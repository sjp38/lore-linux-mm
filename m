From: Jeremy Hall <jhall@maoz.com>
Message-Id: <200304130350.h3D3o8pn031108@sith.maoz.com>
Subject: Re: 2.5.67-mm2
In-Reply-To: <20030413031440.GA14357@holomorphy.com> from William Lee Irwin III
 at "Apr 12, 2003 08:14:40 pm"
Date: Sat, 12 Apr 2003 23:50:08 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Jeremy Hall <jhall@maoz.com>, Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>, Andrew Morton <akpm@digeo.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

well I guess I could step through one thing at a time, n, because I DO get 
an initial trap it comes as soon as cpus are brought up

but that would take a long time and I'm sure there's LOTS of code.

_J

In the new year, William Lee Irwin III wrote:
> On Sat, Apr 12, 2003 at 11:03:46PM -0400, Jeremy Hall wrote:
> > I dunno about that, but mm2 locks in the boot process and doesn't display 
> > anything to me through gdb even though it is supposed to.  I have gdb 
> > console=gdb but that doesn't make the messages flow.
> 
> An early printk patch (any of the several going around) may give you an
> idea of where it's barfing.
> 
> 
> -- wli
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
