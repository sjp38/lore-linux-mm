Message-ID: <41DDCD2B.4060709@mvista.com>
Date: Thu, 06 Jan 2005 15:43:39 -0800
From: Steve Longerbeam <stevel@mvista.com>
MIME-Version: 1.0
Subject: Re: page migration patchset
References: <Pine.LNX.4.44.0501052008160.8705-100000@localhost.localdomain> <41DC7EAD.8010407@mvista.com> <20050106144307.GB59451@muc.de>
In-Reply-To: <20050106144307.GB59451@muc.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Hugh Dickins <hugh@veritas.com>, Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Marcello Tosatti <marcelo.tosatti@cyclades.com>, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, andrew morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

>On Wed, Jan 05, 2005 at 03:56:29PM -0800, Steve Longerbeam wrote:
>  
>
>>Hugetlbfs is also defining its own shared policy RB tree in its
>>inode info struct, but it doesn't seem to be used, just initialized
>>and freed at alloc/destroy inode time. Does anyone know why that
>>is there? A place-holder for future hugetlbfs mempolicy support?
>>If so, it can be removed and use the generic_file policies instead.
>>    
>>
>
>You need lazy hugetlbfs to use it (= allocate at page fault time,
>not mmap time). Otherwise the policy can never be applied. I implemented 
>my own version of lazy allocation for SLES9, but when I wanted to 
>merge it into mainline some other people told they had a much better 
>singing&dancing lazy hugetlb patch. So I waited for them, but they 
>never went forward with their stuff and their code seems to be dead
>now. So this is still a dangling end :/
>
>If nothing happens soon regarding the "other" hugetlb code I will
>forward port my SLES9 code. It already has NUMA policy support.
>
>For now you can remove the hugetlb policy code from mainline if you
>want, it would be easy to readd it when lazy hugetlbfs is merged.
>  
>

if you don't mind I'd like to. Sounds as if lazy hugetlbfs would be able to
make use of the generic file mapping->policy instead of a hugetlb-specific
policy anyway. Same goes for shmem.

Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
