Subject: Re: VM tuning through fault trace gathering [with actual code]
References: <Pine.LNX.4.21.0106261031150.850-100000@freak.distro.conectiva>
From: John Fremlin <vii@users.sourceforge.net>
Date: 26 Jun 2001 16:38:07 +0100
In-Reply-To: <Pine.LNX.4.21.0106261031150.850-100000@freak.distro.conectiva> (Marcelo Tosatti's message of "Tue, 26 Jun 2001 10:52:16 -0300 (BRT)")
Message-ID: <m2vgljb6ao.fsf@boreas.yi.org.>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo@conectiva.com.br> writes:

> ####################################################################
> Event     	          Time                   PID     Length Description
> ####################################################################
> 
> Trap entry              991,299,585,597,016     678     12      TRAP: page fault; EIP : 0x40067785

That looks like just the generic interrupt handling. It does not do
what I want to do, i.e. record some more info about the fault saying
where it comes from.

-- 

	http://ape.n3.net
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
