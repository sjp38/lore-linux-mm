Message-ID: <41EEB440.8010108@mvista.com>
Date: Wed, 19 Jan 2005 11:25:52 -0800
From: Steve Longerbeam <stevel@mvista.com>
MIME-Version: 1.0
Subject: Re: BUG in shared_policy_replace() ?
References: <Pine.LNX.4.44.0501191221400.4795-100000@localhost.localdomain> <41EE9991.6090606@mvista.com> <20050119174506.GH7445@wotan.suse.de> <41EEA575.9040007@mvista.com> <20050119183430.GK7445@wotan.suse.de> <41EEAE04.3050505@mvista.com> <20050119190927.GM7445@wotan.suse.de>
In-Reply-To: <20050119190927.GM7445@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


Andi Kleen wrote:

>On Wed, Jan 19, 2005 at 10:59:16AM -0800, Steve Longerbeam wrote:
>  
>
>>Andi Kleen wrote:
>>
>>    
>>
>>>>yeah, 2.6.10 makes sense to me too. But I'm working in -mm2, and
>>>>the new2 = NULL line is missing, hence my initial confusion. Trivial
>>>>patch to -mm2 attached. Just want to make sure it has been, or will be,
>>>>put back in.
>>>>  
>>>>
>>>>        
>>>>
>>>That sounds weird. Can you figure out which patch in mm removes it?
>>>
>>>
>>>      
>>>
>>found it:
>>
>>http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.10/2.6.10-mm1/broken-out/mempolicy-optimization.patch
>>    
>>
>
>Are you sure? I don't see it touching the new2 free at the end of the function.
>  
>

it's not touching the new2 free, it's removing the new2 = NULL which is 
the problem.

-				new2 = NULL;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
