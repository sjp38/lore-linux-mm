Date: Tue, 24 Aug 2004 16:24:43 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bug 3268] New: Lowmemory exhaustion problem with v2.6.8.1-mm4
 16gb
Message-Id: <20040824162443.500f3d02.akpm@osdl.org>
In-Reply-To: <1093389067.5677.1839.camel@knk>
References: <200408242051.i7OKplP0009870@fire-1.osdl.org>
	<20040824144312.09b4af42.akpm@osdl.org>
	<1093389067.5677.1839.camel@knk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: keith <kmannth@us.ibm.com>
Cc: linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

keith <kmannth@us.ibm.com> wrote:
>
> Is it possible to fail an kmem_cache_alloc
> call?

Normally not, in the current VM setup (Andrea has differences
of opinion on this, so the code is set up to switch policies).

The kmem_cache_alloc() caller can change that policy by adding
in __GFP_NORETRY.

We'll know more when you've added meminfo/slabinfo/buddyinfo.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
