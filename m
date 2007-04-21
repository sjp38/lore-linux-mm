Message-ID: <4629C81D.8050606@google.com>
Date: Sat, 21 Apr 2007 01:15:25 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/8] Cpuset aware writeback
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com> <45C2960B.9070907@google.com> <Pine.LNX.4.64.0702011815240.9799@schroedinger.engr.sgi.com> <46019F67.3010300@google.com> <Pine.LNX.4.64.0703211428430.4832@schroedinger.engr.sgi.com> <4626CEDA.7050608@google.com> <Pine.LNX.4.64.0704181948260.8743@schroedinger.engr.sgi.com> <46296ACD.3020402@google.com> <Pine.LNX.4.64.0704201840200.13607@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704201840200.13607@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 20 Apr 2007, Ethan Solomita wrote:
>
>   
>> cpuset_write_dirty_map.htm
>>
>>    In __set_page_dirty_nobuffers() you always call cpuset_update_dirty_nodes()
>> but in __set_page_dirty_buffers() you call it only if page->mapping is still
>> set after locking. Is there a reason for the difference? Also a question not
>> about your patch: why do those functions call __mark_inode_dirty() even if the
>> dirty page has been truncated and mapping == NULL?
>>     
>
> If page->mapping has been cleared then the page was removed from the 
> mapping. __mark_inode_dirty just dirties the inode. If a truncation occurs 
> then the inode was modified.
>   

    You didn't address the first half. Why do the buffers() and 
nobuffers() act differently when calling cpuset_update_dirty_nodes()?

>> cpuset_write_throttle.htm
>>
>>    I noticed that several lines have leading spaces. I didn't check if other
>> patches have the problem too.
>>     
>
> Maybe download the patches? How did those strange .htm endings get 
> appended to the patches?
>   

    Something weird with Firefox, but instead of jumping on me did you 
consider double checking your patches? I just went back, found the text 
versions, and the spaces are still there.e.g.:

+  	unsigned long dirtyable_memory;


>>    In get_dirty_limits(), when cpusets are configd you don't subtract highmen
>> the same way that is done without cpusets. Is this intentional?
>>     
>
> That is something in flux upstream. Linus changed it recently. Do it one 
> way or the other.
>   

    Exactly -- your patch should be consistent and do it the same way as 
whatever your patch is built against. Your patch is built against a 
kernel that subtracts off highmem. "Do it..." are you handing off the 
patch and are done with it?

>>    It seems that dirty_exceeded is still a global punishment across cpusets.
>> Should it be addressed?
>>     
>
> Sure. It would be best if you could place that somehow in a cpuset.
>   

    Again it sounds like you're handing them off. I'm not objecting I 
just hadn't understood that.
    -- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
