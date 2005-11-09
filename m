Message-ID: <43716476.1030306@yahoo.com.au>
Date: Wed, 09 Nov 2005 13:52:38 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]: Cleanup of __alloc_pages
References: <20051107174349.A8018@unix-os.sc.intel.com>	 <20051107175358.62c484a3.akpm@osdl.org>	 <1131416195.20471.31.camel@akash.sc.intel.com>	 <43701FC6.5050104@yahoo.com.au> <20051107214420.6d0f6ec4.pj@sgi.com>	 <43703EFB.1010103@yahoo.com.au> <1131473876.2400.9.camel@akash.sc.intel.com>
In-Reply-To: <1131473876.2400.9.camel@akash.sc.intel.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rohit Seth <rohit.seth@intel.com>
Cc: Paul Jackson <pj@sgi.com>, akpm@osdl.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rohit Seth wrote:

>On Tue, 2005-11-08 at 17:00 +1100, Nick Piggin wrote:
>
>
>>That would be good. I'll send off a fresh patch with the
>>ALLOC_WATERMARKS fixed after Rohit gets around to looking over
>>it.
>>
>>
>
>Nick, your changes have really come out good.  Thanks.  I think it is
>definitely a good starting point as it maintains all of existing
>behavior.
>
>

Great, glad you agree. I'll send the revised copy upstream.

>I guess now I can argue about why we should keep the watermark low for
>GFP_HIGH ;-)
>
>

Yep, I would be happy to discuss this with you and linux-mm :)


Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
