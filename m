Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA18924
	for <linux-mm@kvack.org>; Tue, 16 Dec 1997 07:32:11 -0500
Date: Tue, 16 Dec 1997 12:53:36 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: Recipe for cooking 2.1.72's mm
In-Reply-To: <19971216091554.50382@Elf.mj.gts.cz>
Message-ID: <Pine.LNX.3.91.971216124819.15838B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@Elf.mj.gts.cz>
Cc: linux-kernel@vger.rutgers.edu, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Dec 1997, Pavel Machek wrote:

> Sorry. There is a problem. It needs to be solved, not worked
> around. (Notice, that same process does nothing bad to 2.0.28).

On my system, it just gives one or two out-of-memory kills
of random processes. I'd really like it if those processes
would be a little less random... Killing kerneld or crond
(or X... remember those poor stateless-vga-card users) is
IMHO worse than killing a program from some USER. Finding
the most hoggy non-root process group and killing some of
it's programs shouldn't be too difficult.

btw: I'm using 2.1.66 with my mmap-age patch...

> And: Work around is bad. Imagine your machine with such behaviour on
> 100MBit ethernet. Imagine me around (ping -f)ing your machine. That
> can keep your pages low for as long as I want. You do not your machine
> to go yo-yo (up and down and up and down ...).

Ok, so we should limit the amount of memory the kernel can grab
for internal usage... Sysctl-wise of course, because some people
have special purpose routing machines.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
