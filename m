Date: Tue, 9 Nov 2004 19:18:58 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] kswapd shall not sleep during page shortage
Message-Id: <20041109191858.6802f5c3.akpm@osdl.org>
In-Reply-To: <41918715.1080008@cyberone.com.au>
References: <20041109164642.GE7632@logos.cnet>
	<20041109121945.7f35d104.akpm@osdl.org>
	<20041109174125.GF7632@logos.cnet>
	<20041109133343.0b34896d.akpm@osdl.org>
	<20041109182622.GA8300@logos.cnet>
	<20041109142257.1d1411e1.akpm@osdl.org>
	<4191675B.3090903@cyberone.com.au>
	<419181D5.1090308@cyberone.com.au>
	<20041109185640.32c8871b.akpm@osdl.org>
	<41918715.1080008@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <piggin@cyberone.com.au> wrote:
>
> Make sense?

Hey, you know me - I'll believe anything.

Let's take a second look at the numbers when you have a patch.  Please
check that we're printing all the relevant info at boot time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
