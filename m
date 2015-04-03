Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5E06B0032
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 02:33:08 -0400 (EDT)
Received: by widdi4 with SMTP id di4so99474579wid.0
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 23:33:08 -0700 (PDT)
Received: from mail-wg0-x235.google.com (mail-wg0-x235.google.com. [2a00:1450:400c:c00::235])
        by mx.google.com with ESMTPS id l3si12634517wjf.51.2015.04.02.23.33.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Apr 2015 23:33:07 -0700 (PDT)
Received: by wgra20 with SMTP id a20so103633782wgr.3
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 23:33:06 -0700 (PDT)
Date: Fri, 3 Apr 2015 08:33:02 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v4 0/7] mtrr, mm, x86: Enhance MTRR checks for huge I/O
 mapping
Message-ID: <20150403063302.GA29212@gmail.com>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
 <20150324154324.f9ca557127f7bc7aed45a86b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150324154324.f9ca557127f7bc7aed45a86b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Toshi Kani <toshi.kani@hp.com>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 24 Mar 2015 16:08:34 -0600 Toshi Kani <toshi.kani@hp.com> wrote:
> 
> > This patchset enhances MTRR checks for the kernel huge I/O mapping,
> > which was enabled by the patchset below:
> >   https://lkml.org/lkml/2015/3/3/589
> > 
> > The following functional changes are made in patch 7/7.
> >  - Allow pud_set_huge() and pmd_set_huge() to create a huge page
> >    mapping to a range covered by a single MTRR entry of any memory
> >    type.
> >  - Log a pr_warn() message when a specified PMD map range spans more
> >    than a single MTRR entry.  Drivers should make a mapping request
> >    aligned to a single MTRR entry when the range is covered by MTRRs.
> > 
> 
> OK, I grabbed these after barely looking at them, to get them a bit of
> runtime testing.
> 
> I'll await guidance from the x86 maintainers regarding next steps?

Could you please send the current version of them over to us if your 
testing didn't find any problems?

I'd like to take a final look and have them cook in the x86 tree as 
well for a while and want to preserve your testing effort.

Thanks!

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
