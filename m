Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2769003C8
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 05:32:12 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so40804609pdj.3
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 02:32:12 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id sg9si9096000pac.108.2015.07.31.02.32.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 02:32:11 -0700 (PDT)
Received: by pabkd10 with SMTP id kd10so38270940pab.2
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 02:32:10 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Subject: Re: [PATCH 14/15] mm: Drop unlikely before IS_ERR(_OR_NULL)
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <20150731085646.GA31544@node.dhcp.inet.fi>
Date: Fri, 31 Jul 2015 17:32:02 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <FA3D9AE9-9D1E-4232-87DE-42F21B408B24@gmail.com>
References: <cover.1438331416.git.viresh.kumar@linaro.org> <91586af267deb26b905fba61a9f1f665a204a4e3.1438331416.git.viresh.kumar@linaro.org> <20150731085646.GA31544@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Viresh Kumar <viresh.kumar@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, linaro-kernel@lists.linaro.org, open list <linux-kernel@vger.kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>


> On Jul 31, 2015, at 16:56, Kirill A. Shutemov <kirill@shutemov.name> =
wrote:
>=20
> On Fri, Jul 31, 2015 at 02:08:34PM +0530, Viresh Kumar wrote:
>> IS_ERR(_OR_NULL) already contain an 'unlikely' compiler flag and =
there
>> is no need to do that again from its callers. Drop it.
>>=20
>> Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
>=20
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>=20
> --=20
> Kirill A. Shutemov
> --
> To unsubscribe from this list: send the line "unsubscribe =
linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
search in code, there are lots of using like this , does need add this =
check into checkpatch ?

# grep -r 'likely.*IS_ERR'  .
./include/linux/blk-cgroup.h:	if (unlikely(IS_ERR(blkg)))
./fs/nfs/objlayout/objio_osd.c:	if (unlikely(IS_ERR(od))) {
./fs/cifs/readdir.c:	if (unlikely(IS_ERR(dentry)))
./fs/ext4/extents.c:		if (unlikely(IS_ERR(bh))) {
./fs/ext4/extents.c:		if (unlikely(IS_ERR(path1))) {
./fs/ext4/extents.c:		if (unlikely(IS_ERR(path2))) {
./fs/ext4/namei.c:				if =
(unlikely(IS_ERR(bh))) {
./fs/ntfs/lcnalloc.c:	if (likely(page && !IS_ERR(page))) {
./fs/ntfs/runlist.c:	if (likely(!IS_ERR(old_rl)))
./fs/ntfs/mft.c:	if (likely(!IS_ERR(page))) {
./fs/ntfs/mft.c:	if (likely(!IS_ERR(m)))
./fs/ntfs/mft.c:		if (likely(!IS_ERR(m))) {
./fs/ntfs/mft.c:	if (unlikely(IS_ERR(rl) || !rl->length || =
rl->lcn < 0)) {
./fs/ntfs/mft.c:	if (unlikely(IS_ERR(rl) || !rl->length || =
rl->lcn < 0)) {
./fs/ntfs/mft.c:		if (likely(!IS_ERR(rl2)))
./fs/ntfs/inode.c:	if (unlikely(err || IS_ERR(m))) {
./fs/ntfs/namei.c:		if (likely(!IS_ERR(dent_inode))) {
./fs/ntfs/super.c:	if (unlikely(IS_ERR(tmp_ino) || =
is_bad_inode(tmp_ino))) {
./fs/namei.c:			if (unlikely(IS_ERR(s)))
./fs/namei.c:	if (unlikely(IS_ERR(filename)))
./fs/gfs2/dir.c:	if (unlikely(dent =3D=3D NULL || IS_ERR(dent))) =
{
./fs/ecryptfs/inode.c:	if (unlikely(IS_ERR(ecryptfs_inode))) {
./fs/ncpfs/dir.c:	if (unlikely(IS_ERR(newdent)))
./fs/proc/proc_sysctl.c:	if (unlikely(IS_ERR(subdir))) {
Binary file =
./.git/objects/pack/pack-4a5df920db8b8d9df9a91893c9567b4b2f15b782.pack =
matches
./drivers/target/tcm_fc/tfc_cmd.c:	if (unlikely(IS_ERR(fp))) {
./drivers/thermal/intel_powerclamp.c:		if =
(likely(!IS_ERR(thread))) {
./drivers/thermal/intel_powerclamp.c:		if =
(likely(!IS_ERR(thread))) {
./drivers/gpu/drm/vmwgfx/vmwgfx_drv.c:	if (unlikely(IS_ERR(vmaster))) {
./drivers/gpu/drm/vmwgfx/vmwgfx_context.c:		if =
(unlikely(IS_ERR(uctx->man))) {
./drivers/gpu/drm/ttm/ttm_tt.c:		if =
(unlikely(IS_ERR(swap_storage))) {
./drivers/gpu/drm/ttm/ttm_tt.c:		if (unlikely(IS_ERR(to_page))) {
./drivers/scsi/bnx2fc/bnx2fc_fcoe.c:	if (likely(!IS_ERR(thread))) {
./drivers/scsi/bnx2i/bnx2i_init.c:	if (likely(!IS_ERR(thread))) {
./drivers/scsi/fcoe/fcoe.c:	if (likely(!IS_ERR(thread))) {
./drivers/base/power/opp.c:	if (unlikely(IS_ERR_OR_NULL(dev))) {
./drivers/base/power/opp.c:	if (unlikely(IS_ERR_OR_NULL(tmp_opp)) || =
!tmp_opp->available)
./drivers/base/power/opp.c:	if (unlikely(IS_ERR_OR_NULL(tmp_opp)) || =
!tmp_opp->available)
./drivers/tty/serial/serial_core.c:	if (likely(!IS_ERR(tty_dev))) {
./drivers/rtc/rtc-bfin.c:	if (unlikely(IS_ERR(rtc->rtc_dev)))
./drivers/rtc/rtc-gemini.c:	if (likely(IS_ERR(rtc->rtc_dev)))
./drivers/rtc/interface.c:	if (unlikely(IS_ERR_OR_NULL(rtc)))
./drivers/md/dm-snap-persistent.c:		if =
(unlikely(IS_ERR(area))) {
./drivers/md/dm-verity.c:	if (unlikely(IS_ERR(data)))
./drivers/md/persistent-data/dm-block-manager.c:	if =
(unlikely(IS_ERR(p)))
./drivers/md/persistent-data/dm-block-manager.c:	if =
(unlikely(IS_ERR(p)))
./drivers/md/persistent-data/dm-block-manager.c:	if =
(unlikely(IS_ERR(p)))
./drivers/md/persistent-data/dm-block-manager.c:	if =
(unlikely(IS_ERR(p)))
./drivers/staging/lustre/include/linux/libcfs/libcfs.h:	if =
(unlikely(IS_ERR(ptr) || ptr =3D=3D NULL))
./drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c:		if =
(likely(!IS_ERR(pfmr))) {
./drivers/staging/lustre/lustre/obdclass/lu_object.c:	if =
(unlikely(IS_ERR(o)))
./drivers/staging/lustre/lustre/obdclass/lu_object.c:	if =
(unlikely(IS_ERR(o)))
./drivers/staging/lustre/lustre/obdclass/lu_object.c:	if =
(likely(IS_ERR(shadow) && PTR_ERR(shadow) =3D=3D -ENOENT)) {
./drivers/staging/lustre/lustre/obdclass/lu_object.c:			=
if (unlikely(IS_ERR(value)))
./drivers/staging/android/ashmem.c:		if =
(unlikely(IS_ERR(vmfile))) {
./drivers/input/mouse/alps.c:	} else if =
(unlikely(IS_ERR_OR_NULL(priv->dev3))) {
./drivers/net/ethernet/marvell/sky2.c:	if (unlikely(status & =
Y2_IS_ERROR))
./drivers/net/ethernet/ti/netcp_core.c:	if =
(unlikely(IS_ERR_OR_NULL(desc))) {
./drivers/net/ethernet/ti/netcp_core.c:		if =
(unlikely(IS_ERR_OR_NULL(ndesc))) {
./drivers/devfreq/devfreq.c:	if (unlikely(IS_ERR_OR_NULL(dev))) {
./drivers/devfreq/devfreq.c:	if (unlikely(IS_ERR_OR_NULL(name))) {
./drivers/misc/c2port/core.c:	if (unlikely(IS_ERR(c2dev->dev))) {
./net/socket.c:	if (unlikely(IS_ERR(file))) {
./net/socket.c:	if (likely(!IS_ERR(newfile))) {
./net/socket.c:	if (unlikely(IS_ERR(newfile1))) {
./net/socket.c:	if (unlikely(IS_ERR(newfile))) {
./net/openvswitch/datapath.c:		if (unlikely(IS_ERR(reply))) {
./net/openvswitch/datapath.c:		if (likely(!IS_ERR(reply))) {
./net/sctp/socket.c:	if (unlikely(IS_ERR(newfile))) {
./mm/huge_memory.c:		if (unlikely(IS_ERR(khugepaged_thread))) =
{

Thanks



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
