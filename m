Date: Tue, 10 May 2005 08:09:25 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch] mm: fix rss counter being incremented when unmapping
In-Reply-To: <20050509122916.GA30726@doener.homenet>
Message-ID: <Pine.LNX.4.61.0505100808320.24219@chimarrao.boston.redhat.com>
References: <20050509122916.GA30726@doener.homenet>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="279726928-1609229727-1115726965=:24219"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?Q?Bj=F6rn?= Steinbrink <B.Steinbrink@gmx.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--279726928-1609229727-1115726965=:24219
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 9 May 2005, Bjorn Steinbrink wrote:

> This patch fixes a bug introduced by the "mm counter operations through
> macros" patch, which replaced a decrement operation in with an increment
> macro in try_to_unmap_one().

Oops.  Patch looks good to me.
Andrew, if you see this could you pick up the
patch from the head of this thread? ;)

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--279726928-1609229727-1115726965=:24219--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
