Subject: Re: [RFC][PATCH] Rename PageChecked as PageMiscFS
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <200508110823.53593.phillips@arcor.de>
References: <42F57FCA.9040805@yahoo.com.au>
	 <20050808145430.15394c3c.akpm@osdl.org>
	 <200508110812.59986.phillips@arcor.de>
	 <200508110823.53593.phillips@arcor.de>
Content-Type: text/plain
Date: Wed, 10 Aug 2005 18:34:18 -0400
Message-Id: <1123713258.10292.109.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

to den 11.08.2005 Klokka 08:23 (+1000) skreiv Daniel Phillips:
> Note: I have not fully audited the NFS-related colliding use of page flags bit 
> 8, to verify that it really does not escape into VFS or MM from NFS, in fact 
> I have misgivings about end_page_fs_misc which uses this flag but has no 
> in-tree users to show how it is used and, hmm, isn't even _GPL.  What is up?

What "NFS-related colliding use of page flags bit 8"?

Cheers,
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
