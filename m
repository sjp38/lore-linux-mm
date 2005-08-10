Subject: Re: [RFC][PATCH] Rename PageChecked as PageMiscFS
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <200508110857.06539.phillips@arcor.de>
References: <42F57FCA.9040805@yahoo.com.au>
	 <200508110823.53593.phillips@arcor.de>
	 <1123713258.10292.109.camel@lade.trondhjem.org>
	 <200508110857.06539.phillips@arcor.de>
Content-Type: text/plain
Date: Wed, 10 Aug 2005 19:23:56 -0400
Message-Id: <1123716236.8082.12.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

to den 11.08.2005 Klokka 08:57 (+1000) skreiv Daniel Phillips:
> > What "NFS-related colliding use of page flags bit 8"?
> 
> As explained to me:
> 
> http://marc.theaimsgroup.com/?l=linux-kernel&m=112368417412580&w=2

Oh. You are talking about CacheFS? That hasn't been declared "ready to
merge" yet.

That said, is it really safe to use any flags other than
PG_lock/PG_writeback there, David? I can't see that you want to allow
other tasks to modify or free the page while you are writing it to the
local cache.

Cheers,
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
