Date: Thu, 6 Jan 2005 15:58:30 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: page migration patchset
Message-ID: <20050106235830.GE9636@holomorphy.com>
References: <Pine.LNX.4.44.0501052008160.8705-100000@localhost.localdomain> <41DC7EAD.8010407@mvista.com> <20050106144307.GB59451@muc.de> <41DDCD2B.4060709@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41DDCD2B.4060709@mvista.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Longerbeam <stevel@mvista.com>
Cc: Andi Kleen <ak@muc.de>, Hugh Dickins <hugh@veritas.com>, Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Marcello Tosatti <marcelo.tosatti@cyclades.com>, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, andrew morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
>> You need lazy hugetlbfs to use it (= allocate at page fault time,
>> not mmap time). Otherwise the policy can never be applied. I implemented 
>> my own version of lazy allocation for SLES9, but when I wanted to 
>> merge it into mainline some other people told they had a much better 
>> singing&dancing lazy hugetlb patch. So I waited for them, but they 
>> never went forward with their stuff and their code seems to be dead
>> now. So this is still a dangling end :/
>> If nothing happens soon regarding the "other" hugetlb code I will
>> forward port my SLES9 code. It already has NUMA policy support.
>> For now you can remove the hugetlb policy code from mainline if you
>> want, it would be easy to readd it when lazy hugetlbfs is merged.

On Thu, Jan 06, 2005 at 03:43:39PM -0800, Steve Longerbeam wrote:
> if you don't mind I'd like to. Sounds as if lazy hugetlbfs would be
> able to make use of the generic file mapping->policy instead of a
> hugetlb-specific policy anyway. Same goes for shmem.

If Andi's comments refer to my work, it already got permavetoed.

Anyway, using the vma's is a minor change. Please include this as a
patch separate from other changes (fault handling, consolidations, etc.)


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
