Message-ID: <4707D9B4.8020904@tmr.com>
Date: Sat, 06 Oct 2007 14:53:40 -0400
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: [13/18] x86_64: Allow fallback for the stack
References: <20071004035935.042951211@sgi.com>	<20071004040004.708466159@sgi.com>	<200710041356.51750.ak@suse.de>	<Pine.LNX.4.64.0710041220010.12075@schroedinger.engr.sgi.com> <20071004153940.49bd5afc@bree.surriel.com>
In-Reply-To: <20071004153940.49bd5afc@bree.surriel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On Thu, 4 Oct 2007 12:20:50 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
>> On Thu, 4 Oct 2007, Andi Kleen wrote:
>>
>>> We've known for ages that it is possible. But it has been always so
>>> rare that it was ignored.
>> Well we can now address the rarity. That is the whole point of the 
>> patchset.
> 
> Introducing complexity to fight a very rare problem with a good
> fallback (refusing to fork more tasks, as well as lumpy reclaim)
> somehow does not seem like a good tradeoff.
>  
>>> Is there any evidence this is more common now than it used to be?
>> It will be more common if the stack size is increased beyond 8k.
> 
> Why would we want to do such a thing?
> 
> 8kB stacks are large enough...
> 
Why would anyone need more than 640k... In addition to NUMA, who can 
tell what some future hardware might do, given that the size of memory 
is expanding as if it were covered in Moore's Law. As memory sizes 
increase someone will bump the page size again. Better to Let people 
make it as large as they feel they need and warn at build time 
performance may suck.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
