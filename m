Date: Wed, 4 Apr 2001 22:59:01 +0100
From: Stephen Tweedie <sct@redhat.com>
Subject: Re: [PATCH] Reclaim orphaned swap pages
Message-ID: <20010404225901.C1118@redhat.com>
References: <20010328235958.A1724@redhat.com> <Pine.LNX.4.21.0103301915010.23093-100000@imladris.rielhome.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0103301915010.23093-100000@imladris.rielhome.conectiva>; from riel@conectiva.com.br on Fri, Mar 30, 2001 at 07:16:28PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Stephen Tweedie <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Mar 30, 2001 at 07:16:28PM -0300, Rik van Riel wrote:
> 
> It looks good and simple enough to just plug into the
> kernel. I cannot see any problem with this patch, except
> that the PAGECACHE_LOCK macro doesn't seem to exist (yet)
> in my kernel tree ;))

Yep, I built this on a tree which had Ingo's Tux patches applied and
I'd forgotten that he had added a fine-grained page cache lock to his
code.  Will fix.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
