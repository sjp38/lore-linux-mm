Date: Mon, 5 Jun 2000 10:43:44 -0700 (PDT)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.4.0-test1: fix for SMP race in getblk()
In-Reply-To: <20000604191848.C22412@loth.demon.co.uk>
Message-ID: <Pine.LNX.4.21.0006051042120.439-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Dodd <steved@loth.demon.co.uk>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.rutgers.edu, Tigran Aivazian <tigran@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 4 Jun 2000, Steve Dodd wrote:

>This is a repost of a patch which I sent a while back but that never got
>merged. Can anyone see any problems with it?

It's right. It's just merged into the classzone patch since some time.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
