Date: Sun, 13 Oct 2002 18:04:02 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.5.42-mm2
In-Reply-To: <20021013195236.GC27878@holomorphy.com>
Message-ID: <Pine.LNX.4.44L.0210131803400.22735-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 13 Oct 2002, William Lee Irwin III wrote:

> (1) It's embedded in struct zone, hence bootmem allocated, hence
> 	already zeroed.

The struct zone doesn't get automatically zeroed on all architectures.

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://distro.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
