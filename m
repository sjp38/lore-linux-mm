Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 37E606B000A
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 14:00:07 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id y11so589959wmd.5
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 11:00:07 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m26sor7697112wrb.86.2018.02.15.11.00.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Feb 2018 11:00:05 -0800 (PST)
Date: Thu, 15 Feb 2018 20:00:01 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 2/4] x86/mm/memory_hotplug: determine block size based
 on the end of boot memory
Message-ID: <20180215190001.rbvrb74jxpvs6vrz@gmail.com>
References: <20180213193159.14606-1-pasha.tatashin@oracle.com>
 <20180213193159.14606-3-pasha.tatashin@oracle.com>
 <20180215113725.GC7275@dhcp22.suse.cz>
 <CAOAebxu5EM1qhC=pS2cCqjGfBabFEj0aQQNon1nAz5_3YPOsCw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOAebxu5EM1qhC=pS2cCqjGfBabFEj0aQQNon1nAz5_3YPOsCw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com


* Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> > I dunno. If x86 maintainers are OK with this then why not, but I do not
> > like how this is x86 specific. I would much rather address this by
> > making the memblock user interface more sane.
> >
> 
> Hi Michal,
> 
> Ingo Molnar reviewed this patch, and Okayed it.

But I'd not be against robustifying the whole generic interface against such 
misconfiguration either.

But having the warning should be enough in practice, right?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
