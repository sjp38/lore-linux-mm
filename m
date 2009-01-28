Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8E7846B005C
	for <linux-mm@kvack.org>; Fri, 30 Jan 2009 03:57:31 -0500 (EST)
Date: Wed, 28 Jan 2009 20:38:13 +0100
From: Pavel Machek <pavel@suse.cz>
Subject: Re: marching through all physical memory in software
Message-ID: <20090128193813.GD1222@ucw.cz>
References: <497DD8E5.1040305@nortel.com> <20090126075957.69b64a2e@infradead.org> <497F5289.404@nortel.com> <m1vds0bj2j.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m1vds0bj2j.fsf@fess.ebiederm.org>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Chris Friesen <cfriesen@nortel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, Doug Thompson <norsk5@yahoo.com>, linux-mm@kvack.org, bluesmoke-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue 2009-01-27 12:16:52, Eric W. Biederman wrote:
> "Chris Friesen" <cfriesen@nortel.com> writes:
> 
> > Arjan van de Ven wrote:
> >> On Mon, 26 Jan 2009 09:38:13 -0600
> >> "Chris Friesen" <cfriesen@nortel.com> wrote:
> >>
> >>> Someone is asking me about the feasability of "scrubbing" system
> >>> memory by accessing each page and handling the ECC faults.
> >>>
> >>
> >> Hi,
> >>
> >> I would suggest that you look at the "edac" subsystem, which tries to
> >> do exactly this....
> 
> 
> > edac appears to currently be able to scrub the specific page where the fault
> > occurred.  This is a useful building block, but doesn't provide the ability to
> > march through all of physical memory.
> 
> Well that is the tricky part.  The rest is simply finding which physical
> addresses are valid.  Either by querying the memory controller or looking
> at the range the BIOS gave us.
> 
> That part should not be too hard.  I think it simply has not been implemented
> yet as most ECC chipsets implement this in hardware today.

You can do the scrubbing today by echo reboot > /sys/power/disk; echo
disk > /sys/power/state :-)... or using uswsusp APIs.

Take a look at hibernation code for 'walk all memory' examples...  

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
