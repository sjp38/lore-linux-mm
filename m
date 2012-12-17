Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id B6E7C6B002B
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 03:14:05 -0500 (EST)
Date: Mon, 17 Dec 2012 10:14:47 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: BUG: MAX_LOCK_DEPTH too low!
Message-ID: <20121217081447.GB24173@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

I've got this BUG on up-to-date Linus tree (aed606e):

[ 1145.439071] BUG: MAX_LOCK_DEPTH too low!
[ 1145.439077] turning off the locking correctness validator.
[ 1145.439081] Pid: 4619, comm: kvm Not tainted 3.7.0-08682-gaed606e-dirty =
#166
[ 1145.439084] Call Trace:
[ 1145.439094]  [<ffffffff810e6094>] __lock_acquire.isra.24+0xc54/0xe10
[ 1145.439099]  [<ffffffff810e6873>] lock_acquire+0x93/0x140
[ 1145.439106]  [<ffffffff8117bfa8>] ? mm_take_all_locks+0x148/0x1b0
[ 1145.439111]  [<ffffffff8173d239>] down_write+0x49/0x90
[ 1145.439115]  [<ffffffff8117bfa8>] ? mm_take_all_locks+0x148/0x1b0
[ 1145.439119]  [<ffffffff8117bfa8>] mm_take_all_locks+0x148/0x1b0
[ 1145.439124]  [<ffffffff81192253>] ? do_mmu_notifier_register+0x153/0x180
[ 1145.439128]  [<ffffffff8119217f>] do_mmu_notifier_register+0x7f/0x180
[ 1145.439132]  [<ffffffff811922b3>] mmu_notifier_register+0x13/0x20
[ 1145.439138]  [<ffffffff81006036>] kvm_dev_ioctl+0x3e6/0x520
[ 1145.439142]  [<ffffffff810e40e8>] ? debug_check_no_locks_freed+0xd8/0x170
[ 1145.439148]  [<ffffffff811be6c7>] do_vfs_ioctl+0x97/0x540
[ 1145.439152]  [<ffffffff811bec01>] sys_ioctl+0x91/0xb0
[ 1145.439158]  [<ffffffff8132464e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 1145.439163]  [<ffffffff817478c6>] system_call_fastpath+0x1a/0x1f

--=20
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
