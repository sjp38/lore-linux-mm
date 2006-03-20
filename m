Subject: Re: [PATCH][0/8] (Targeting 2.6.17) Posix memory locking and
	balanced mlock-LRU semantic
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <bc56f2f0603200535s2b801775m@mail.gmail.com>
References: <bc56f2f0603200535s2b801775m@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 20 Mar 2006 14:41:18 +0100
Message-Id: <1142862078.3114.47.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stone Wang <pwstone@gmail.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 1. Posix mlock/munlock/mlockall/munlockall.
>    Get mlock/munlock/mlockall/munlockall to Posix definiton: transaction-like,
>    just as described in the manpage(2) of mlock/munlock/mlockall/munlockall.
>    Thus users of mlock system call series will always have an clear map of
>    mlocked areas.
> 2. More consistent LRU semantics in Memory Management.
>    Mlocked pages is placed on a separate LRU list: Wired List.

please give this a more logical name, such as mlocked list or pinned
list


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
