Message-ID: <45EC6ECF.30804@redhat.com>
Date: Mon, 05 Mar 2007 14:26:07 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [rfc][patch 2/2] mm: mlocked pages off LRU
References: <20070305161746.GD8128@wotan.suse.de> <Pine.LNX.4.64.0703050948040.6620@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0703050948040.6620@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:

>>  /*
>> + * This routine is used to map in an anonymous page into an address space:
>> + * needed by execve() for the initial stack and environment pages.
> 
> Could we have some common code that also covers do_anonymous page etc?

It would be good to cover ramfs, too.

(unless it already does some magic that I overlooked)

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
