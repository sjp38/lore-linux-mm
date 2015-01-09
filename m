Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id EFC6D6B0032
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 10:56:46 -0500 (EST)
Received: by mail-la0-f53.google.com with SMTP id gm9so15564776lab.12
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 07:56:46 -0800 (PST)
Received: from mail-we0-x22b.google.com (mail-we0-x22b.google.com. [2a00:1450:400c:c03::22b])
        by mx.google.com with ESMTPS id vk1si20277641wjc.12.2015.01.09.07.56.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 Jan 2015 07:56:45 -0800 (PST)
Received: by mail-we0-f171.google.com with SMTP id u56so8677125wes.2
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 07:56:45 -0800 (PST)
Date: Fri, 9 Jan 2015 16:56:43 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Linux 3.19-rc3
Message-ID: <20150109155643.GC7596@dhcp22.suse.cz>
References: <CA+55aFwsxoyLb9OWMSCL3doe_cz_EQtKsEFCyPUYn_T87pbz0A@mail.gmail.com>
 <54AE7D53.2020305@redhat.com>
 <20150108150850.GD5658@dhcp22.suse.cz>
 <54AEB25E.9050205@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54AEB25E.9050205@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Langsdorf <mlangsdo@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu 08-01-15 10:37:50, Mark Langsdorf wrote:
> On 01/08/2015 09:08 AM, Michal Hocko wrote:
> >[CCing linux-mm and CMA people]
> >[Full message here:
> >http://article.gmane.org/gmane.linux.ports.arm.kernel/383669]
> 
> >>[ 1054.095277] DMA: 109*64kB (UR) 53*128kB (R) 8*256kB (R) 0*512kB 0*1024kB
> >>0*2048kB 1*4096kB (R) 0*8192kB 0*16384kB 1*32768kB (R) 0*65536kB = 52672kB
> >>[ 1054.108621] Normal: 191*64kB (MR) 0*128kB 0*256kB 0*512kB 0*1024kB
> >>0*2048kB 0*4096kB 0*8192kB 0*16384kB 0*32768kB 0*65536kB = 12224kB
> >[...]
> >>[ 1054.142545] Free swap  = 6598400kB
> >>[ 1054.145928] Total swap = 8388544kB
> >>[ 1054.149317] 262112 pages RAM
> >>[ 1054.152180] 0 pages HighMem/MovableOnly
> >>[ 1054.155995] 18446744073709544361 pages reserved
> >>[ 1054.160505] 8192 pages cma reserved
> >
> >Besides underflow in the reserved pages accounting mentioned in other
> >email the free lists look strange as well. All free blocks with some memory
> >are marked as reserved. I would suspect something CMA related.
> 
> I get the same failure with CMA turned off entirely. I assume that means
> CMA is not the culprit.

OK. Do you see all the free page blocks completely reserved without CMA
as well?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
