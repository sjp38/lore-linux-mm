Date: Mon, 27 Mar 2006 14:24:15 +0200
From: Pavel Machek <pavel@suse.cz>
Subject: Re: [PATCH] mm: swsusp shrink_all_memory tweaks
Message-ID: <20060327122415.GC1766@elf.ucw.cz>
References: <200603200231.50666.kernel@kolivas.org> <200603202250.14843.kernel@kolivas.org> <200603201946.32681.rjw@sisk.pl> <200603241807.41175.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200603241807.41175.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux list <linux-kernel@vger.kernel.org>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> > swsusp_shrink_memory() is still wrong, because it will always fail for
> > image_size = 0.  My bad, sorry.
> >
> > The appended patch (on top of yours) should fix that (hope I did it right
> > this time).
> 
> Well I discovered that if all the necessary memory is freed in one call to
>  shrink_all_memory we don't get the nice updating printout from
>  swsusp_shrink_memory telling us we're making progress. So instead of
>  modifying the function to call shrink_all_memory with the full amount (and
>  since we've botched swsusp_shrink_memory a few times between us), we should
>  limit it to a max of SHRINK_BITEs instead.
> 
>  This patch is fine standalone.
> 
>  Rafael, Pavel what do you think of this one? 

Looks good to me (but I'm not a mm expert).
									Pavel

-- 
Picture of sleeping (Linux) penguin wanted...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
