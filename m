Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id TAA01432
	for <linux-mm@kvack.org>; Mon, 21 Oct 2002 19:24:54 -0700 (PDT)
Message-ID: <3DB4B6F4.9488F283@digeo.com>
Date: Mon, 21 Oct 2002 19:24:52 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.44-mm2 compile error using gcc 3.2 (gcc 2.96 works fine).
References: <3DB48BE7.A044FDE0@digeo.com> <1035252853.9472.45.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Steven Cole wrote:
> 
> > Are you using "nmi_watchdog=1"?
> >
> 
> Nope.  My understanding is that is only applicable for SMP systems, but
> I can add that to the lilo.conf append line if it would do any good on
> this troublesome UP box.

It should still work OK if you have the IO-APIC enabled.  

Running an SMP kernel on UP sometimes will catch deadlocks
which a UP build would miss.  But in this case, it might
make it go away - your SMP box is unaffected.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
