Date: Wed, 1 Feb 2006 09:03:15 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [discuss] Memory performance problems on Tyan VX50
In-Reply-To: <200602011539.40368.ak@suse.de>
Message-ID: <Pine.LNX.4.62.0602010900200.16613@schroedinger.engr.sgi.com>
References: <43DF7654.6060807@t-platforms.ru> <200601311223.11492.raybry@mpdtxmail.amd.com>
 <43E0B8FE.8040803@t-platforms.ru> <200602011539.40368.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: discuss@x86-64.org, Andrey Slepuhin <pooh@t-platforms.ru>, Ray Bryant <raybry@mpdtxmail.amd.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, 1 Feb 2006, Andi Kleen wrote:

> Looks like a bug. There were changes both in the page allocator and in
> mempolicy in 2.6.16rc, so it might be related to that.
> What does this wheremem program do exactly?
> And what does numastat --hardware say on the machine?
> 
> Either it's generally broken in page alloc or mempolicy somehow managed to pass in
> a NULL zonelist. 

The failure is in __rmqueue. AFAIK There is no influence of mempolicy on 
that one. Could we get an accurate pointer to the statement that is 
causing the NULL deref?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
