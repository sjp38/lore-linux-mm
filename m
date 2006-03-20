Subject: Re: PATCH][1/8] 2.6.15 mlock: make_pages_wired/unwired
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <bc56f2f0603200536scb87a8ck@mail.gmail.com>
References: <bc56f2f0603200536scb87a8ck@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 20 Mar 2006 14:42:14 +0100
Message-Id: <1142862134.3114.49.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stone Wang <pwstone@gmail.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2006-03-20 at 08:36 -0500, Stone Wang wrote:
> 1. Add make_pages_unwired routine.
> 2. Replace make_pages_present with make_pages_wired, support rollback.
> 3. Pass 1 more param ("wire") to get_user_pages.

hmm again "wire" is a meaningless name
also.. get_user_pages ALWAYS pins the page ... so might as well make
that automatic (with an unpin when the pinning is released)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
