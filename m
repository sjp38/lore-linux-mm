Subject: Re: [PATCH][0/8] (Targeting 2.6.17) Posix memory locking and balanced mlock-LRU semantic
References: <bc56f2f0603200535s2b801775m@mail.gmail.com>
From: Andi Kleen <ak@suse.de>
Date: 24 Mar 2006 15:36:46 +0100
In-Reply-To: <bc56f2f0603200535s2b801775m@mail.gmail.com>
Message-ID: <p73bqvv6ha9.fsf@verdi.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stone Wang <pwstone@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stone Wang" <pwstone@gmail.com> writes:
>    mlocked areas.
> 2. More consistent LRU semantics in Memory Management.
>    Mlocked pages is placed on a separate LRU list: Wired List.

If it's mlocked why don't you just called it Mlocked list? 
Strange jargon makes the patch cooler? Also in meminfo

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
