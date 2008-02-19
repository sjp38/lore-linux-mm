Date: Tue, 19 Feb 2008 23:28:28 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
Message-ID: <20080219222828.GB28786@elf.ucw.cz>
References: <2f11576a0802090719i3c08a41aj38504e854edbfeac@mail.gmail.com> <20080217084906.e1990b11.pj@sgi.com> <20080219145108.7E96.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080219090008.bb6cbe2f.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080219090008.bb6cbe2f.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, marcelo@kvack.org, daniel.spang@gmail.com, riel@redhat.com, akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk, linux-fsdevel@vger.kernel.org, a1426z@gawab.com, jonathan@jonmasters.org, zlynx@acm.org
List-ID: <linux-mm.kvack.org>

On Tue 2008-02-19 09:00:08, Paul Jackson wrote:
> Kosaki-san wrote:
> > Thank you for wonderful interestings comment.
> 
> You're most welcome.  The pleasure is all mine.
> 
> > you think kill the process just after swap, right?
> > but unfortunately, almost user hope receive notification before swap ;-)
> > because avoid swap.
> 
> There is not much my customers HPC jobs can do with notification before
> swap.  Their jobs either have the main memory they need to perform the
> requested calculations with the desired performance, or their job is
> useless and should be killed.  Unlike the applications you describe,
> my customers jobs have no way, once running, to adapt to less
> memory.

Sounds like a job for memory limits (ulimit?), not for OOM
notification, right?
								Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
