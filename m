Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.59-mm5 got stuck during boot
Date: Fri, 24 Jan 2003 14:18:18 -0500
References: <20030123195044.47c51d39.akpm@digeo.com> <200301241244.05268.tomlins@cam.org> <3E317E6A.7020507@cyberone.com.au>
In-Reply-To: <3E317E6A.7020507@cyberone.com.au>
MIME-Version: 1.0
Message-Id: <200301241418.18275.tomlins@cam.org>
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On January 24, 2003 12:56 pm, Nick Piggin wrote:
> Processes get sleep waiting for a page and never wake up.
> It doesn't seem to be an anticipatory scheduling problem but
> if you have time, try changing drivers/block/deadline-iosched.c
>
> static int antic_expire = HZ / 25;
> to
> static int antic_expire = 0;
>
> And see if you can reproduce.

It boots with this change.

Ed 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
