Message-ID: <416D0AA4.30701@yahoo.com.au>
Date: Wed, 13 Oct 2004 20:59:48 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: NUMA: Patch for node based swapping
References: <Pine.LNX.4.44.0410121151220.13693-100000@chimarrao.boston.redhat.com> <Pine.LNX.4.58.0410121319510.5785@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0410121319510.5785@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 12 Oct 2004, Rik van Riel wrote:
> 
> 
>>On Tue, 12 Oct 2004, Christoph Lameter wrote:
>>
>>
>>>Any other suggestions?
>>
>>Since this is meant as a stop gap patch, waiting for a real
>>solution, and is only relevant for big (and rare) systems,
>>it would be an idea to at least leave it off by default.
>>
>>I think it would be safe to assume that a $100k system has
>>a system administrator looking after it, while a $5k AMD64
>>whitebox might not have somebody watching its performance.
> 
> 
> Ok. Will do that then. Should I submit the patch to Andrew?
> 

I can't see the harm in sending it after 2.6.9 if it defaults
to off (maybe also make it CONFIG_NUMA).

OTOH, if it is going to be painful to remove later on, then
maybe leave it local to your tree.

It's true that I have something a bit more sophisticated in
the pipe, but it is going to be an uphill battle to get it
and everything it depends on merged - so don't count on it for
2.6.10 :P

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
