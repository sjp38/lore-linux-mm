Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 55D2E6B0098
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 03:41:36 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so2805980pad.14
        for <linux-mm@kvack.org>; Tue, 11 Dec 2012 00:41:35 -0800 (PST)
Date: Tue, 11 Dec 2012 00:41:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: kswapd infinite loop in 3.7-rc6?
In-Reply-To: <CALCETrX0t6YkzA5Q2rozsmbDCrrGgUopZVCMwT_vv0gVcvDDCw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1212110040430.16584@chino.kir.corp.google.com>
References: <CALCETrX0t6YkzA5Q2rozsmbDCrrGgUopZVCMwT_vv0gVcvDDCw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-mm@kvack.org

On Mon, 3 Dec 2012, Andy Lutomirski wrote:

> The stack looks like this:
> 
> [<ffffffff81192015>] put_super+0x25/0x40
> [<ffffffff811920f2>] drop_super+0x22/0x30
> [<ffffffff81193199>] prune_super+0x149/0x1b0
> [<ffffffff8113f241>] shrink_slab+0xa1/0x2d0
> [<ffffffff81142b09>] balance_pgdat+0x609/0x7d0
> [<ffffffff81142e44>] kswapd+0x174/0x450
> [<ffffffff81081810>] kthread+0xc0/0xd0
> [<ffffffff8161e3ac>] ret_from_fork+0x7c/0xb0
> [<ffffffffffffffff>] 0xffffffffffffffff
> 

Does this persist in v3.7, which was released today, now that it has 
caf491916b1c ("Revert "revert "Revert "mm: remove __GFP_NO_KSWAPD""" and 
associated damage")?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
