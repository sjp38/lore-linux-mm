Date: Mon, 30 Apr 2007 12:46:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.21-rc7-mm2 crash: Eeek! page_mapcount(page) went negative!
 (-1)
Message-Id: <20070430124638.10611058.akpm@linux-foundation.org>
In-Reply-To: <46364346.6030407@imap.cc>
References: <20070425225716.8e9b28ca.akpm@linux-foundation.org>
	<46338AEB.2070109@imap.cc>
	<20070428141024.887342bd.akpm@linux-foundation.org>
	<4636248E.7030309@imap.cc>
	<20070430112130.b64321d3.akpm@linux-foundation.org>
	<46364346.6030407@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tilman Schmidt <tilman@imap.cc>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 30 Apr 2007 21:28:06 +0200
Tilman Schmidt <tilman@imap.cc> wrote:

> Am 30.04.2007 20:21 schrieb Andrew Morton:
> > A lot of Greg's driver tree has gone upstream, so please check current
> > mainline.
> 
> 2.6.21-final is fine.

Sure, but what about 2.6.21-git3 (or, better, current -git)?

> >  If that's OK then we need to pick through the difference between
> > 2.6.21-rc7-mm2's driver tree and the patches which went into mainline.  And
> > that's a pretty small set.
> 
> I'm not quite sure how to determine that difference. Can you just provide
> me with a list of patches you'd like me to test?

Not really - everything's tangled up.  A bisection search on the
2.6.21-rc7-mm2 driver tree would be the best bet.

See, 2.6.21-rc7-mm2 had:

gregkh-driver-driver-core-fix-device_add-error-path.patch
gregkh-driver-driver-core-fix-namespace-issue-with-devices-assigned-to-classes.patch
gregkh-driver-dev_printk-and-new-style-class-devices.patch
gregkh-driver-driver-core-udev-triggered-device-driver-binding.patch
gregkh-driver-driver-core-use-attribute-groups-in-struct-device_type.patch
gregkh-driver-named-device_type.patch
gregkh-driver-kobject-kobject_shadow_add-cleanup.patch
gregkh-driver-driver-core-per-subsystem-multithreaded-probing.patch
gregkh-driver-powerpc-make-it-compile-for-multithread-change.patch
gregkh-driver-driver-core-don-t-fail-attaching-the-device-if-it-cannot-be-bound.patch
gregkh-driver-driver-no-more-wait.patch
gregkh-driver-kref-fix-cpu-ordering-with-respect-to-krefs.patch
gregkh-driver-driver-core-notify-userspace-of-network-device-renames.patch
gregkh-driver-driver-core-suppress-uevents-via-filter.patch
gregkh-driver-driver-core-switch-firmware_class-to-uevent_suppress.patch
gregkh-driver-uevent-use-add_uevent_var-instead-of-open-coding-it.patch
gregkh-driver-driver-core-add-suspend-and-resume-to-struct-device_type.patch
gregkh-driver-kobject-kobject_ueventc-collapse-unnecessary-loop-nesting.patch
gregkh-driver-kobject-kobject_add-reference-leak.patch
gregkh-driver-devices_subsys-rwsem-removal.patch
gregkh-driver-scsi-hosts-rwsem-removal.patch
gregkh-driver-usb-bus-mutex.patch
gregkh-driver-pnp-remove-rwsem-usage.patch
gregkh-driver-input-serio-do-not-touch-bus-s-rwsem.patch
gregkh-driver-input-gameport-do-not-touch-bus-s-rwsem.patch
gregkh-driver-ide-proc-remove-rwsem.patch
gregkh-driver-ieee1394-rwsem-removal.patch
gregkh-driver-phy-rwsem-removal.patch
gregkh-driver-qeth-remove-usage-of-subsys_rwsem.patch
gregkh-driver-subsys-rwsem-removal.patch
gregkh-driver-sysfs-fix-i_ino-handling-in-sysfs.patch
gregkh-driver-sysfs-fix-error-handling-in-binattr-write.patch
gregkh-driver-sysfs-move-release_sysfs_dirent-to-dirc.patch
gregkh-driver-sysfs-flatten-cleanup-paths-in-sysfs_add_link-and-create_dir.patch
gregkh-driver-sysfs-consolidate-sysfs_dirent-creation-functions.patch
gregkh-driver-sysfs-add-sysfs_dirent-s_parent.patch
gregkh-driver-sysfs-add-sysfs_dirent-s_name.patch
gregkh-driver-sysfs-make-sysfs_dirent-s_element-a-union.patch
gregkh-driver-sysfs-implement-kobj_sysfs_assoc_lock.patch
gregkh-driver-sysfs-reimplement-symlink-using-sysfs_dirent-tree.patch
gregkh-driver-sysfs-implement-bin_buffer.patch
gregkh-driver-sysfs-implement-sysfs_dirent-active-reference-and-immediate-disconnect.patch
gregkh-driver-sysfs-kill-attribute-file-orphaning.patch
gregkh-driver-sysfs-kill-unnecessary-attribute-owner.patch
gregkh-driver-sysfs-make-lockdep-ignore-s_active.patch
gregkh-driver-sysfs-make-sysfs_put-ignore-null-sd.patch
gregkh-driver-sysfs-rename-object_depth-to-sysfs_path_depth-and-make-it-global.patch
gregkh-driver-sysfs-reimplement-sysfs_drop_dentry.patch
gregkh-driver-sysfs-kill-sysfs_dirent-s_dentry.patch
gregkh-driver-driver-core-make-uevent-environment-available-in-uevent-file.patch
gregkh-driver-driver-core-warn-for-odd-store-uevent-usage.patch
gregkh-driver-kobject-comment-and-warning-fixes-to-kobjectc.patch
gregkh-driver-the-overdue-removal-of-the-mount-umount-uevents.patch
gregkh-driver-debugfs-add-debugfs_create_u64.patch
gregkh-driver-bus_add_driver-return-error-for-no-bus.patch
gregkh-driver-uio.patch
gregkh-driver-uio-documentation.patch
gregkh-driver-uio-dummy.patch
gregkh-driver-uio-hilscher-cif-card-driver.patch
gregkh-driver-remove-struct-subsystem-as-it-is-no-longer-needed.patch
gregkh-driver-put_device-might_sleep.patch
gregkh-driver-kobject-warn.patch
gregkh-driver-warn-when-statically-allocated-kobjects-are-used.patch
gregkh-driver-nozomi.patch


and Greg's driver tree (as of yesterday, I think) had

gregkh-driver-uio.patch
gregkh-driver-uio-documentation.patch
gregkh-driver-uio-dummy.patch
gregkh-driver-uio-hilscher-cif-card-driver.patch
gregkh-driver-remove-struct-subsystem-as-it-is-no-longer-needed.patch
gregkh-driver-put_device-might_sleep.patch
gregkh-driver-kobject-warn.patch
gregkh-driver-warn-when-statically-allocated-kobjects-are-used.patch
gregkh-driver-nozomi.patch

So what has happened (approximately) is that

- the above nine patches have been held back, or are new

- Tejun's sysfs changes have been dropped

- Everything else from 2.6.21-rc7-mm2 has gone into mainline


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
