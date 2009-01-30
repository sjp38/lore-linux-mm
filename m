Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CEA996B0083
	for <linux-mm@kvack.org>; Fri, 30 Jan 2009 16:10:38 -0500 (EST)
Subject: Re: marching through all physical memory in software
From: Nigel Cunningham <ncunningham-lkml@crca.org.au>
Reply-To: ncunningham-lkml@crca.org.au
In-Reply-To: <m1wscc7fop.fsf@fess.ebiederm.org>
References: <715599.77204.qm@web50111.mail.re2.yahoo.com>
	 <m1wscc7fop.fsf@fess.ebiederm.org>
Content-Type: text/plain
Date: Sat, 31 Jan 2009 08:10:58 +1100
Message-Id: <1233349858.11332.14.camel@nigel-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Doug Thompson <norsk5@yahoo.com>, Pavel Machek <pavel@suse.cz>, Chris Friesen <cfriesen@nortel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bluesmoke-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hi.

On Fri, 2009-01-30 at 11:32 -0800, Eric W. Biederman wrote:
> Doug Thompson <norsk5@yahoo.com> writes:
> 
> > Nigel Cunningham <ncunningham-lkml@crca.org.au> wrote:
> >
> >     Hi again.
> >
> >     On Fri, 2009-01-30 at 10:13 +0100, Pavel Machek wrote:
> >     > > Hi.
> >     > >
> >     > > On Wed, 2009-01-28 at 20:38 +0100, Pavel Machek wrote:
> >     > > > You can do the scrubbing today by echo reboot > /sys/power/disk; echo
> >     > > > disk > /sys/power/state :-)... or using uswsusp APIs.
> >     > >
> >     > > That won't work. The RAM retains its contents across a reboot, and even
> >     > > for a little while after powering off.
> >     >
> >     > Yes, and the original goal was to rewrite all the memory with same
> >     > contents so that parity errors don't accumulate. SO scrubbing here !=
> >     > trying to clear it.
> >
> >     Sorry - I think I missed something.
> >
> >     AFAICS, hibernating is going to be a noop as far as doing anything to
> >     memory that's not touched by the process of hibernating goes. It won't
> >     clear it or scrub it or anything else.
> 
> A background software scrubber simply has the job of rewritting memory
> to it's current content so that the data and the ecc check bits are
> guaranteed to be in sync keeping correctable ecc errors caused by
> environmental factors from accumulating.
> 
> Pavel's original comment was that the hibernation code has to walk all
> of memory to save it to disk so it would be a good place to look to
> figure out how to walk all of memory.  And incidentally hibernation
> would serve as a crud way of rewritting all of memory.

Thanks. Now I get it :)

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
