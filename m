Date: Sat, 16 Feb 2002 21:23:27 +0100
From: Dave Jones <davej@suse.de>
Subject: Re: [PATCH] shrink struct page for 2.5
Message-ID: <20020216212327.C4777@suse.de>
References: <Pine.LNX.4.33L.0202161804330.1930-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33L.0202161804330.1930-100000@imladris.surriel.com>; from riel@conectiva.com.br on Sat, Feb 16, 2002 at 06:15:03PM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 16, 2002 at 06:15:03PM -0200, Rik van Riel wrote:
 > Hi,
 > 
 > I've forward-ported a small part of the -rmap patch to 2.5,
 > the shrinkage of the struct page. Most of this code is from
 > William Irwin and Christoph Hellwig.

 Anton Blanchard did some nice benchmarks of this work a while
 ago, and noticed that with one of the features (I think the
 I forget which its in the l-k archives somewhere) there
 seemed to be a noticable performance degradation.
 Of course, this was a dbench test, so how reflective this is
 of real world is another story..

 Maybe Randy Hron can throw it in with the next round of
 kernel tests he does ?

 > Unfortunately I haven't managed to make 2.5.5-pre2 to boot on
 > my machine, so I haven't been able to test this port of the
 > patch to 2.5.

 Just a complete lock up ? oops ? anything ?

-- 
| Dave Jones.        http://www.codemonkey.org.uk
| SuSE Labs
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
