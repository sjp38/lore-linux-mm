From: "George Bonser" <george@gator.com>
Subject: RE: [PATCH] 2.4.6-pre2 page_launder() improvements
Date: Sun, 10 Jun 2001 02:06:09 -0700
Message-ID: <CHEKKPICCNOGICGMDODJKEJNDEAA.george@gator.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <Pine.LNX.4.33.0106100541200.1742-100000@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>
> That sounds like the machine just gets a working set
> larger than the amount of available memory. It should
> work better with eg. 96, 128 or more MBs of memory.

Now that I think about it a little more ... once I took it out of the
balancer and I got control back, I had over 500 apache kids alive and it was
responsive.  Also, when top -q starting giving out, it was still updating
the screen though it started getting slower and slower ... at that point I
only had MAYBE 300 apache processes. It almost felt like the system could
not catch up as fast as the new connections were arriving. Lets say it "goes
dead" at about 300 or so connections, I let it run for a while then take it
out of the rotation and it "comes back" and shows me it has about 500
processes and its interactive response is fine and it is only about 100MB
into swap. It just feels like it can't get out of its own way fast enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
