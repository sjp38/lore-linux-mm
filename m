Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 69103600762
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 08:16:17 -0500 (EST)
Date: Wed, 2 Dec 2009 21:15:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 14/24] HWPOISON: return 0 if page is assured to be
	isolated
Message-ID: <20091202131554.GB13277@localhost>
References: <20091202031231.735876003@intel.com> <20091202043045.394560341@intel.com> <20091202124730.GB18989@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091202124730.GB18989@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 02, 2009 at 08:47:30PM +0800, Andi Kleen wrote:
> On Wed, Dec 02, 2009 at 11:12:45AM +0800, Wu Fengguang wrote:
> > Introduce hpc.page_isolated to record if page is assured to be
> > isolated, ie. it won't be accessed in normal kernel code paths
> > and therefore won't trigger another MCE event.
> > 
> > __memory_failure() will now return 0 to indicate that page is
> > really isolated.  Note that the original used action result
> > RECOVERED is not a reliable criterion.
> > 
> > Note that we now don't bother to risk returning 0 for the
> > rare unpoison/truncated cases.
> 
> That's the only user of the new hwpoison_control structure right?
> I think I prefer for that single bit to extend the return values
> and keep the arguments around. structures are not nice to read.

Easier to read but harder to extend.  I saw Haicheng add some debug
bits to hwpoison_control to collect debug info ;)

> I'll change the code.

I originally introduce "struct hwpoison_control" to collect more info
(like data_recoverable) and to dump them via uevent. Then we decide to
drop them unless there comes explicit user demands..

In its current form, it does seem more clean to do without hwpoison_control.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
