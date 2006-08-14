Message-ID: <44DFBEA3.5070305@google.com>
Date: Sun, 13 Aug 2006 17:06:59 -0700
From: Daniel Phillips <phillips@google.com>
MIME-Version: 1.0
Subject: Re: rename *MEMALLOC flags
References: <20060812141415.30842.78695.sendpatchset@lappy>	 <20060812141445.30842.47336.sendpatchset@lappy>	 <44DDE8B6.8000900@garzik.org> <1155395201.13508.44.camel@lappy>
In-Reply-To: <1155395201.13508.44.camel@lappy>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jeff Garzik <jeff@garzik.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Indan Zupancic <indan@nul.nu>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
>Jeff Garzik in his infinite wisdom spake thusly:
>>Peter Zijlstra wrote:
>>
>>>Index: linux-2.6/include/linux/gfp.h
>>>===================================================================
>>>--- linux-2.6.orig/include/linux/gfp.h	2006-08-12 12:56:06.000000000 +0200
>>>+++ linux-2.6/include/linux/gfp.h	2006-08-12 12:56:09.000000000 +0200
>>>@@ -46,6 +46,7 @@ struct vm_area_struct;
>>> #define __GFP_ZERO	((__force gfp_t)0x8000u)/* Return zeroed page on success */
>>> #define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
>>> #define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
>>>+#define __GFP_MEMALLOC  ((__force gfp_t)0x40000u) /* Use emergency reserves */
>>
>>This symbol name has nothing to do with its purpose.  The entire area of 
>>code you are modifying could be described as having something to do with 
>>'memalloc'.
>>
>>GFP_EMERGENCY or GFP_USE_RESERVES or somesuch would be a far better 
>>symbol name.
>>
>>I recognize that is matches with GFP_NOMEMALLOC, but that doesn't change 
>>the situation anyway.  In fact, a cleanup patch to rename GFP_NOMEMALLOC 
>>would be nice.
> 
> I'm rather bad at picking names, but here goes:
> 
> PF_MEMALLOC      -> PF_EMERGALLOC
> __GFP_NOMEMALLOC -> __GFP_NOEMERGALLOC
> __GFP_MEMALLOC   -> __GFP_EMERGALLOC
> 
> Is that suitable and shall I prepare patches? Or do we want more ppl to
> chime in and have a few more rounds?

MEMALLOC is the name Linus chose to name exactly the reserve from which we
are allocating.  Perhaps that was just Linus being denser than jgarzik and
not realizing that he should have called it EMERGALLOC right from the start.

BUT since Linus did call it MEMALLOC, we should too.  Or just email Linus
and tell him how much better EMERGALLOC rolls off the tongue, and could we
please change all occurances of MEMALLOC to EMERGALLOC.  Then don't read
your email for a week ;-)

Inventing a new name for an existing thing is very poor taste on grounds of
grepability alone.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
