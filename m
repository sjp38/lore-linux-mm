Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7250E6B01EF
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 09:52:27 -0400 (EDT)
Message-ID: <4BD1A609.4040401@redhat.com>
Date: Fri, 23 Apr 2010 09:52:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [BUGFIX] rmap: remove anon_vma check in page_address_in_vma()
References: <20100422054241.GB10957@spritzerA.linux.bs1.fc.nec.co.jp> <4BD0688A.7050806@redhat.com> <20100423020827.GB7383@spritzerA.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20100423020827.GB7383@spritzerA.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On 04/22/2010 10:08 PM, Naoya Horiguchi wrote:
> Currently page_address_in_vma() compares vma->anon_vma and page_anon_vma(page)
> for parameter check, but in 2.6.34 a vma can have multiple anon_vmas with
> anon_vma_chain, so current check does not work. (For anonymous page shared by
> multiple processes, some verified (page,vma) pairs return -EFAULT wrongly.)
>
> We can go to checking all anon_vmas in the "same_vma" chain, but it needs
> to meet lock requirement. Instead, we can remove anon_vma check safely
> because page_address_in_vma() assumes that page and vma are already checked
> to belong to the identical process.
>
> Signed-off-by: Naoya Horiguchi<n-horiguchi@ah.jp.nec.com>
> Cc: Andrew Morton<akpm@linux-foundation.org>
> Cc: Rik van Riel<riel@redhat.com>
> Cc: Andi Kleen<andi@firstfloor.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
