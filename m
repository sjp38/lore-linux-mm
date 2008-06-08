Date: Sun, 8 Jun 2008 12:14:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 16/21] hugetlb: allow arch overried hugepage allocation
Message-Id: <20080608121445.168fb358.akpm@linux-foundation.org>
In-Reply-To: <20080604113113.026345633@amd.local0.net>
References: <20080604112939.789444496@amd.local0.net>
	<20080604113113.026345633@amd.local0.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Wed, 04 Jun 2008 21:29:55 +1000 npiggin@suse.de wrote:

> Subject: [patch 16/21] hugetlb: allow arch overried hugepage allocation

I assumed that this was supposed to read "overridden".

>  
> +__initdata LIST_HEAD(huge_boot_pages);

WARNING: externs should be avoided in .c files
#61: FILE: mm/hugetlb.c:34:
+__initdata LIST_HEAD(huge_boot_pages);

checkpatch got confused.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
