From: Daniel Phillips <phillips@innominate.de>
Subject: Re: [PATCH] drop-behind fix for generic_file_write
Date: Wed, 3 Jan 2001 16:21:17 +0100
Content-Type: text/plain
References: <Pine.LNX.4.21.0101031256040.1403-100000@duckman.distro.conectiva>
In-Reply-To: <Pine.LNX.4.21.0101031256040.1403-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Message-Id: <01010316360903.00713@gimli>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 03 Jan 2001, Rik van Riel wrote:
> Hi Linus, Alan,
> 
> the following (trivial) patch fixes drop-behind behaviour
> in generic_file_write to only drop fully written pages.
> 
> This increases performance in dbench by about 8% (as
> measured by Daniel Phillips) and should get rid of the
> logfile bottleneck Ingo Molnar found with the drop-behind
> call in generic_file_write in TUX tests.

Rik, I detected the speedup in -pre5 but it disappeared in -pre7 (which
turned in a faster performance than pre5 or 6 anyway).  I don't have an
explanation for that.  The idea makes sense: treat a partial page as
'in play' until completely full, then deactivate it.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
