Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B03D6B002A
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 15:38:20 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 3so6520389wrb.5
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 12:38:20 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id s44si7469092wrc.426.2018.03.23.12.38.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 23 Mar 2018 12:38:18 -0700 (PDT)
Date: Fri, 23 Mar 2018 20:38:09 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 4/9] x86, pkeys: override pkey when moving away from
 PROT_EXEC
In-Reply-To: <f7897068-18a3-d88b-0458-5dcf05d7ffc2@intel.com>
Message-ID: <alpine.DEB.2.21.1803232036140.1481@nanos.tec.linutronix.de>
References: <20180323180903.33B17168@viggo.jf.intel.com> <20180323180911.E43ACAB8@viggo.jf.intel.com> <CALvZod6F8x-smAE7sEGfJ3Ds5p6M5Qj6gd-P-VLejuBxfU6niQ@mail.gmail.com> <f7897068-18a3-d88b-0458-5dcf05d7ffc2@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Shakeel Butt <shakeelb@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linuxram@us.ibm.com, mpe@ellerman.id.au, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, shuah@kernel.org

On Fri, 23 Mar 2018, Dave Hansen wrote:

> On 03/23/2018 12:15 PM, Shakeel Butt wrote:
> >> We had a check for PROT_READ/WRITE, but it did not work
> >> for PROT_NONE.  This entirely removes the PROT_* checks,
> >> which ensures that PROT_NONE now works.
> >>
> >> Reported-by: Shakeel Butt <shakeelb@google.com>
> >> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> > Should there be a 'Fixes' tag? Also should this patch go to stable?
> 
> There could be, but I'm to lazy to dig up the original commit.  Does it
> matter?
> 
> And, yes, I think it probably makes sense for -stable.  I'll add that if
> I resend this series.

The fixes tag makes sense in general even if the patch is not tagged for
stable. It gives you immediate context and I use it a lot to look why this
went unnoticed or what the context of that change was.

Thanks,

	tglx
