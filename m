Date: Tue, 19 Feb 2008 14:43:29 -0600
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
Message-Id: <20080219144329.360394cd.pj@sgi.com>
In-Reply-To: <20080219141820.f7132b62.pj@sgi.com>
References: <2f11576a0802090719i3c08a41aj38504e854edbfeac@mail.gmail.com>
	<20080217084906.e1990b11.pj@sgi.com>
	<20080219145108.7E96.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080219090008.bb6cbe2f.pj@sgi.com>
	<20080219140222.4cee07ab@cuia.boston.redhat.com>
	<20080219141820.f7132b62.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, marcelo@kvack.org, daniel.spang@gmail.com, akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk, linux-fsdevel@vger.kernel.org, pavel@ucw.cz, a1426z@gawab.com, jonathan@jonmasters.org, zlynx@acm.org
List-ID: <linux-mm.kvack.org>

pj, talking to himself:
> Of course
> for embedded use, I'd have to adapt it to a non-cpuset based mechanism
> (not difficult), as embedded definitely doesn't do cpusets.

I'm forgetting an important detail here.  Kosaki-san has clearly stated
that this hook, at vmscan's writepage, is too late for his embedded needs,
and that they need the feedback a bit earlier, when the page moves from
the active list to the inactive list.

However, except for the placement of such hooks in three or four
places, rather than just one, it may well be (if cpusets could be
factored out) that one mechanism would meet all needs ... except for
that pesky HPC need for throttling to more or less zero the swapping
from select cpusets.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
