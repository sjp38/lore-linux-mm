Date: Tue, 19 Feb 2002 14:30:43 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH *] new struct page shrinkage
In-Reply-To: <3C7278B7.C0E4D126@mandrakesoft.com>
Message-ID: <Pine.LNX.4.33L.0202191429420.7820-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Feb 2002, Jeff Garzik wrote:
> Rik van Riel wrote:
> > I've also pulled the thing up to
> > your latest changes from linux.bkbits.net so you should be
> > able to just pull it into your tree from:
>
> Note that with BK, unlike CVS, it is not required that you update to
> the latest Linus tree before he can pull.
>
> It is only desired that you do so if there is an actual conflict you
> need to resolve...

In this case there were 2 files with a potential conflict
(buffer.c and filemap.c).

No actual conflicts, but I thought it good manners to
pull the tree and resolve any potential conflicts myself,
instead of burdening Linus with the job.

regards,

Rik
-- 
"Linux holds advantages over the single-vendor commercial OS"
    -- Microsoft's "Competing with Linux" document

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
