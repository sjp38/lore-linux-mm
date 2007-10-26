Message-ID: <47226325.4000404@mbligh.org>
Date: Fri, 26 Oct 2007 14:59:01 -0700
From: Martin Bligh <mbligh@mbligh.org>
MIME-Version: 1.0
Subject: Re: OOM notifications
References: <20071018201531.GA5938@dmt>	<20071026140201.ae52757c.akpm@linux-foundation.org>	<472256AB.6060109@mbligh.org>	<20071026141112.18af0fa6.akpm@linux-foundation.org> <20071026173550.333d8eb4@bree.surriel.com>
In-Reply-To: <20071026173550.333d8eb4@bree.surriel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, marcelo@kvack.org, linux-kernel@vger.kernel.org, drepper@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On Fri, 26 Oct 2007 14:11:12 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
>> Sure, but in terms of high-level userspace interface, being able to
>> select() on a group of priority buckets (spread across different
>> nodes, zones and cgroups) seems a lot more flexible than any
>> signal-based approach we could come up with.
> 
> Absolutely, the process needs to be able to just poll or
> select on a file descriptor from the process main loop.
> 
> I am not convinced that the magic of NUMA memory distribution
> and NUMA memory pressure should be visible to userspace.  Due
> to the thundering herd problem we cannot wake up all of the
> processes that select on the filedescriptor at the same time
> anyway, so we can (later on) add NUMA magic to the process
> selection logic in the kernel to only wake up processes on
> the right NUMA nodes.
> 
> The initial patch probably does not need that.

Depends if you're using cpusets or not, I think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
