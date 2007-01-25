Date: Wed, 24 Jan 2007 22:47:58 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Limit the size of the pagecache
In-Reply-To: <6d6a94c50701242235m48013856kb5a947c489d9da37@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0701242243080.14597@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
 <45B75208.90208@linux.vnet.ibm.com>  <Pine.LNX.4.64.0701240655400.9696@schroedinger.engr.sgi.com>
  <45B82F41.9040705@linux.vnet.ibm.com> <6d6a94c50701242235m48013856kb5a947c489d9da37@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aubrey Li <aubreylee@gmail.com>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Robin Getz <rgetz@blackfin.uclinux.org>, "Hennerich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jan 2007, Aubrey Li wrote:

> But Vaidy - even with your patch, we are still using the existing
> reclaimer, that means we dont ensure that only page cache is
> reclaimed/limited. mapped pages will be hit also.
> I think we still need to add a new scancontrol field to lock mmaped
> pages and remove unmapped pagecache pages only.

Setting sc->swappiness to zero will make the reclaimer hit 
unmapped pages until we get into problems. Maybe set that to some negative 
value to avoid reclaim_mapped being set to 1 in shrink_active_list?

Oh. But reclaim_mapped is staying at zero anyways if may_swap is off. So 
we are already fine.

I still wonder why you are doing this at all. If you just run your own app 
on the box then preallocate your higher order allocations from user space. 
Much less trouble.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
