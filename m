Message-ID: <41918A9A.90601@cyberone.com.au>
Date: Wed, 10 Nov 2004 14:27:22 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] kswapd shall not sleep during page shortage
References: <20041109164642.GE7632@logos.cnet>	<20041109121945.7f35d104.akpm@osdl.org>	<20041109174125.GF7632@logos.cnet>	<20041109133343.0b34896d.akpm@osdl.org>	<20041109182622.GA8300@logos.cnet>	<20041109142257.1d1411e1.akpm@osdl.org>	<4191675B.3090903@cyberone.com.au>	<419181D5.1090308@cyberone.com.au>	<20041109185640.32c8871b.akpm@osdl.org>	<41918715.1080008@cyberone.com.au> <20041109191858.6802f5c3.akpm@osdl.org>
In-Reply-To: <20041109191858.6802f5c3.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>Nick Piggin <piggin@cyberone.com.au> wrote:
>
>>Make sense?
>>
>
>Hey, you know me - I'll believe anything.
>
>Let's take a second look at the numbers when you have a patch.  Please
>check that we're printing all the relevant info at boot time.
>
>

OK... I'll actually go the other way - really quadruple min_free_kbytes,
and squash the top watermarks down, rather than the bottom ones up. This
way min_free_kbytes should retain its semantics. I've got a patch I'll
test now...

Also, what info do you want at boot time?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
