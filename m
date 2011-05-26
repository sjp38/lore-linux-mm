Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 94F206B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 14:35:52 -0400 (EDT)
Message-ID: <4DDE9C01.2090104@zytor.com>
Date: Thu, 26 May 2011 11:29:21 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [slubllv5 07/25] x86: Add support for cmpxchg_double
References: <20110516202605.274023469@linux.com> <20110516202625.197639928@linux.com> <4DDE9670.3060709@zytor.com> <alpine.DEB.2.00.1105261315350.26578@router.home>
In-Reply-To: <alpine.DEB.2.00.1105261315350.26578@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

On 05/26/2011 11:17 AM, Christoph Lameter wrote:
> On Thu, 26 May 2011, H. Peter Anvin wrote:
> 
>>> +config CMPXCHG_DOUBLE
>>> +	def_bool X86_64 || (X86_32 && !M386)
>>> +
>>
>> CMPXCHG16B is not a baseline feature for the Linux x86-64 build, and
>> CMPXCHG8G is a Pentium, not a 486, feature.
>>
>> Nacked-by: H. Peter Anvin <hpa@zytor.com>
> 
> Hmmm... We may have to call it CONFIG_CMPXCHG_DOUBLE_POSSIBLE then?
> 
> Because the slub code tests the flag in the processor and will not use the
> cmpxchg16b from the allocator if its not there. It will then fallback to
> using a bit lock in page struct.
> 

Well, if it is just about being "possible" then it should simply be true
for all of x86.  There is no reason to exclude i386 (which is all your
above predicate does, it is exactly equivalent to !M386).

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
