Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 06C666B0038
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 05:32:15 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id s63so20336730wms.7
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 02:32:14 -0800 (PST)
Received: from mifar.in (mifar.in. [46.101.129.31])
        by mx.google.com with ESMTPS id i7si1274477wjl.146.2017.01.10.02.32.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 02:32:13 -0800 (PST)
Received: from mifar.in (host-109-204-146-251.tp-fne.tampereenpuhelin.net [109.204.146.251])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(Client CN "mifar.in", Issuer "mifar.in" (verified OK))
	by mifar.in (Postfix) with ESMTPS id 6DF105FD0C
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 12:32:12 +0200 (EET)
Date: Tue, 10 Jan 2017 12:32:11 +0200
From: Sami Farin <hvtaifwkbgefbaei@gmail.com>
Subject: Re: [BUG] How to crash 4.9.2 x86_64: vmscan: shrink_slab
Message-ID: <20170110103211.arb3sqv54hu4gdiy@m.mifar.in>
References: <20170109210210.2zgvw6nfs4qbgmjw@m.mifar.in>
 <20170110092241.GA28032@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170110092241.GA28032@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

On Tue, Jan 10, 2017 at 10:22:41 +0100, Michal Hocko wrote:
> On Mon 09-01-17 23:02:10, Sami Farin wrote:
> > # sysctl vm.vfs_cache_pressure=-100
> > 
> > kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6640827866535449472
> > kernel: vmscan: shrink_slab: super_cache_scan+0x0/0x1a0 negative objects to delete nr=-6640827866535450112
...
> > 
> > 
> > Alternatively,
> > # sysctl vm.vfs_cache_pressure=10000000
> 
> Both values are insane and admins do not do insane things to their
> machines, do they?

Not on purpose, unless they are insane :)

Docs say:
"Increasing vfs_cache_pressure significantly beyond 100 may have
negative performance impact."
Nothing about crashing.

But anyways, the problem I originally had was:
with vm.vfs_cache_pressure=0 , dentry/inode caches are reclaimed
at a very alarming rate, and when I e.g. rescan quodlibet media
directory (only 30000 files), that takes a lot of time..  I only download
some files for a minute and dentry/inode caches are reclaimed,
or so it seems.  Still, SReclaimable keeps on increasing, when it gets to
about 6 GB , I increase vm.vfs_cache_pressure .... 

-- 
Do what you love because life is too short for anything else.
https://samifar.in/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
