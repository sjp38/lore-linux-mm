Message-ID: <45A58DFA.8050304@yahoo.com.au>
Date: Thu, 11 Jan 2007 12:08:10 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [REGRESSION] 2.6.19/2.6.20-rc3 buffered write slowdown
References: <20070110223731.GC44411608@melbourne.sgi.com> <Pine.LNX.4.64.0701101503310.22578@schroedinger.engr.sgi.com> <20070110230855.GF44411608@melbourne.sgi.com> <45A57333.6060904@yahoo.com.au> <20070111003158.GT33919298@melbourne.sgi.com>
In-Reply-To: <20070111003158.GT33919298@melbourne.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Chinner wrote:
> On Thu, Jan 11, 2007 at 10:13:55AM +1100, Nick Piggin wrote:
> 
>>David Chinner wrote:
>>
>>>On Wed, Jan 10, 2007 at 03:04:15PM -0800, Christoph Lameter wrote:
>>>
>>>
>>>>On Thu, 11 Jan 2007, David Chinner wrote:
>>>>
>>>>
>>>>
>>>>>The performance and smoothness is fully restored on 2.6.20-rc3
>>>>>by setting dirty_ratio down to 10 (from the default 40), so
>>>>>something in the VM is not working as well as it used to....
>>>>
>>>>dirty_background_ratio is left as is at 10?
>>>
>>>
>>>Yes.
>>>
>>>
>>>
>>>>So you gain performance by switching off background writes via pdflush?
>>>
>>>
>>>Well, pdflush appears to be doing very little on both 2.6.18 and
>>>2.6.20-rc3. In both cases kswapd is consuming 10-20% of a CPU and
>>>all of the pdflush threads combined (I've seen up to 7 active at
>>>once) use maybe 1-2% of cpu time. This occurs regardless of the
>>>dirty_ratio setting.
>>
>>Hi David,
>>
>>Could you get /proc/vmstat deltas for each kernel, to start with?
> 
> 
> Sure, but that doesn't really show the how erratic the per-filesystem
> throughput is because the test I'm running is PCI-X bus limited in
> it's throughput at about 750MB/s. Each dm device is capable of about
> 340MB/s write, so when one slows down, the others will typically
> speed up.

But you do also get aggregate throughput drops? (ie. 2.6.20-rc3-worse)

> So, what I've attached is three files which have both
> 'vmstat 5' output and 'iostat 5 |grep dm-' output in them.

Ahh, sorry to be unclear, I meant:

   cat /proc/vmstat > pre
   run_test
   cat /proc/vmstat > post

It might just give us a hint what is changing (however vmstat doesn't
give much interesting in the way of pdflush stats, so it might not
show anything up).

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
