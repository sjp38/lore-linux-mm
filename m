Message-ID: <45F97C9B.6060503@redhat.com>
Date: Thu, 15 Mar 2007 13:04:27 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
References: <Pine.GSO.4.64.0703081612290.1080@cpu102.cs.uwaterloo.ca> <20070312142012.GH30777@atrey.karlin.mff.cuni.cz> <20070312143900.GB6016@wotan.suse.de> <20070312151355.GB23532@duck.suse.cz> <Pine.GSO.4.64.0703121247210.7679@cpu102.cs.uwaterloo.ca> <20070312173500.GF23532@duck.suse.cz> <Pine.GSO.4.64.0703131438580.8193@cpu102.cs.uwaterloo.ca> <20070313185554.GA5105@duck.suse.cz> <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca> <45F96CCB.4000709@redhat.com> <20070315162944.GI8321@wotan.suse.de>
In-Reply-To: <20070315162944.GI8321@wotan.suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Chuck Ebbert <cebbert@redhat.com>, Ashif Harji <asharji@cs.uwaterloo.ca>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> A change to make database style random read() workloads perform better, by
> calling mark_page_accessed for some non-page-aligned reads broke the case of
> < PAGE_CACHE_SIZE files, which will not get their prev_index moved past the
> first page.
> 
> Combine both heuristics for marking the page accessed.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
