Date: Tue, 19 Feb 2008 22:36:25 -0600
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
Message-Id: <20080219223625.a2717138.pj@sgi.com>
In-Reply-To: <20080219210739.27325078@bree.surriel.com>
References: <2f11576a0802090719i3c08a41aj38504e854edbfeac@mail.gmail.com>
	<20080217084906.e1990b11.pj@sgi.com>
	<20080219145108.7E96.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080219090008.bb6cbe2f.pj@sgi.com>
	<20080219222828.GB28786@elf.ucw.cz>
	<20080219210739.27325078@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: pavel@ucw.cz, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, marcelo@kvack.org, daniel.spang@gmail.com, akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk, linux-fsdevel@vger.kernel.org, a1426z@gawab.com, jonathan@jonmasters.org, zlynx@acm.org
List-ID: <linux-mm.kvack.org>

Rik wrote:
> In that case the user is better off having that job killed and
> restarted elsewhere, than having all of the jobs on that node
> crawl to a halt due to swapping.
> 
> Paul, is this guess correct? :)

Not for the loads I focus on.  Each job gets exclusive use of its own
dedicated set of nodes, for the duration of the job.  With that comes a
quite specific upper limit on how much memory, in total, including node
local kernel data, that job is allowed to use.

One problem with swapping is that nodes aren't entirely isolated.
They share buses, i/o channels, disk arms, kernel data cache lines and
kernel locks with other nodes, running other jobs.   A job thrashing
its swap is a drag on the rest of the system.

Another problem with swapping is that it's a waste of resources.  Once
a pure compute bound job goes into swapping when it shouldn't, that job
has near zero hope of continuing with the intended performance, as it
has just slowed from main memory speeds to disk speeds, which are
thousands of times slower.  Best to get it out of there, immediately.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
