Message-ID: <45DCD309.5010109@redhat.com>
Date: Wed, 21 Feb 2007 18:17:29 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Take anonymous pages off the LRU if we have no swap
References: <Pine.LNX.4.64.0702211409001.27422@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0702211409001.27422@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:

> On linux-mm we also discussed taking anonymous pages off the LRU if there 
> is no swap defined or not enough swap. However, there is no easy way of 
> putting the pages back to the LRU since we have no list of mlocked pages. 

Chris,

I am working on a VM design that would take care of this issue in
a somewhat cleaner way.  I'm writing up the bits and pieces as I
find easy ways to explain them.

Want to help out with brainstorming and implementing?

http://linux-mm.org/PageReplacementDesign

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
