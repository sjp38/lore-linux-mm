Date: Mon, 9 Oct 2000 21:58:09 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001009215809.I19583@athlon.random>
References: <Pine.LNX.4.21.0010092040300.6338-100000@elte.hu> <39E21CCB.61AC1EBE@kalifornia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39E21CCB.61AC1EBE@kalifornia.com>; from david@kalifornia.com on Mon, Oct 09, 2000 at 12:30:20PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: david+validemail@kalifornia.com
Cc: mingo@elte.hu, Byron Stanoszek <gandalf@winds.org>, Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 09, 2000 at 12:30:20PM -0700, David Ford wrote:
> Init should only get killed if it REALLY is taking a lot of memory.  On a 4 or 8meg

Init should never get killed. Killing init can be compared to destroy the TCP
stack. Some app can keep to run right for some minute until they run socket()
and then they will hang. Same with init, some task may still run right for
some time but the machine will die eventually. We simply must not pass the
point of not return or we're buggy and after the bug triggered we have to force
the user to reboot the machine as only way to recover.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
