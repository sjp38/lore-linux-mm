Subject: Re: VM problem in 2.5.69-mm5
From: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <20030524175106.385f8e45.akpm@digeo.com>
References: <1053822686.32330.35.camel@tux.rsn.bth.se>
	 <20030524175106.385f8e45.akpm@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Message-Id: <1053824174.32331.49.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Date: 25 May 2003 02:56:14 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2003-05-25 at 02:51, Andrew Morton wrote:
> Martin Josefsson <gandalf@wlug.westbo.se> wrote:
> >
> > 2.5.69-mm5 has some serious problems on my machine (pIII 700 704MB ram,
> >  512MB swap)
> 
> So you do.
> 
> Don't know.  You could try `elevator=deadline' to rule that out.

Ok, I'll do that.

> What filesystems are in use?

only ext3, all mounted in ordered mode.

> file_lock_cache seems rather large (irrelevantly)

Yes it leaks in 2.5, known problem, I think we (willy and me) nailed it
down to that it is something postfix does that triggers it. Anyway I
have seen >500k leaked without any noticable impact on the system in
earlier kernels.

-- 
/Martin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
