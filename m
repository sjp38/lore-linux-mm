Date: Mon, 17 Mar 2008 08:02:08 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [11/18] Fix alignment bug in bootmem allocator
Message-ID: <20080317070208.GC27015@one.firstfloor.org>
References: <20080317258.659191058@firstfloor.org> <20080317015825.0C0171B41E0@basil.firstfloor.org> <86802c440803161919h20ed9f78k6e3798ef56668638@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86802c440803161919h20ed9f78k6e3798ef56668638@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> node_boot_start is not page aligned?

It is, but it is not necessarily GB aligned and without this
change sometimes alloc_bootmem when requesting GB alignment
doesn't return GB aligned memory. This was a nasty problem
that took some time to track down.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
