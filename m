Date: Fri, 7 Feb 2003 09:11:15 -0500
From: Daniel Jacobowitz <dan@debian.org>
Subject: Re: 2.5.59-mm9
Message-ID: <20030207141114.GA31151@nevyn.them.org>
References: <20030207013921.0594df03.akpm@digeo.com> <20030207030350.728b4618.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030207030350.728b4618.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 07, 2003 at 03:03:50AM -0800, Andrew Morton wrote:
> Andrew Morton <akpm@digeo.com> wrote:
> >
> > http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-mm9/
> 
> I've taken this down.
> 
> Ingo, there's something bad in the signal changes in Linus's current tree.
> 
> mozilla won't display, and is unkillable:

Yeah, I'm seeing hangs in rt_sigsuspend under GDB also.  Thanks for
saying that they show up without ptrace; I hadn't been able to
reproduce them without it.

Something is causing realtime signals to drop.

-- 
Daniel Jacobowitz
MontaVista Software                         Debian GNU/Linux Developer
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
