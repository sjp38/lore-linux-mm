Date: Tue, 09 Apr 2002 07:34:09 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: Fwd: Re: How CPU(x86) resolve kernel address
Message-ID: <1979206818.1018337648@[10.10.2.3]>
In-Reply-To: <Pine.GSO.4.10.10204091052060.13298-100000@mailhub.cdac.ernet.in>
References: <Pine.GSO.4.10.10204091052060.13298-100000@mailhub.cdac.ernet.in
 >
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sanket Rathi <sanket.rathi@cdac.ernet.in>, Ravi <kravi26@yahoo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>                 phyAddress = pte_page(*pte) ;
> ...
> where virtAddress is the address i passed from application so every time
> phyAddress i got is start with somthing like (C1081234) which is actually
> a kernel address space. why it is like so.

I don't think pte_page does what you think it does:

#define pte_page(x)     (mem_map+((unsigned long)(((x).pte_low
>>PAGE_SHIFT))))

seems to return the address of the struct page for that physaddr,
not the physaddr itself. pte.pte_low might be closer to what you
want, but as has been pointed out already, that's not accurate if 
it's been swapped out.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
