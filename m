Date: Mon, 7 Jul 2003 16:23:39 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: 2.5.74-mm1
Message-ID: <20030707152339.GA9669@mail.jlokier.co.uk>
References: <20030703023714.55d13934.akpm@osdl.org> <200307060414.34827.phillips@arcor.de> <Pine.LNX.4.53.0307071042470.743@skynet> <200307071424.06393.phillips@arcor.de> <Pine.LNX.4.53.0307071408440.5007@skynet> <Pine.LNX.4.55.0307070745250.4428@bigblue.dev.mcafeelabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.55.0307070745250.4428@bigblue.dev.mcafeelabs.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Davide Libenzi <davidel@xmailserver.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Daniel Phillips <phillips@arcor.de>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Davide Libenzi wrote:
> The scheduler has to work w/out external input, period.

Can you justify this?

It strikes me that a music player's thread which requests a special
music-playing scheduling hint is not unreasonable, if that actually
works and scheduler heuristics do not.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
