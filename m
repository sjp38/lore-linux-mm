Date: Fri, 30 Mar 2001 19:16:28 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Reclaim orphaned swap pages
In-Reply-To: <20010328235958.A1724@redhat.com>
Message-ID: <Pine.LNX.4.21.0103301915010.23093-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Tweedie <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Mar 2001, Stephen Tweedie wrote:

> Rik, the patch below tries to reclaim orphaned swap pages after
> swapped processes exit.  I've only given it basic testing but I want
> to get feedback on it sooner rather than later --- we need to do
> _something_ about this problem!
> 
> The patch works completely differently to the release-on-exit diffs:

It looks good and simple enough to just plug into the
kernel. I cannot see any problem with this patch, except
that the PAGECACHE_LOCK macro doesn't seem to exist (yet)
in my kernel tree ;))

cheers,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
