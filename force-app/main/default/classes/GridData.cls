/**
 * Implementors of this interface are expected to serve data to a Grid component instance.
 */
public interface GridData {

	List<Object> getRecords(GridContext context);
}