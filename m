Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AAF5B6B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 18:35:56 -0400 (EDT)
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
 do?
From: Kevin Fox <Kevin.Fox@pnl.gov>
In-Reply-To: <20090314081207.GA16436@elte.hu>
References: <1236891719.32630.14.camel@bahia>
	 <20090312212124.GA25019@us.ibm.com>
	 <604427e00903122129y37ad791aq5fe7ef2552415da9@mail.gmail.com>
	 <20090313053458.GA28833@us.ibm.com>
	 <alpine.LFD.2.00.0903131018390.3940@localhost.localdomain>
	 <20090313193500.GA2285@x200.localdomain>
	 <alpine.LFD.2.00.0903131401070.3940@localhost.localdomain>
	 <1236981097.30142.251.camel@nimitz><49BADAE5.8070900@cs.columbia.edu>
	 <m1hc1xrlt5.fsf@fess.ebiederm.org>  <20090314081207.GA16436@elte.hu>
Content-Type: text/plain
Date: Mon, 16 Mar 2009 15:33:28 -0700
Message-Id: <1237242808.23841.38.camel@sledge.emsl.pnl.gov>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, mpm@selenic.com, linux-mm@kvack.org, tglx@linutronix.de, viro@zeniv.linux.org.uk, linux-api@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Sat, 2009-03-14 at 01:12 -0700, Ingo Molnar wrote:
> 
> * Eric W. Biederman <ebiederm@xmission.com> wrote:
> 
> > >> In the OpenVZ case, they've at least demonstrated that the
> > >> filesystem can be moved largely with rsync.  Unlinked files
> > >> need some in-kernel TLC (or /proc mangling) but it isn't
> > >> *that* bad.
> > >
> > > And in the Zap we have successfully used a log-based
> > > filesystem (specifically NILFS) to continuously snapshot the
> > > file-system atomically with taking a checkpoint, so it can
> > > easily branch off past checkpoints, including the file
> > > system.
> > >
> > > And unlinked files can be (inefficiently) handled by saving
> > > their full contents with the checkpoint image - it's not a
> > > big toll on many apps (if you exclude Wine and UML...). At
> > > least that's a start.
> >
> > Oren we might want to do a proof of concept implementation
> > like I did with network namespaces.  That is done in the
> > community and goes far enough to show we don't have horribly
> > nasty code.  The patches and individual changes don't need to
> > be quite perfect but close enough that they can be considered
> > for merging.
> >
> > For the network namespace that seems to have made a big
> > difference.
> >
> > I'm afraid in our clean start we may have focused a little too
> > much on merging something simple and not gone far enough on
> > showing that things will work.
> >
> > After I had that in the network namespace and we had a clear
> > vision of the direction.  We started merging the individual
> > patches and things went well.
> 
> I'm curious: what is the actual end result other than good
> looking code? In terms of tangible benefits to the everyday
> Linux distro user. [This is not meant to be sarcastic, i'm
> truly curious.]

>From an ordinary user perspective, I hate loosing my desktop state every
time there is a power bump or a new kernel/video driver comes down from
the distro provider. Some of the stuff I loose:
*All my terminals
    *many tabs and windows
    *each in a different directory
    *vi
       *which files I was editing
       *which function I was coding
    *screen
    *scrollback buffer's contents
         *history for debugging code
    *command line arguments
*State of running apps
    *web browser
        *Tabs, yes it saves urls on crash, but sometimes the page cant
come back up (say, because of a form)
        *where the windows are on the desktop
    *evolution
        *what folder is selected
        *which message within the folder is selected
    *rhythmbox
    *misc other apps

Being able to reboot and get back to exactly where I was before the
reboot would save me a lot of time restarting apps and getting my
desktop back to where it was before the reboot. I'd also be more
inclined to reboot to get security updates more frequently if I didn't
loose track of what I was doing in the session, making machines more
secure in the process.

Kevin

PS: Yes, I know both GNOME and KDE have tried to deal with some of this
with their session manager stuff, but it doesn't restore everything and
only supported by some apps. It would probably take more work to get all
apps working with the session management stuff then supporting kernel
C/R.

>         Ingo
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
