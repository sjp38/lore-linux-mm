Date: Wed, 27 Jun 2001 07:09:14 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: VM tuning through fault trace gathering [with actual code]
In-Reply-To: <m2vgljb6ao.fsf@boreas.yi.org.>
Message-ID: <Pine.LNX.4.21.0106270707550.1291-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fremlin <vii@users.sourceforge.net>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


On 26 Jun 2001, John Fremlin wrote:

> Marcelo Tosatti <marcelo@conectiva.com.br> writes:
> 
> > ####################################################################
> > Event     	          Time                   PID     Length Description
> > ####################################################################
> > 
> > Trap entry              991,299,585,597,016     678     12      TRAP: page fault; EIP : 0x40067785
> 
> That looks like just the generic interrupt handling. It does not do
> what I want to do, i.e. record some more info about the fault saying
> where it comes from.

You can create custom events with LTT and then you can get them from a
"big buffer" to userlevel later, then. 

I just told you about LTT because I think you are redoing work by creating
the tracing facilities... 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
