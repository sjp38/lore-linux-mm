Message-ID: <467F6C8F.9040400@yahoo.com.au>
Date: Mon, 25 Jun 2007 17:19:43 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 1/3] add the fsblock layer
References: <20070624014528.GA17609@wotan.suse.de>	<20070624014613.GB17609@wotan.suse.de> <p73fy4h5q3c.fsf@bingen.suse.de>
In-Reply-To: <p73fy4h5q3c.fsf@bingen.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> Nick Piggin <npiggin@suse.de> writes:
> 
> 
> [haven't read everything, just commenting on something that caught my eye]
> 
> 
>>+struct fsblock {
>>+	atomic_t	count;
>>+	union {
>>+		struct {
>>+			unsigned long	flags; /* XXX: flags could be int for better packing */
> 
> 
> int is not supported by many architectures, but works on x86 at least.

Yeah, that would be nice. We could actually use this for buffer_head as well,
but saving 4% there isn't so important as saving 20% for fsblock :)


> Hmm, could define a macro DECLARE_ATOMIC_BITMAP(maxbit) that expands to the smallest
> possible type for each architecture. And a couple of ugly casts for set_bit et.al.
> but those could be also hidden in macros. Should be relatively easy to do.

Cool. It would probably be useful for other things as well.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
