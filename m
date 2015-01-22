Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 16A876B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 20:52:49 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so4945267pad.7
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 17:52:48 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id fn10si10780269pab.65.2015.01.21.17.52.46
        for <linux-mm@kvack.org>;
        Wed, 21 Jan 2015 17:52:47 -0800 (PST)
Date: Thu, 22 Jan 2015 10:53:44 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Bisected BUG: using smp_processor_id() in preemptible
Message-ID: <20150122015344.GC21444@js1304-P5Q-DELUXE>
References: <1421746712.6847.5.camel@AMDC1943>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421746712.6847.5.camel@AMDC1943>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Mo rton <akpm@linux-foundation.org>, BartlomiejZolnierkiewicz <b.zolnierkie@samsung.com>, KyungminPark <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Tue, Jan 20, 2015 at 10:38:32AM +0100, Krzysztof Kozlowski wrote:
> Hi,
> 
> 
> Since next-20150119 booting of Exynos4 based boards is nearly impossible
> because of continuous BUG on messages. The system finally boots... but
> console log is polluted with:
> 
> [    9.700828] BUG: using smp_processor_id() in preemptible [00000000] code: udevd/1656
> [    9.708525] caller is kfree+0x8c/0x198
> [    9.712229] CPU: 2 PID: 1656 Comm: udevd Tainted: G        W      3.19.0-rc4-00279-gd2dc80750ee0 #1630
> [    9.721501] Hardware name: SAMSUNG EXYNOS (Flattened Device Tree)
> [    9.727602] [<c0014980>] (unwind_backtrace) from [<c0011904>] (show_stack+0x10/0x14)
> [    9.735324] [<c0011904>] (show_stack) from [<c0585bbc>] (dump_stack+0x70/0xbc)
> [    9.742525] [<c0585bbc>] (dump_stack) from [<c01e79e0>] (check_preemption_disabled+0xf8/0x128)
> [    9.751114] [<c01e79e0>] (check_preemption_disabled) from [<c00c501c>] (kfree+0x8c/0x198)
> [    9.759265] [<c00c501c>] (kfree) from [<c0299b7c>] (uevent_show+0x38/0x104)
> [    9.766210] [<c0299b7c>] (uevent_show) from [<c0299fb8>] (dev_attr_show+0x1c/0x48)
> [    9.773763] [<c0299fb8>] (dev_attr_show) from [<c0122424>] (sysfs_kf_seq_show+0x8c/0x10c)
> [    9.781920] [<c0122424>] (sysfs_kf_seq_show) from [<c0120f90>] (kernfs_seq_show+0x24/0x28)
> [    9.790172] [<c0120f90>] (kernfs_seq_show) from [<c00e93b0>] (seq_read+0x1ac/0x480)
> [    9.797806] [<c00e93b0>] (seq_read) from [<c00cacf4>] (__vfs_read+0x18/0x4c)
> [    9.804833] [<c00cacf4>] (__vfs_read) from [<c00cada4>] (vfs_read+0x7c/0x100)
> [    9.811950] [<c00cada4>] (vfs_read) from [<c00cae68>] (SyS_read+0x40/0x8c)
> [    9.818810] [<c00cae68>] (SyS_read) from [<c000f160>] (ret_fast_syscall+0x0/0x30)
> 
> I bisected this to:
> 
> d2dc80750ee05ceb03c9b13b0531a782116d1ade
> Author: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date:   Sat Jan 17 11:23:23 2015 +1100
> mm/slub: optimize alloc/free fastpath by removing preemption on/off
> 
> Full dmesg and config attached.
> 
> Any ideas?

Hello,

This issue will be fixed in next mmotm release.
Following patch is next version of
commit d2dc80750ee05ceb03c9b13b0531a782116d1ade.

https://lkml.org/lkml/2015/1/19/17

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
