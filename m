Date: Sat, 16 Feb 2002 14:32:20 +0200 (SAST)
From: Zwane Mwaikambo <zwane@linux.realnet.co.sz>
Subject: Re: __pa() vs. virt_to_phys()
In-Reply-To: <3C6ACC76.6A3D3A36@scs.ch>
Message-ID: <Pine.LNX.4.44.0202161430430.23877-100000@netfinity.realnet.co.sz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Maletinsky <maletinsky@scs.ch>
Cc: KernelNewbies <kernelnewbies@nl.linux.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Feb 2002, Martin Maletinsky wrote:

> Hi,
> 
> Is there any reason to use __pa() rather than virt_to_phys() or vice versa?
> 
> On i386 virt_to_phys() is just a function that returns the value returned by __pa(); on Alpha virt_to_phys() is a function that subtracts IDENT_ADDR from the argument,
> whereas __pa() is a macro that subtracts PAGE_OFFSET from its argument - however PAGE_OFFSET and IDENT_ADDR expand to the same value; on Sparc virt_to_phys() is a macro
> that expands to __pa().
> 
> So the two things look to be pretty much the same on different platforms - is there any reason
> for having __pa() as well as virt_to_phys(), and which one is to be used by device drivers?

Try not to use the underlying calls directly, they may change under you, 
although these seem less likely, IOW use the API given to you.

Regards,
	Zwane Mwaikambo


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
