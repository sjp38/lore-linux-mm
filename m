Date: Wed, 7 May 2008 10:30:44 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 1/1] mm: add virt to phys debug
In-Reply-To: <4820D39E.3090109@gmail.com>
Message-ID: <Pine.LNX.4.64.0805071030180.3173@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0804281322510.31163@schroedinger.engr.sgi.com>
 <1209669740-10493-1-git-send-email-jirislaby@gmail.com>
 <Pine.LNX.4.64.0805011310390.9288@schroedinger.engr.sgi.com>
 <4820D39E.3090109@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Jeremy Fitzhardinge <jeremy@goop.org>, pageexec@freemail.hu, Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, herbert@gondor.apana.org.au, penberg@cs.helsinki.fi, akpm@linux-foundation.org, linux-ext4@vger.kernel.org, paulmck@linux.vnet.ibm.com, rjw@sisk.pl, zdenek.kabelac@gmail.com, David Miller <davem@davemloft.net>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Tue, 6 May 2008, Jiri Slaby wrote:

> I like the idea, I'll get back with a patch in few days (sorry, too busy).
> Anyway bounds.h should be include/asm/ thing though.

For arch specific stuff use asm-offsets.h. It would have to be included in 
page_xx.h.

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
