Date: Tue, 3 Sep 2002 21:53:27 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.5.33-mm1
In-Reply-To: <20020904004028.GS888@holomorphy.com>
Message-ID: <Pine.LNX.4.44L.0209032152210.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@zip.com.au>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Sep 2002, William Lee Irwin III wrote:

> count_list() appears to be the largest consumer of cpu after this is
> done, or so say the profiles after running updatedb by hand on
> 2.5.33-mm1 on a 900MHz P-III T21 Thinkpad with 256MB of RAM.
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

> Maybe it's old news. Just thought I'd try running a test on something
> tiny for once. (new kbd/mouse config options were a PITA BTW)

You've got an interesting idea of tiny ;)

Somehow I have the idea that the Linux users with 64 MB
of RAM or less have _more_ memory together than what's
present in all the >8GB Linux servers together...

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
