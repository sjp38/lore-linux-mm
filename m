From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.5.74-mm1
Date: Mon, 7 Jul 2003 14:24:06 +0200
References: <20030703023714.55d13934.akpm@osdl.org> <200307060414.34827.phillips@arcor.de> <Pine.LNX.4.53.0307071042470.743@skynet>
In-Reply-To: <Pine.LNX.4.53.0307071042470.743@skynet>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200307071424.06393.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Jamie Lokier <jamie@shareable.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 07 July 2003 12:00, Mel Gorman wrote:
> On Sun, 6 Jul 2003, Daniel Phillips wrote:
> > > > What are you going to do if you have one
> > > > application you want to take priority, re-nice the other 50?
> > >
> > > Is that effective?  It might be just the trick.
> >
> > Point.
>
> Alternatively, how about using PAM to grant the CAP_SYS_NICE capability to
> known interactive users that require it. Presumably the number of users
> that require it is very small (in the case of the music player, only one)
> so it wouldn't be a major security issue.

And set up distros to grant it by default.  Yes.

The problem I see is that it lets user space priorities invade the range of 
priorities used by root processes.  What's really needed is a range of 
negative priorities available to normal users that are not normally used by 
root.

In retrospect, the idea of renicing all the applications but the realtime one  
doesn't work, because it doesn't take care of applications started 
afterwards. 

> There is something along these lines at http://www.pamcap.org but it
> requires some patching to the kernel (only available against 2.4.18
> currently) to inherit capabilities across exec and, from what I gather at
> a quick glance, to allow capabilities to be set for a process group.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
