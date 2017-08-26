function mylabel(fig,evd,ax)
currentax = evd.Axes; 
if ~isempty(find(ax==currentax))
datetick(currentax, 'x', 'keeplimits');
ticks  = get(currentax, 'XTick');
labels = get(currentax, 'XTickLabel');
set(ax, 'XTick', ticks, 'XTickLabel', labels);
end
end
