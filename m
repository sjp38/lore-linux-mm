Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 70B386B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 02:16:56 -0400 (EDT)
Subject: Re: Oops in VMA code
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1308204171.2516.65.camel@pasglop>
References: <47FAB15C-B113-40FD-9CE0-49566AACC0DF@suse.de>
	 <BANLkTimubRW2Az2MmRbgV+iTB+s6UEF5-w@mail.gmail.com>
	 <CDE289EC-7844-48E1-BB6A-6230ADAF6B7C@suse.de>
	 <1308204171.2516.65.camel@pasglop>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 16 Jun 2011 16:16:51 +1000
Message-ID: <1308205011.2516.66.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Graf <agraf@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>

On Thu, 2011-06-16 at 16:02 +1000, Benjamin Herrenschmidt wrote:
> On Thu, 2011-06-16 at 07:32 +0200, Alexander Graf wrote:
> > On 16.06.2011, at 06:32, Linus Torvalds wrote:
> 
> > Thanks a lot for looking at it either way :).
> 
> Yeah thanks ;-) Let me see what I can dig out.
> 
> First it's a load from what looks like a valid pointer to the linear
> mapping that had one byte corrupted (or more but it looks reasonably
> "clean"). It's not a one bit error, there's at least 2 bad bits (the
> 09):
> 
> DAR: c00090026236bbc0
> 
> Alex, how much RAM do you have ? If that was just a one byte corruption,
> the above would imply you have something valid between 9 and 10G. From
> the look of other registers, it seems that it could be a genuine pointer
> with just that stay "09" byte that landed onto it.

90 actually...

Anyways, doesn't tell us much more.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
