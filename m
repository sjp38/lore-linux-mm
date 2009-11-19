Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1B3F36B004D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 19:26:32 -0500 (EST)
Message-ID: <4B049090.1070300@redhat.com>
Date: Wed, 18 Nov 2009 19:25:52 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] mm: define PAGE_MAPPING_FLAGS
References: <Pine.LNX.4.64.0911102142570.2272@sister.anvils> <Pine.LNX.4.64.0911102150350.2816@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0911102150350.2816@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11/10/2009 04:51 PM, Hugh Dickins wrote:
> At present we define PageAnon(page) by the low PAGE_MAPPING_ANON bit
> set in page->mapping, with the higher bits a pointer to the anon_vma;
> and have defined PageKsm(page) as that with NULL anon_vma.
>
> But KSM swapping will need to store a pointer there: so in preparation
> for that, now define PAGE_MAPPING_FLAGS as the low two bits, including
> PAGE_MAPPING_KSM (always set along with PAGE_MAPPING_ANON, until some
> other use for the bit emerges).
>
> Declare page_rmapping(page) to return the pointer part of page->mapping,
> and page_anon_vma(page) to return the anon_vma pointer when that's what
> it is.  Use these in a few appropriate places: notably, unuse_vma() has
> been testing page->mapping, but is better to be testing page_anon_vma()
> (cases may be added in which flag bits are set without any pointer).
>
> Signed-off-by: Hugh Dickins<hugh.dickins@tiscali.co.uk>
>
>    
Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
