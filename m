From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14282.59712.315181.783541@dukat.scot.redhat.com>
Date: Mon, 30 Aug 1999 21:27:44 +0100 (BST)
Subject: Re: accel handling
In-Reply-To: <Pine.LNX.4.10.9908301313300.5070-100000@imperial.edgeglobal.com>
References: <14282.43218.149092.491404@dukat.scot.redhat.com>
	<Pine.LNX.4.10.9908301313300.5070-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 30 Aug 1999 13:51:14 -0400 (EDT), James Simmons
<jsimmons@edgeglobal.com> said:

> Then the question is how are DRI handling this. I'm assuming they don't
> allow access to the framebuffer. 

They have to allow framebuffer access, to support software fallback if
the hardware doesn't do complete open-GL in silicon.  For functions
which the hardware won't do, the software needs to be able to get its
own hands dirty, and it is the same user-space library which is doing
both the accelerated and the raw bits of the job.

> Then it looks like the best solution not allow any accels when you
> have /dev/fb mmapped. Then their still the problem of fbcon drivers
> that use accels to do drawing operations.

Exactly.

>  What if the user is writing to the framebuffer device while a accel
> is being processed in the kernel. It locks the machine hard. 

Then you need to trust any libs/binaries which you give framebuffer
access to.

> I know from personal experience with the matrox framebuffer
> device. One in ten times of starting X it locks my machine and I have
> to reboot. This problem needs to be solved and its no longer a PC
> problem when this kind of hardware can now run on SPARCs and PPC. 

it needs to be solved, yes.  In hardware.  Moan at your vendor. :)

> Right, you have to empty the accel queue at each frame refresh. Faster
> than that would be pointless. Slower than that would be really bad.

It depends on the speed of the queue.  If your video throughput is
bottlenecked on the accel queue, then you do want to be emptying it as
fast as possible to avoid idling the silicon.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
