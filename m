Message-ID: <44180D5A.7000202@yahoo.com.au>
Date: Wed, 15 Mar 2006 23:49:30 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: page migration: Fail with error if swap not setup
References: <Pine.LNX.4.64.0603141903150.24199@schroedinger.engr.sgi.com> <20060314192443.0d121e73.akpm@osdl.org> <Pine.LNX.4.64.0603141945060.24395@schroedinger.engr.sgi.com> <20060314195234.10cf35a7.akpm@osdl.org> <Pine.LNX.4.64.0603141955370.24487@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603141955370.24487@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 14 Mar 2006, Andrew Morton wrote:
> 
> 
>>But the operation can still fail if we run out of swapspace partway through
>>- so this problem can still occur.  The patch just makes it (much) less
>>frequent.
>>
>>Surely it's possible to communicate -ENOSWAP correctly and reliably?
> 
> 
> There are a number of possible failure conditions. The strategy of the 
> migration function is to migrate as much as possible and return the rest 
> without giving any reason. migrate_pages() returns the number of leftover 
> pages not the reasons they failed.
> 

Could you return the reason the first failing page failed. At least then
the caller can have some idea about what is needed to make further progress.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
