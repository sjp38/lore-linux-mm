Message-ID: <45DCFD22.2020300@redhat.com>
Date: Wed, 21 Feb 2007 21:17:06 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Take anonymous pages off the LRU if we have no swap
References: <Pine.LNX.4.64.0702211409001.27422@schroedinger.engr.sgi.com> <45DCD309.5010109@redhat.com> <Pine.LNX.4.64.0702211600430.28364@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0702211600430.28364@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 21 Feb 2007, Rik van Riel wrote:
> 
>> I am working on a VM design that would take care of this issue in
>> a somewhat cleaner way.  I'm writing up the bits and pieces as I
>> find easy ways to explain them.
>>
>> Want to help out with brainstorming and implementing?
>>
>> http://linux-mm.org/PageReplacementDesign
> 
> I do not see how this issue would be solved there.

If there is no swap space, we do not bother scanning the anonymous
page pool.  When swap space becomes available, we may end up scanning
it again.

> The patch here is just the leftover from last weeks discussion in which 
> the ability to remove anonymous pages was requested. Which can be done
> in the limited form presented here within the current code in mm.

Yes, we can pile more limited fixes on top of the VM.  I suspect
that too many "limited fixes" on top of each other will just end
up introducing too many corner cases, though.

I would like to move the kernel towards something that fixes all
of the problem workloads, instead of thinking about one problem
at a time and reintroducing bugs for other workloads.

Changes still need to be introduced incrementally, of course, but
I think it would be good if we had an idea where we were headed
in the medium (or even long) term.

http://linux-mm.org/ProblemWorkloads

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
