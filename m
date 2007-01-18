From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Thu, 18 Jan 2007 17:22:12 +1100 (EST)
Subject: Re: [PATCH 0/29] Page Table Interface Explanation
In-Reply-To: <Pine.LNX.4.64.0701161048450.30540@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0701181701320.12779@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.64.0701161048450.30540@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Paul Davies <pauld@gelato.unsw.edu.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Jan 2007, Christoph Lameter wrote:

> I am glad to see that this endeavor is still going forward.
I will be working hard to make this happen over the coming period
of time.  I will take your feedback, talk to my colleagues, and
come up with a new version after LCA.

>> 		unsigned long new_addr, unsigned long len);
>
> Why do we need so many individual specialized iterators? Isnt there some
> way to have a common iterator function?
Yes - and this is the intention.  However, I thought that it might
be easier to get the page table interface into the kernel by doing
it in stages.

I was worried a common iterator function represented too much change
too quickly.

Cheers

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
