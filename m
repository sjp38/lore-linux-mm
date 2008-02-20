Date: Tue, 19 Feb 2008 21:07:39 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
Message-ID: <20080219210739.27325078@bree.surriel.com>
In-Reply-To: <20080219222828.GB28786@elf.ucw.cz>
References: <2f11576a0802090719i3c08a41aj38504e854edbfeac@mail.gmail.com>
	<20080217084906.e1990b11.pj@sgi.com>
	<20080219145108.7E96.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080219090008.bb6cbe2f.pj@sgi.com>
	<20080219222828.GB28786@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Paul Jackson <pj@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, marcelo@kvack.org, daniel.spang@gmail.com, akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk, linux-fsdevel@vger.kernel.org, a1426z@gawab.com, jonathan@jonmasters.org, zlynx@acm.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Feb 2008 23:28:28 +0100
Pavel Machek <pavel@ucw.cz> wrote:

> Sounds like a job for memory limits (ulimit?), not for OOM
> notification, right?

I suspect one problem could be that an HPC job scheduling program
does not know exactly how much memory each job can take, so it can
sometimes end up making a mistake and overcommitting the memory on
one HPC node.

In that case the user is better off having that job killed and
restarted elsewhere, than having all of the jobs on that node
crawl to a halt due to swapping.

Paul, is this guess correct? :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
