Date: Mon, 11 Jun 2001 13:03:14 +1000
From: Daniel Stone <daniel@kabuki.sfarc.net>
Subject: Re: [PATCH] 2.4.6-pre2 page_launder() improvements
Message-ID: <20010611130314.B964@kabuki.openfridge.net>
References: <Pine.LNX.4.33.0106100128100.4239-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0106100128100.4239-100000@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 10, 2001 at 01:40:44AM -0300, Rik van Riel wrote:
> [Request For Testers ... patch below]
> 
> Hi,
> 
> during my holidays I've written the following patch (forward-ported
> to 2.4.6-pre2 and improved a tad today), which implements these
> improvements to page_launder():
> 
> YMMV, please test it. If it works great for everybody I'd like
> to get this improvement merged into the next -pre kernel.

I forgot about vmstat, but this is -ac12, anecdotal evidence - my system
(weak) performs far better under heavy load (mpg123 nice'd to -20 + apt/dpkg
+ gcc), than with vanilla -ac12. To get it to compile on -ac, just hand-hack
in the patch, and s/CAN_GET_IO/can_get_io_locks/ in vmscan.c.

:) d

-- 
Daniel Stone		<daniel@kabuki.openfridge.net> <daniel@kabuki.sfarc.net>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
