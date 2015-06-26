Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id DDC946B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 05:09:03 -0400 (EDT)
Received: by wiga1 with SMTP id a1so11789470wig.0
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 02:09:03 -0700 (PDT)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id f18si57340501wjz.182.2015.06.26.02.09.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jun 2015 02:09:02 -0700 (PDT)
Received: by wicnd19 with SMTP id nd19so11758705wic.1
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 02:09:02 -0700 (PDT)
Date: Fri, 26 Jun 2015 11:08:56 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150626090856.GA31657@gmail.com>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
 <20150608174551.GA27558@gmail.com>
 <20150609084739.GQ26425@suse.de>
 <20150609103231.GA11026@gmail.com>
 <20150609112055.GS26425@suse.de>
 <20150609124328.GA23066@gmail.com>
 <5577078B.2000503@intel.com>
 <20150621202231.GB6766@node.dhcp.inet.fi>
 <20150625114819.GA20478@gmail.com>
 <558C4C8E.5010107@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <558C4C8E.5010107@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>


* Dave Hansen <dave.hansen@intel.com> wrote:

> On 06/25/2015 04:48 AM, Ingo Molnar wrote:
>
> > I've updated the benchmarks with 4K flushes as well. Changes to the previous 
> > measurement:
> 
> Did you push these out somewhere?  The tip tmp.fpu branch hasn't seen any 
> updates.

Not yet, I still don't trust the numbers.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
