Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8834DC43140
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 08:50:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4210B20578
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 08:50:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4210B20578
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA3F66B0003; Fri,  6 Sep 2019 04:50:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C540D6B0006; Fri,  6 Sep 2019 04:50:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1C9E6B0007; Fri,  6 Sep 2019 04:50:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0131.hostedemail.com [216.40.44.131])
	by kanga.kvack.org (Postfix) with ESMTP id 8871F6B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 04:50:51 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 1E1D062DD
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 08:50:51 +0000 (UTC)
X-FDA: 75903875502.17.week16_7baf8eb982823
X-HE-Tag: week16_7baf8eb982823
X-Filterd-Recvd-Size: 13724
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 08:50:49 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7801F301A3E3;
	Fri,  6 Sep 2019 08:50:48 +0000 (UTC)
Received: from [10.36.117.162] (ovpn-117-162.ams2.redhat.com [10.36.117.162])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 38E31100194E;
	Fri,  6 Sep 2019 08:50:41 +0000 (UTC)
Subject: Re: [PATCH v2 1/7] mm/gup: Rename "nonblocking" to "locked" where
 proper
To: Peter Xu <peterx@redhat.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
 Jerome Glisse <jglisse@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>,
 Marty McFadden <mcfadden8@llnl.gov>, Shaohua Li <shli@fb.com>,
 Andrea Arcangeli <aarcange@redhat.com>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 Denis Plotnikov <dplotnikov@virtuozzo.com>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman
 <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>,
 "Dr . David Alan Gilbert" <dgilbert@redhat.com>
References: <20190905101534.9637-1-peterx@redhat.com>
 <20190905101534.9637-2-peterx@redhat.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 xsFNBFXLn5EBEAC+zYvAFJxCBY9Tr1xZgcESmxVNI/0ffzE/ZQOiHJl6mGkmA1R7/uUpiCjJ
 dBrn+lhhOYjjNefFQou6478faXE6o2AhmebqT4KiQoUQFV4R7y1KMEKoSyy8hQaK1umALTdL
 QZLQMzNE74ap+GDK0wnacPQFpcG1AE9RMq3aeErY5tujekBS32jfC/7AnH7I0v1v1TbbK3Gp
 XNeiN4QroO+5qaSr0ID2sz5jtBLRb15RMre27E1ImpaIv2Jw8NJgW0k/D1RyKCwaTsgRdwuK
 Kx/Y91XuSBdz0uOyU/S8kM1+ag0wvsGlpBVxRR/xw/E8M7TEwuCZQArqqTCmkG6HGcXFT0V9
 PXFNNgV5jXMQRwU0O/ztJIQqsE5LsUomE//bLwzj9IVsaQpKDqW6TAPjcdBDPLHvriq7kGjt
 WhVhdl0qEYB8lkBEU7V2Yb+SYhmhpDrti9Fq1EsmhiHSkxJcGREoMK/63r9WLZYI3+4W2rAc
 UucZa4OT27U5ZISjNg3Ev0rxU5UH2/pT4wJCfxwocmqaRr6UYmrtZmND89X0KigoFD/XSeVv
 jwBRNjPAubK9/k5NoRrYqztM9W6sJqrH8+UWZ1Idd/DdmogJh0gNC0+N42Za9yBRURfIdKSb
 B3JfpUqcWwE7vUaYrHG1nw54pLUoPG6sAA7Mehl3nd4pZUALHwARAQABzSREYXZpZCBIaWxk
 ZW5icmFuZCA8ZGF2aWRAcmVkaGF0LmNvbT7CwX4EEwECACgFAljj9eoCGwMFCQlmAYAGCwkI
 BwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEE3eEPcA/4Na5IIP/3T/FIQMxIfNzZshIq687qgG
 8UbspuE/YSUDdv7r5szYTK6KPTlqN8NAcSfheywbuYD9A4ZeSBWD3/NAVUdrCaRP2IvFyELj
 xoMvfJccbq45BxzgEspg/bVahNbyuBpLBVjVWwRtFCUEXkyazksSv8pdTMAs9IucChvFmmq3
 jJ2vlaz9lYt/lxN246fIVceckPMiUveimngvXZw21VOAhfQ+/sofXF8JCFv2mFcBDoa7eYob
 s0FLpmqFaeNRHAlzMWgSsP80qx5nWWEvRLdKWi533N2vC/EyunN3HcBwVrXH4hxRBMco3jvM
 m8VKLKao9wKj82qSivUnkPIwsAGNPdFoPbgghCQiBjBe6A75Z2xHFrzo7t1jg7nQfIyNC7ez
 MZBJ59sqA9EDMEJPlLNIeJmqslXPjmMFnE7Mby/+335WJYDulsRybN+W5rLT5aMvhC6x6POK
 z55fMNKrMASCzBJum2Fwjf/VnuGRYkhKCqqZ8gJ3OvmR50tInDV2jZ1DQgc3i550T5JDpToh
 dPBxZocIhzg+MBSRDXcJmHOx/7nQm3iQ6iLuwmXsRC6f5FbFefk9EjuTKcLMvBsEx+2DEx0E
 UnmJ4hVg7u1PQ+2Oy+Lh/opK/BDiqlQ8Pz2jiXv5xkECvr/3Sv59hlOCZMOaiLTTjtOIU7Tq
 7ut6OL64oAq+zsFNBFXLn5EBEADn1959INH2cwYJv0tsxf5MUCghCj/CA/lc/LMthqQ773ga
 uB9mN+F1rE9cyyXb6jyOGn+GUjMbnq1o121Vm0+neKHUCBtHyseBfDXHA6m4B3mUTWo13nid
 0e4AM71r0DS8+KYh6zvweLX/LL5kQS9GQeT+QNroXcC1NzWbitts6TZ+IrPOwT1hfB4WNC+X
 2n4AzDqp3+ILiVST2DT4VBc11Gz6jijpC/KI5Al8ZDhRwG47LUiuQmt3yqrmN63V9wzaPhC+
 xbwIsNZlLUvuRnmBPkTJwwrFRZvwu5GPHNndBjVpAfaSTOfppyKBTccu2AXJXWAE1Xjh6GOC
 8mlFjZwLxWFqdPHR1n2aPVgoiTLk34LR/bXO+e0GpzFXT7enwyvFFFyAS0Nk1q/7EChPcbRb
 hJqEBpRNZemxmg55zC3GLvgLKd5A09MOM2BrMea+l0FUR+PuTenh2YmnmLRTro6eZ/qYwWkC
 u8FFIw4pT0OUDMyLgi+GI1aMpVogTZJ70FgV0pUAlpmrzk/bLbRkF3TwgucpyPtcpmQtTkWS
 gDS50QG9DR/1As3LLLcNkwJBZzBG6PWbvcOyrwMQUF1nl4SSPV0LLH63+BrrHasfJzxKXzqg
 rW28CTAE2x8qi7e/6M/+XXhrsMYG+uaViM7n2je3qKe7ofum3s4vq7oFCPsOgwARAQABwsFl
 BBgBAgAPBQJVy5+RAhsMBQkJZgGAAAoJEE3eEPcA/4NagOsP/jPoIBb/iXVbM+fmSHOjEshl
 KMwEl/m5iLj3iHnHPVLBUWrXPdS7iQijJA/VLxjnFknhaS60hkUNWexDMxVVP/6lbOrs4bDZ
 NEWDMktAeqJaFtxackPszlcpRVkAs6Msn9tu8hlvB517pyUgvuD7ZS9gGOMmYwFQDyytpepo
 YApVV00P0u3AaE0Cj/o71STqGJKZxcVhPaZ+LR+UCBZOyKfEyq+ZN311VpOJZ1IvTExf+S/5
 lqnciDtbO3I4Wq0ArLX1gs1q1XlXLaVaA3yVqeC8E7kOchDNinD3hJS4OX0e1gdsx/e6COvy
 qNg5aL5n0Kl4fcVqM0LdIhsubVs4eiNCa5XMSYpXmVi3HAuFyg9dN+x8thSwI836FoMASwOl
 C7tHsTjnSGufB+D7F7ZBT61BffNBBIm1KdMxcxqLUVXpBQHHlGkbwI+3Ye+nE6HmZH7IwLwV
 W+Ajl7oYF+jeKaH4DZFtgLYGLtZ1LDwKPjX7VAsa4Yx7S5+EBAaZGxK510MjIx6SGrZWBrrV
 TEvdV00F2MnQoeXKzD7O4WFbL55hhyGgfWTHwZ457iN9SgYi1JLPqWkZB0JRXIEtjd4JEQcx
 +8Umfre0Xt4713VxMygW0PnQt5aSQdMD58jHFxTk092mU+yIHj5LeYgvwSgZN4airXk5yRXl
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <c25c5756-fd63-b8f6-4d67-d4506052891c@redhat.com>
Date: Fri, 6 Sep 2019 10:50:40 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190905101534.9637-2-peterx@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Fri, 06 Sep 2019 08:50:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05.09.19 12:15, Peter Xu wrote:
> There's plenty of places around __get_user_pages() that has a parameter
> "nonblocking" which does not really mean that "it won't block" (because
> it can really block) but instead it shows whether the mmap_sem is
> released by up_read() during the page fault handling mostly when
> VM_FAULT_RETRY is returned.
> 
> We have the correct naming in e.g. get_user_pages_locked() or
> get_user_pages_remote() as "locked", however there're still many places
> that are using the "nonblocking" as name.
> 
> Renaming the places to "locked" where proper to better suite the
> functionality of the variable.  While at it, fixing up some of the
> comments accordingly.
> 
> Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Reviewed-by: Jerome Glisse <jglisse@redhat.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>
> ---
>  mm/gup.c     | 44 +++++++++++++++++++++-----------------------
>  mm/hugetlb.c |  8 ++++----
>  2 files changed, 25 insertions(+), 27 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index 98f13ab37bac..eddbb95dcb8f 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -622,12 +622,12 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
>  }
>  
>  /*
> - * mmap_sem must be held on entry.  If @nonblocking != NULL and
> - * *@flags does not include FOLL_NOWAIT, the mmap_sem may be released.
> - * If it is, *@nonblocking will be set to 0 and -EBUSY returned.
> + * mmap_sem must be held on entry.  If @locked != NULL and *@flags
> + * does not include FOLL_NOWAIT, the mmap_sem may be released.  If it
> + * is, *@locked will be set to 0 and -EBUSY returned.
>   */
>  static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
> -		unsigned long address, unsigned int *flags, int *nonblocking)
> +		unsigned long address, unsigned int *flags, int *locked)
>  {
>  	unsigned int fault_flags = 0;
>  	vm_fault_t ret;
> @@ -639,7 +639,7 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
>  		fault_flags |= FAULT_FLAG_WRITE;
>  	if (*flags & FOLL_REMOTE)
>  		fault_flags |= FAULT_FLAG_REMOTE;
> -	if (nonblocking)
> +	if (locked)
>  		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
>  	if (*flags & FOLL_NOWAIT)
>  		fault_flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
> @@ -665,8 +665,8 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
>  	}
>  
>  	if (ret & VM_FAULT_RETRY) {
> -		if (nonblocking && !(fault_flags & FAULT_FLAG_RETRY_NOWAIT))
> -			*nonblocking = 0;
> +		if (locked && !(fault_flags & FAULT_FLAG_RETRY_NOWAIT))
> +			*locked = 0;
>  		return -EBUSY;
>  	}
>  
> @@ -743,7 +743,7 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
>   *		only intends to ensure the pages are faulted in.
>   * @vmas:	array of pointers to vmas corresponding to each page.
>   *		Or NULL if the caller does not require them.
> - * @nonblocking: whether waiting for disk IO or mmap_sem contention
> + * @locked:     whether we're still with the mmap_sem held
>   *
>   * Returns number of pages pinned. This may be fewer than the number
>   * requested. If nr_pages is 0 or negative, returns 0. If no pages
> @@ -772,13 +772,11 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
>   * appropriate) must be called after the page is finished with, and
>   * before put_page is called.
>   *
> - * If @nonblocking != NULL, __get_user_pages will not wait for disk IO
> - * or mmap_sem contention, and if waiting is needed to pin all pages,
> - * *@nonblocking will be set to 0.  Further, if @gup_flags does not
> - * include FOLL_NOWAIT, the mmap_sem will be released via up_read() in
> - * this case.
> + * If @locked != NULL, *@locked will be set to 0 when mmap_sem is
> + * released by an up_read().  That can happen if @gup_flags does not
> + * have FOLL_NOWAIT.
>   *
> - * A caller using such a combination of @nonblocking and @gup_flags
> + * A caller using such a combination of @locked and @gup_flags
>   * must therefore hold the mmap_sem for reading only, and recognize
>   * when it's been released.  Otherwise, it must be held for either
>   * reading or writing and will not be released.
> @@ -790,7 +788,7 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
>  static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		unsigned long start, unsigned long nr_pages,
>  		unsigned int gup_flags, struct page **pages,
> -		struct vm_area_struct **vmas, int *nonblocking)
> +		struct vm_area_struct **vmas, int *locked)
>  {
>  	long ret = 0, i = 0;
>  	struct vm_area_struct *vma = NULL;
> @@ -834,7 +832,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  			if (is_vm_hugetlb_page(vma)) {
>  				i = follow_hugetlb_page(mm, vma, pages, vmas,
>  						&start, &nr_pages, i,
> -						gup_flags, nonblocking);
> +						gup_flags, locked);
>  				continue;
>  			}
>  		}
> @@ -852,7 +850,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		page = follow_page_mask(vma, start, foll_flags, &ctx);
>  		if (!page) {
>  			ret = faultin_page(tsk, vma, start, &foll_flags,
> -					nonblocking);
> +					   locked);
>  			switch (ret) {
>  			case 0:
>  				goto retry;
> @@ -1178,7 +1176,7 @@ EXPORT_SYMBOL(get_user_pages_remote);
>   * @vma:   target vma
>   * @start: start address
>   * @end:   end address
> - * @nonblocking:
> + * @locked: whether the mmap_sem is still held
>   *
>   * This takes care of mlocking the pages too if VM_LOCKED is set.
>   *
> @@ -1186,14 +1184,14 @@ EXPORT_SYMBOL(get_user_pages_remote);
>   *
>   * vma->vm_mm->mmap_sem must be held.
>   *
> - * If @nonblocking is NULL, it may be held for read or write and will
> + * If @locked is NULL, it may be held for read or write and will
>   * be unperturbed.
>   *
> - * If @nonblocking is non-NULL, it must held for read only and may be
> - * released.  If it's released, *@nonblocking will be set to 0.
> + * If @locked is non-NULL, it must held for read only and may be
> + * released.  If it's released, *@locked will be set to 0.
>   */
>  long populate_vma_page_range(struct vm_area_struct *vma,
> -		unsigned long start, unsigned long end, int *nonblocking)
> +		unsigned long start, unsigned long end, int *locked)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	unsigned long nr_pages = (end - start) / PAGE_SIZE;
> @@ -1228,7 +1226,7 @@ long populate_vma_page_range(struct vm_area_struct *vma,
>  	 * not result in a stack expansion that recurses back here.
>  	 */
>  	return __get_user_pages(current, mm, start, nr_pages, gup_flags,
> -				NULL, NULL, nonblocking);
> +				NULL, NULL, locked);
>  }
>  
>  /*
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ede7e7f5d1ab..5f816ee42206 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4251,7 +4251,7 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
>  long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			 struct page **pages, struct vm_area_struct **vmas,
>  			 unsigned long *position, unsigned long *nr_pages,
> -			 long i, unsigned int flags, int *nonblocking)
> +			 long i, unsigned int flags, int *locked)
>  {
>  	unsigned long pfn_offset;
>  	unsigned long vaddr = *position;
> @@ -4322,7 +4322,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  				spin_unlock(ptl);
>  			if (flags & FOLL_WRITE)
>  				fault_flags |= FAULT_FLAG_WRITE;
> -			if (nonblocking)
> +			if (locked)
>  				fault_flags |= FAULT_FLAG_ALLOW_RETRY;
>  			if (flags & FOLL_NOWAIT)
>  				fault_flags |= FAULT_FLAG_ALLOW_RETRY |
> @@ -4339,9 +4339,9 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  				break;
>  			}
>  			if (ret & VM_FAULT_RETRY) {
> -				if (nonblocking &&
> +				if (locked &&
>  				    !(fault_flags & FAULT_FLAG_RETRY_NOWAIT))
> -					*nonblocking = 0;
> +					*locked = 0;
>  				*nr_pages = 0;
>  				/*
>  				 * VM_FAULT_RETRY must not return an
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb

