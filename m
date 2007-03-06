Message-ID: <45ED8FD5.6090308@redhat.com>
Date: Tue, 06 Mar 2007 10:59:17 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [rfc][patch 2/2] mm: mlocked pages off LRU
References: <20070305161746.GD8128@wotan.suse.de> <Pine.LNX.4.64.0703050948040.6620@schroedinger.engr.sgi.com> <20070306010529.GB23845@wotan.suse.de> <Pine.LNX.4.64.0703051723240.16842@schroedinger.engr.sgi.com> <20070306014403.GD23845@wotan.suse.de> <Pine.LNX.4.64.0703051753070.16964@schroedinger.engr.sgi.com> <20070306021307.GE23845@wotan.suse.de> <Pine.LNX.4.64.0703051845050.17203@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0703051845050.17203@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@engr.sgi.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 6 Mar 2007, Nick Piggin wrote:
> 
>>> The above is a bit contradictory. Assuming they are taken off the LRU:
>>> How will they be returned to the LRU?
>> In what way is it contradictory? If they are mlocked, we put them on the
>> LRU when they get munlocked. If they are off the LRU due to a !swap condition,
>> then we put them back on the LRU by whatever mechanism that uses (eg. a
>> 3rd LRU list that we go through much more slowly...).
> 
> Ok how are we going to implement the 3rd LRU for non mlocked anonymous 
> pages if you use the lru for the refcounter field? Another page flags bit? 

I'm working on it, in-between my other duties.  A separate set
of LRU lists for file backed pages vs swap backed/anon pages.

I think I'm about halfway done with the patch now - I'm amazed
how much stuff changed in the VM since I got abducted to work
on Xen...

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
