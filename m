Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3071E6B0038
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 15:11:57 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id w13so114864wmw.0
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 12:11:57 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id w206si41031wmb.82.2017.01.05.12.11.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 12:11:55 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id m203so85855wma.3
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 12:11:55 -0800 (PST)
Date: Thu, 5 Jan 2017 23:11:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Message-ID: <20170105201153.GA27928@node.shutemov.name>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
 <20161227015413.187403-30-kirill.shutemov@linux.intel.com>
 <5a3dcc25-b264-37c7-c090-09981b23940d@intel.com>
 <20170105192910.q26ozg4ci4i3j2ai@black.fi.intel.com>
 <161ece66-fbf4-cb89-3da6-91b4851af69f@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <161ece66-fbf4-cb89-3da6-91b4851af69f@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Thu, Jan 05, 2017 at 11:39:16AM -0800, Dave Hansen wrote:
> On 01/05/2017 11:29 AM, Kirill A. Shutemov wrote:
> > On Thu, Jan 05, 2017 at 11:13:57AM -0800, Dave Hansen wrote:
> >> On 12/26/2016 05:54 PM, Kirill A. Shutemov wrote:
> >>> MM would use min(RLIMIT_VADDR, TASK_SIZE) as upper limit of virtual
> >>> address available to map by userspace.
> >>
> >> What happens to existing mappings above the limit when this upper limit
> >> is dropped?
> > 
> > Nothing: we only prevent creating new mappings. All existing are not
> > affected.
> > 
> > The semantics here the same as with other resource limits.
> > 
> >> Similarly, why do we do with an application running with something
> >> incompatible with the larger address space that tries to raise the
> >> limit?  Say, legacy MPX.
> > 
> > It has to know what it does. Yes, it can change limit to the point where
> > application is unusable. But you can to the same with other limits.
> 
> I'm not sure I'm comfortable with this.  Do other rlimit changes cause
> silent data corruption?  I'm pretty sure doing this to MPX would.

Maybe it's too ugly, but MPX can set rlim_max to rlim_cur on enabling.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
