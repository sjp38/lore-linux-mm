Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4999F6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 07:36:56 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id f38so4858425wrf.3
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 04:36:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 79si71125wmh.251.2017.08.14.04.36.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Aug 2017 04:36:55 -0700 (PDT)
Date: Mon, 14 Aug 2017 13:36:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 04/15] mm: discard memblock data later
Message-ID: <20170814113652.GF19063@dhcp22.suse.cz>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-5-git-send-email-pasha.tatashin@oracle.com>
 <20170811093249.GE30811@dhcp22.suse.cz>
 <6366171f-1a30-2faa-d776-01983fcb5a00@oracle.com>
 <20170811160436.GS30811@dhcp22.suse.cz>
 <a63eb223-455f-ae57-122f-7b2655e3de26@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a63eb223-455f-ae57-122f-7b2655e3de26@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, Mel Gorman <mgorman@suse.de>

On Fri 11-08-17 12:22:52, Pasha Tatashin wrote:
> >>I will address your comment, and send out a new patch. Should I send it out
> >>separately from the series or should I keep it inside?
> >
> >I would post it separatelly. It doesn't depend on the rest.
> 
> OK, I will post it separately. No it does not depend on the rest, but the
> reset depends on this. So, I am not sure how to enforce that this comes
> before the rest.

Andrew will take care of that. Just make it explicit that some of the
patch depends on an earlier work when reposting.
 
> >>Also, before I send out a new patch, I will need to root cause and resolve
> >>problem found by kernel test robot <fengguang.wu@intel.com>, and bisected
> >>down to this patch.
> >>
> >>[  156.659400] BUG: Bad page state in process swapper  pfn:03147
> >>[  156.660051] page:ffff88001ed8a1c0 count:0 mapcount:-127 mapping:
> >>(null) index:0x1
> >>[  156.660917] flags: 0x0()
> >>[  156.661198] raw: 0000000000000000 0000000000000000 0000000000000001
> >>00000000ffffff80
> >>[  156.662006] raw: ffff88001f4a8120 ffff88001ed85ce0 0000000000000000
> >>0000000000000000
> >>[  156.662811] page dumped because: nonzero mapcount
> >>[  156.663307] CPU: 0 PID: 1 Comm: swapper Not tainted
> >>4.13.0-rc3-00220-g1aad694 #1
> >>[  156.664077] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> >>1.9.3-20161025_171302-gandalf 04/01/2014
> >>[  156.665129] Call Trace:
> >>[  156.665422]  dump_stack+0x1e/0x20
> >>[  156.665802]  bad_page+0x122/0x148
> >
> >Was the report related with this patch?
> 
> Yes, they said that the problem was bisected down to this patch. Do you know
> if there is a way to submit a patch to this test robot?

You can ask them for re testing with an updated patch by replying to
their report. ANyway I fail to see how the change could lead to this
patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
