From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.5.74-mm1
Date: Sat, 5 Jul 2003 23:09:12 +0200
References: <20030703023714.55d13934.akpm@osdl.org> <200307051728.12891.phillips@arcor.de> <20030705121416.62afd279.akpm@osdl.org>
In-Reply-To: <20030705121416.62afd279.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200307052309.12680.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 05 July 2003 21:14, Andrew Morton wrote:
> Daniel Phillips <phillips@arcor.de> wrote:
> > The situation re scheduling in 2.5 feels much as
> > the vm situation did in 2.3
>
> I've been trying to avoid thinking about that comparison.
>
> I don't think it's really, really bad at present.  Just "should be a bit
> better".

Ever since I -niced Zinf a coupld of hours ago I haven't had a problem.  This 
is a fine way to handle the problem.  We're not dealing with an "interactive 
scheduling" problem here, it's simply realtime scheduling and needs to be 
treated as such.

Unfortunately, negative priority requires root privilege, at least on Debian.  
That's dumb.  By default, the root privilege requirement should kick in at 
something like -5 or -10, so  ordinary users can set priorities higher than 
the default, as well as lower.  For the millions of desktop users out there, 
sound ought to work by default, not be broken by default.

The "better" mechanism for sound scheduling is SCHED_RR, which requires root 
privilege for some reason that isn't clear to me.  Or maybe there once was a 
good reason, back in the days of the dinosaurs.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
