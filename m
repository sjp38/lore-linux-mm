Message-Id: <20071114221020.227931278@sgi.com>
References: <20071114220906.206294426@sgi.com>
Date: Wed, 14 Nov 2007 14:09:09 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 03/17] SLUB: Replace ctor field with ops field in /sys/slab/:0000008 /sys/slab/:0000016 /sys/slab/:0000024 /sys/slab/:0000032 /sys/slab/:0000040 /sys/slab/:0000048 /sys/slab/:0000056 /sys/slab/:0000064 /sys/slab/:0000072 /sys/slab/:0000080 /sys/slab/:0000088 /sys/slab/:0000096 /sys/slab/:0000104 /sys/slab/:0000128 /sys/slab/:0000144 /sys/slab/:0000184 /sys/slab/:0000192 /sys/slab/:0000216 /sys/slab/:0000256 /sys/slab/:0000344 /sys/slab/:0000384 /sys/slab/:0000448 /sys/slab/:0000512 /sys/slab/:0000768 /sys/slab/:0000976 /sys/slab/:0001024 /sys/slab/:0001152 /sys/slab/:0001328 /sys/slab/:0001536 /sys/slab/:0002048 /sys/slab/:0003072 /sys/slab/:0004096 /sys/slab/:a-0000016 /sys/slab/:a-0000024 /sys/slab/:a-0000056 /sys/slab/:a-0000080 /sys/slab/Acpi-Namespace /sys/slab/Acpi-Operand /sys/slab/Acpi-Parse /sys/slab/Acpi-ParseExt /sys/slab/Acpi-State /sys/slab/RAW /sys/slab/TCP /sys/slab/UDP /sys/slab/UDP-Lite /sys/slab/UNIX /sys/slab/anon_vma /sys/slab/arp_cache /sy
 s/slab/bdev_cache /sys/slab/bio /sys/slab/biovec-1 /sys/slab/biovec-128 /sys/slab/biovec-16 /sys/slab/biovec-256 /sys/slab/biovec-4 /sys/slab/biovec-64 /sys/slab/blkdev_ioc /sys/slab/blkdev_queue /sys/slab/blkdev_requests /sys/slab/buffer_head /sys/slab/cfq_io_context /sys/slab/cfq_queue /sys/slab/dentry_cache /sys/slab/eventpoll_epi /sys/slab/eventpoll_pwq /sys/slab/ext2_inode_cache /sys/slab/ext3_inode_cache /sys/slab/fasync_cache /sys/slab/file_lock_cache /sys/slab/files_cache /sys/slab/filp /sys/slab/flow_cache /sys/slab/fs_cache /sys/slab/idr_layer_cache /sys/slab/inet_peer_cache /sys/slab/inode_cache /sys/slab/inotify_event_cache /sys/slab/inotify_watch_cache /sys/slab/ip_dst_cache /sys/slab/ip_fib_alias /sys/slab/ip_fib_hash /sys/slab/journal_handle /sys/slab/journal_head /sys/slab/kiocb /sys/slab/kioctx /sys/slab/kmalloc-1024 /sys/slab/kmalloc-128 /sys/slab/kmalloc-16 /sys/slab/kmalloc-192 /sys/slab/kmalloc-2048 /sys/slab/kmalloc-256 /sys/slab/kmalloc-32 /sys/slab/km
 alloc-512 /sys/slab/kmalloc-64 /sys/slab/kmalloc-8 /sys/slab/kmalloc-96 /sys/slab/mm_struct /sys/slab/mnt_cache /sys/slab/mqueue_inode_cache /sys/slab/names_cache /sys/slab/nfs_direct_cache /sys/slab/nfs_inode_cache /sys/slab/nfs_page /sys/slab/nfs_read_data /sys/slab/nfs_write_data /sys/slab/nfsd4_delegations /sys/slab/nfsd4_files /sys/slab/nfsd4_stateids /sys/slab/nfsd4_stateowners /sys/slab/nsproxy /sys/slab/pid_1 /sys/slab/pid_namespace /sys/slab/posix_timers_cache /sys/slab/proc_inode_cache /sys/slab/radix_tree_node /sys/slab/request_sock_TCP /sys/slab/revoke_record /sys/slab/revoke_table /sys/slab/rpc_buffers /sys/slab/rpc_inode_cache /sys/slab/rpc_tasks /sys/slab/scsi_cmd_cache /sys/slab/scsi_io_context /sys/slab/secpath_cache /sys/slab/sgpool-128 /sys/slab/sgpool-16 /sys/slab/sgpool-32 /sys/slab/sgpool-64 /sys/slab/sgpool-8 /sys/slab/shmem_inode_cache /sys/slab/sighand_cache /sys/slab/signal_cache /sys/slab/sigqueue /sys/slab/skbuff_fclone_cache /sys/slab/skbuff_head
 _cache /sys/slab/sock_inode_cache /sys/slab/sysfs_dir_cache /sys/slab/task_struct /sys/slab/tcp_bind_bucket /sys/slab/tw_sock_TCP /sys/slab/uhci_urb_priv /sys/slab/uid_cache /sys/slab/vm_area_struct /sys/slab/xfrm_dst_cache
Content-Disposition: inline; filename=0049-SLUB-Replace-ctor-field-with-ops-field-in-sys-slab.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

Create an ops field in /sys/slab/*/ops to contain all the operations defined
on a slab. This will be used to display the additional operations that will
be defined soon.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

Index: linux-2.6.24-rc2-mm1/mm/slub.c
===================================================================
--- linux-2.6.24-rc2-mm1.orig/mm/slub.c	2007-11-14 12:06:05.338343172 -0800
+++ linux-2.6.24-rc2-mm1/mm/slub.c	2007-11-14 12:06:18.770343797 -0800
@@ -3793,16 +3793,18 @@ static ssize_t order_show(struct kmem_ca
 }
 SLAB_ATTR_RO(order);
 
-static ssize_t ctor_show(struct kmem_cache *s, char *buf)
+static ssize_t ops_show(struct kmem_cache *s, char *buf)
 {
-	if (s->ctor) {
-		int n = sprint_symbol(buf, (unsigned long)s->ctor);
+	int x = 0;
 
-		return n + sprintf(buf + n, "\n");
+	if (s->ctor) {
+		x += sprintf(buf + x, "ctor : ");
+		x += sprint_symbol(buf + x, (unsigned long)s->ops->ctor);
+		x += sprintf(buf + x, "\n");
 	}
-	return 0;
+	return x;
 }
-SLAB_ATTR_RO(ctor);
+SLAB_ATTR_RO(ops);
 
 static ssize_t aliases_show(struct kmem_cache *s, char *buf)
 {
@@ -4053,7 +4055,7 @@ static struct attribute *slab_attrs[] = 
 	&slabs_attr.attr,
 	&partial_attr.attr,
 	&cpu_slabs_attr.attr,
-	&ctor_attr.attr,
+	&ops_attr.attr,
 	&aliases_attr.attr,
 	&align_attr.attr,
 	&sanity_checks_attr.attr,

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
