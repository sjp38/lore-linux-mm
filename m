Date: Wed, 29 Sep 1999 20:23:00 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: mm->mmap_sem
In-Reply-To: <Pine.LNX.4.10.9909292012290.31287-100000@imperial.edgeglobal.com>
Message-ID: <Pine.LNX.3.96.990929201805.6780A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcus Sundberg <erammsu@kieray1.p.y.ki.era.ericsson.se>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Sep 1999, James Simmons wrote:

> On Thu, 30 Sep 1999, Stephen C. Tweedie wrote:
> 
> > Hi,
> > 
> > On Mon, 27 Sep 1999 15:31:28 -0400 (EDT), James Simmons
> > <jsimmons@edgeglobal.com> said:
> > 
> > > What are all the broken cards out their? I was reading my old Matrox
> > > Millenium I docs and even that card supports similutaneous access to 
> > > the accel engine and framebuffer. If the number of cards that are that
> > > broken are small then I just will not support them.
> > 
> > I think that there's a large number of them.  The XI and XFree86 folk
> > would probably know which ones exactly.
> 
> Yikes. I think the best solution is to just put the process that owns
> the framebuffer to be put to sleep just before accel engine access. Wake
> it up once its done. Some fancy scheduling tricks should do it. I have it
> setup now that accels used internal in the kernel to speed up console
> rendering will not work when /dev/fb is mmapped. Also I have set it up so
> only one process can open /dev/fb at a time. This makes life much easier.

No, same problem.  You can't put a process to sleep without
inter-processor interrupts on smp if its not running currently.  You can't
allow the kernel to touch the frame buffer if the user is using the
accelerator or vice-versa.  Have an ioctl to lock the kernel out from
updating, and only unlock it from user space when there's no activity for
a while.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
