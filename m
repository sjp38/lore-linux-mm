Message-ID: <45DDCD38.6000807@redhat.com>
Date: Thu, 22 Feb 2007 12:04:56 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Take anonymous pages off the LRU if we have no swap
References: <Pine.LNX.4.64.0702211409001.27422@schroedinger.engr.sgi.com> <45DCD309.5010109@redhat.com> <Pine.LNX.4.64.0702211600430.28364@schroedinger.engr.sgi.com> <45DCFD22.2020300@redhat.com> <Pine.LNX.4.64.0702211900340.29703@schroedinger.engr.sgi.com> <45DD88E3.2@redhat.com> <45DDB85D.209@in.ibm.com>
In-Reply-To: <45DDB85D.209@in.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@in.ibm.com
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Rik van Riel wrote:
>> Christoph Lameter wrote:
>>> On Wed, 21 Feb 2007, Rik van Riel wrote:
>>>
>> Absolutely.  I am convinced that the whole "swappiness" thing
>> of scanning past the anonymous pages in order to find the page
>> cache pages will fall apart on 256GB systems even with somewhat
>> friendly workloads.
> 
> That should probably make a good case for splitting the LRU
> into unmapped and mapped page LRU's :-) 

Please read http://linux-mm.org/PageReplacementDesign.

There are good reasons why the split should probably be
between anonymous/swap backed and file backed pages,
not between mapped and unmapped.

> I hope to get to it, implement it and get some results.

Ditto here :)

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
