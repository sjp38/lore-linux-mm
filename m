Message-ID: <491DBD9E.6030703@goop.org>
Date: Fri, 14 Nov 2008 10:04:14 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: implement remap_pfn_range with apply_to_page_range
References: <491C61B1.10005@goop.org> <200811141417.35724.nickpiggin@yahoo.com.au> <491D0B2F.7050900@goop.org> <200811141835.17073.nickpiggin@yahoo.com.au>
In-Reply-To: <200811141835.17073.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> No, adding a cycle here or an indirect function call there IMO is
> not acceptable in core mm/ code without a good reason.
>   

<shrug> OK.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
