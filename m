Date: Sat, 16 Feb 2002 15:37:39 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] shrink struct page for 2.5
Message-ID: <20020216233739.GA3511@holomorphy.com>
References: <Pine.LNX.4.33L.0202161804330.1930-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33L.0202161804330.1930-100000@imladris.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 16, 2002 at 06:15:03PM -0200, Rik van Riel wrote:
> Unfortunately I haven't managed to make 2.5.5-pre2 to boot on
> my machine, so I haven't been able to test this port of the
> patch to 2.5. The code has been running stably in 2.4 for the
> last 2 months though, so if you can boot 2.5, please help test
> this thing.

I tested current 2.5.5-pre bk on a diskless Pentium 200 MMX with 192MB
of RAM loading with PXELINUX and with nfsroot enabled.

The result was a triplefault (i.e. reboot) before console_init(),
which clearly isn't our code failing.

It was literally early enough I'm inclined to suspect bootloader
protocol issues.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
