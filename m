Date: Wed, 4 Feb 2004 02:10:35 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2/5] mm improvements
Message-Id: <20040204021035.2a6ca8a2.akpm@osdl.org>
In-Reply-To: <4020BE25.9050908@cyberone.com.au>
References: <4020BDCB.8030707@cyberone.com.au>
	<4020BE25.9050908@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <piggin@cyberone.com.au> wrote:
>
>  > 2/5: vm-dont-rotate-active-list.patch
>  >     Nikita's patch to keep more page ordering info in the active list.
>  >     Also should improve system time due to less useless scanning
>  >     Helps swapping loads significantly.

It bugs me that this improvement is also applicable to 2.4.  if it makes
the same improvement there, we're still behind.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
