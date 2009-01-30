Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5E4C36B005C
	for <linux-mm@kvack.org>; Fri, 30 Jan 2009 04:13:06 -0500 (EST)
Date: Fri, 30 Jan 2009 10:13:04 +0100
From: Pavel Machek <pavel@suse.cz>
Subject: Re: marching through all physical memory in software
Message-ID: <20090130091304.GA9495@atrey.karlin.mff.cuni.cz>
References: <497DD8E5.1040305@nortel.com> <20090126075957.69b64a2e@infradead.org> <497F5289.404@nortel.com> <m1vds0bj2j.fsf@fess.ebiederm.org> <20090128193813.GD1222@ucw.cz> <1233306324.11332.11.camel@nigel-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1233306324.11332.11.camel@nigel-laptop>
Sender: owner-linux-mm@kvack.org
To: Nigel Cunningham <ncunningham-lkml@crca.org.au>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Chris Friesen <cfriesen@nortel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, Doug Thompson <norsk5@yahoo.com>, linux-mm@kvack.org, bluesmoke-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

> Hi.
> 
> On Wed, 2009-01-28 at 20:38 +0100, Pavel Machek wrote:
> > You can do the scrubbing today by echo reboot > /sys/power/disk; echo
> > disk > /sys/power/state :-)... or using uswsusp APIs.
> 
> That won't work. The RAM retains it's contents across a reboot, and even
> for a little while after powering off.

Yes, and the original goal was to rewrite all the memory with same
contents so that parity errors don't accumulate. SO scrubbing here !=
trying to clear it.


-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
