Subject: Re: [PATCH] strict VM overcommit for stock 2.4
From: Robert Love <rml@tech9.net>
In-Reply-To: <Pine.LNX.4.30.0207181806220.30902-100000@divine.city.tvnet.hu>
References: <Pine.LNX.4.30.0207181806220.30902-100000@divine.city.tvnet.hu>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 18 Jul 2002 10:42:41 -0700
Message-Id: <1027014161.1086.123.camel@sinai>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szakacsits Szabolcs <szaka@sienet.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2002-07-18 at 09:36, Szakacsits Szabolcs wrote:

> This is what I would do first [make sure you don't hit any resource,
> malloc, kernel memory mapping, etc limits -- this is a simulation that
> must eat all available memory continually]:
> main(){void *x;while(1)if(x=malloc(4096))memset(x,666,4096);}
> 
> When the above used up all the memory try to ssh/login to the box as
> root and clean up the mess. Can you do it?

Three points:

- with strict overcommit and the "allocations must meet backing store"
rule (policy #3) the above can never use all physical memory

- if your point is that a rogue user can use all of the systems memory,
then you need per-user resource accounting.

- the point of this patch is to not use MORE memory than the system
has.  I say nothing else except that I am trying to avoid OOM and push
the allocation failures into the allocations themselves.  Assuming the
accounting is correct (and it seems to be) then Alan and I have
succeeded.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
