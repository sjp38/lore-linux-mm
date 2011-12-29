Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id B77466B00B5
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 10:58:42 -0500 (EST)
Received: by obcwo8 with SMTP id wo8so12258140obc.14
        for <linux-mm@kvack.org>; Thu, 29 Dec 2011 07:58:41 -0800 (PST)
Date: Thu, 29 Dec 2011 07:58:36 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: memblock and bootmem problems if start + size = 4GB
Message-ID: <20111229155836.GB3516@google.com>
References: <4EEF42F5.7040002@monstr.eu>
 <20111219162835.GA24519@google.com>
 <4EF05316.5050803@monstr.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EF05316.5050803@monstr.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Simek <monstr@monstr.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Sam Ravnborg <sam@ravnborg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hello,

On Tue, Dec 20, 2011 at 10:19:18AM +0100, Michal Simek wrote:
> >Yeah, that's an inherent problem in using [) ranges but I think
> >chopping off the last page probably is simpler and more robust
> >solution.  Currently, memblock_add_region() would simply ignore if
> >address range overflows but making it just ignore the last page is
> >several lines of addition.  Wouldn't that be effective enough while
> >staying very simple?
> 
> The main problem is with PFN_DOWN/UP macros and it is in __init section.
> The result will be definitely u32 type (for 32bit archs) anyway and seems to me
> better solution than ignoring the last page.

Other than being able to use one more 4k page, is there any other
benefit?  Maybe others had different experiences but in my exprience
trying to extend range coverages - be it stack top/end pointers,
address ranges or whatnot - using [] ranges or special flag usually
ended up adding complexity while adding almost nothing tangible.  On
extreme cases, people even carry separate valid flag to use %NULL as
valid address, which is pretty silly, IMHO.  So, unless there's some
benefit that I'm missing, I still think it's an overkill.  It's more
complex and difficult to test and verify.  Why bother for a single
page?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
