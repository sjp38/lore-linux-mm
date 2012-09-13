Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 817406B016E
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 15:32:14 -0400 (EDT)
Received: by dadi14 with SMTP id i14so2209639dad.14
        for <linux-mm@kvack.org>; Thu, 13 Sep 2012 12:32:13 -0700 (PDT)
Date: Thu, 13 Sep 2012 12:32:09 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: bootmem: use phys_addr_t for physical addresses
Message-ID: <20120913193209.GL7677@google.com>
References: <1347466008-7231-1-git-send-email-cyril@ti.com>
 <20120912203920.GU7677@google.com>
 <505123FE.2090305@ti.com>
 <20120913003400.GA25889@localhost>
 <50512B9A.9060905@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50512B9A.9060905@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyril Chemparathy <cyril@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, davem@davemloft.net, eric.dumazet@gmail.com, hannes@cmpxchg.org, shangw@linux.vnet.ibm.com, vitalya@ti.com

Hello, Cyril.

On Wed, Sep 12, 2012 at 08:40:58PM -0400, Cyril Chemparathy wrote:
> You probably missed the lowmem bit from my response?
> 
> This system has all of its memory outside the 4GB physical address
> space.  This includes lowmem, which is permanently mapped into the
> kernel virtual address space as usual.

Yeah, I understand that and as a short-term solution we maybe can add
a check to verify that the goal and limits are under lowmem and fail
with NULL if not, but it still is a broken interface and I'd rather
not mess with it when memblock is already there.  Converting to
memblock usually isn't too much work although it expectedly involves
some subtleties and fallouts for a while.

Do you recall what the problem was with sparsemem and memblock?  I
don't think I'll directly work on arm but I'll be happy to help on
memblock issues.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
