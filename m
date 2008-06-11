Date: Wed, 11 Jun 2008 16:16:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 12/21] hugetlb: introduce pud_huge
Message-Id: <20080611161622.aa650b88.akpm@linux-foundation.org>
In-Reply-To: <20080604113112.524988294@amd.local0.net>
References: <20080604112939.789444496@amd.local0.net>
	<20080604113112.524988294@amd.local0.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 04 Jun 2008 21:29:51 +1000
npiggin@suse.de wrote:

> Straight forward extensions for huge pages located in the PUD
> instead of PMDs.

s390:

mm/built-in.o: In function `follow_page':
: undefined reference to `pud_huge'
mm/built-in.o: In function `apply_to_page_range':
: undefined reference to `pud_huge'

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
