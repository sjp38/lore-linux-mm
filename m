Date: Thu, 16 Mar 2000 20:58:41 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] madvise() against 2.3.52-3
In-Reply-To: <14543.57493.860685.448837@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.21.0003160438220.254-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Chuck Lever <cel@monkey.org>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Mar 2000, Stephen C. Tweedie wrote:

>tlb lock on Intel to guard this --- I'm not sure if it's 100% safe on
>other architectures.

It's not safe on other architectures but that's a bug.

Andrea



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
