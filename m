Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 627EF6B005C
	for <linux-mm@kvack.org>; Fri, 22 May 2009 16:46:57 -0400 (EDT)
Date: Fri, 22 May 2009 22:47:36 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] Warn if we run out of swap space
Message-ID: <20090522204736.GA32134@elf.ucw.cz>
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0905221454460.7673@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri 2009-05-22 14:58:19, Christoph Lameter wrote:
> 
> Subject: Warn if we run out of swap space
> 
> Running out of swap space means that the evicton of anonymous pages may no longer
> be possible which can lead to OOM conditions.
> 
> Print a warning when swap space first becomes exhausted.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Acked-by: Pavel Machek <pavel@ucw.cz>

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
