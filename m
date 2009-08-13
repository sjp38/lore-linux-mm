Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A459C6B004F
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 11:26:28 -0400 (EDT)
Date: Thu, 13 Aug 2009 08:26:36 -0700
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
	slot is freed)
Message-ID: <20090813152636.GB13559@linux.intel.com>
References: <200908122007.43522.ngupta@vflare.org> <Pine.LNX.4.64.0908122312380.25501@sister.anvils> <20090813151312.GA13559@linux.intel.com> <alpine.DEB.2.00.0908130815450.30426@asgard.lang.hm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0908130815450.30426@asgard.lang.hm>
Sender: owner-linux-mm@kvack.org
To: david@lang.hm
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 13, 2009 at 08:17:34AM -0700, david@lang.hm wrote:
> On Thu, 13 Aug 2009, Matthew Wilcox wrote:
>
>> So TRIM isn't free, and there's a better way for the drive to find
>> out that the contents of a block no longer matter -- write some new
>> data to it.  So if we just swapped a page in, and we're going to swap
>> something else back out again soon, just write it to the same location
>> instead of to a fresh location.  You've saved a command, and you've
>> saved the drive some work, plus you've allowed other users to continue
>> accessing the drive in the meantime.
>
> on the other hand, if you then end up swapping the page you read in out  
> again and haven't dirtied it, you now have to actually write it as 
> opposed to just throwing it away (knowing that you already have a copy of 
> it stored on the swap device)

This is true, but at the point where you call discard, you will also
have to write it again.  My point was about delaying calls to discard,
rather than moving the point, or changing the circumstances under which
one calls discard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
