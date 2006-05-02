Message-ID: <44576BF5.8070903@yahoo.com.au>
Date: Wed, 03 May 2006 00:25:57 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: assert/crash in __rmqueue() when enabling CONFIG_NUMA
References: <20060419112130.GA22648@elte.hu> <p73aca07whs.fsf@bragg.suse.de> <20060502070618.GA10749@elte.hu> <200605020905.29400.ak@suse.de> <44576688.6050607@mbligh.org>
In-Reply-To: <44576688.6050607@mbligh.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:
>> Oh that's a 32bit kernel. I don't think the 32bit NUMA has ever worked
>> anywhere but some Summit systems (at least every time I tried it it 
>> blew up on me and nobody seems to use it regularly). Maybe it would be 
>> finally time to mark it CONFIG_BROKEN though or just remove it (even 
>> by design it doesn't work very well) 
> 
> 
> Bollocks. It works fine, and is tested every single day, on every git
> release, and every -mm tree.

Whatever the case, there definitely does not appear to be sufficient
zone alignment enforced for the buddy allocator. I cannot see how it
could work if zones are not aligned on 4MB boundaries.

Maybe some architectures / subarch code naturally does this for us,
but Ingo is definitely hitting this bug because his config does not
(align, that is).

I've randomly added a couple more cc's.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
