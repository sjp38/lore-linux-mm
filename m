Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E39F76B026F
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 05:03:02 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id n13so918545wra.13
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 02:03:02 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o26sor3368241edi.29.2018.01.19.02.03.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jan 2018 02:03:01 -0800 (PST)
Date: Fri, 19 Jan 2018 13:02:59 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Message-ID: <20180119100259.rwq3evikkemtv7q5@node.shutemov.name>
References: <201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
 <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
 <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name>
 <d8347087-18a6-1709-8aa8-3c6f2d16aa94@linux.intel.com>
 <20180118154026.jzdgdhkcxiliaulp@node.shutemov.name>
 <20180118172213.GI6584@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180118172213.GI6584@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, torvalds@linux-foundation.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, tony.luck@intel.com, vbabka@suse.cz, aarcange@redhat.com, hillf.zj@alibaba-inc.com, hughd@google.com, oleg@redhat.com, peterz@infradead.org, riel@redhat.com, srikar@linux.vnet.ibm.com, vdavydov.dev@gmail.com, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Thu, Jan 18, 2018 at 06:22:13PM +0100, Michal Hocko wrote:
> On Thu 18-01-18 18:40:26, Kirill A. Shutemov wrote:
> [...]
> > +	/*
> > +	 * Make sure that pages are in the same section before doing pointer
> > +	 * arithmetics.
> > +	 */
> > +	if (page_to_section(pvmw->page) != page_to_section(page))
> > +		return false;
> 
> OK, THPs shouldn't cross memory sections AFAIK. My brain is meltdown
> these days so this might be a completely stupid question. But why don't
> you simply compare pfns? This would be just simpler, no?

In original code, we already had pvmw->page around and I thought it would
be easier to get page for the pte intead of looking for pfn for both
sides.

We these changes it's no longer the case.

Do you care enough to send a patch? :)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
