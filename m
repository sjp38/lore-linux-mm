Date: Tue, 26 Jun 2001 10:52:16 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: VM tuning through fault trace gathering [with actual code]
In-Reply-To: <m2n16vcsft.fsf@boreas.yi.org.>
Message-ID: <Pine.LNX.4.21.0106261031150.850-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fremlin <vii@users.sourceforge.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On 26 Jun 2001, John Fremlin wrote:

> Marcelo Tosatti <marcelo@conectiva.com.br> writes:
> 
> > On 25 Jun 2001, John Fremlin wrote:
> > 
> > > 
> > > Last year I had the idea of tracing the memory accesses of the system
> > > to improve the VM - the traces could be used to test algorithms in
> > > userspace. The difficulty is of course making all memory accesses
> > > fault without destroying system performance.
> 
> [...]
> 
> > Linux Trace Toolkit (http://www.opersys.com/LTT) does that. 
> 
> I dld the ltt-usenix paper and skim read it. It didn't seem to talk
> about page faults much. Where should I look?

Grab the source and try it out?

Example page fault trace: 

####################################################################
Event     	          Time                   PID     Length Description
####################################################################

Trap entry              991,299,585,597,016     678     12      TRAP: page fault; EIP : 0x40067785


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
