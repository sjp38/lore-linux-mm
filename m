Message-ID: <4147936B.5080500@yahoo.com.au>
Date: Wed, 15 Sep 2004 10:57:15 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] shrink per_cpu_pages to fit 32byte cacheline
References: <20040913233835.GA23894@logos.cnet> <1095142204.2698.12.camel@laptop.fenrus.com> <20040914093407.GA23935@logos.cnet> <20040914111329.GB21362@devserv.devel.redhat.com> <20040914100152.GB23935@logos.cnet> <20040914114412.GC21362@devserv.devel.redhat.com> <20040914224555.GA714@logos.cnet>
In-Reply-To: <20040914224555.GA714@logos.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Arjan van de Ven <arjanv@redhat.com>, akpm@osdl.org, "Martin J. Bligh" <mbligh@aracnet.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:

>>some version of that; I can't find it in my current one though. Hrmpf
>>Maybe there's someone from intel or amd on this list who can confirm the
>>performance impact of the 0x66 operand size override prefix
> 
> 
> Prefix "data16" I see... Well it doesnt seem anyone really familiar with this 
> is part of the list - who you think would be sure about this?
> 
> Jun Nakajima maybe? 
> 
> We need to be sure because we've just done for pagevec's.

You could leave them as ints, and just make the size of the pagevec
14 on 32-bit archs and 15 on 64-bit ones.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
