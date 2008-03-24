Date: Mon, 24 Mar 2008 06:26:23 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
Message-ID: <20080324052623.GA13691@one.firstfloor.org>
References: <a36005b50803191545h33d1a443y57d09176f8324186@mail.gmail.com> <20080320090005.GA25734@one.firstfloor.org> <a36005b50803211015l64005f6emb80dbfc21dcfad9f@mail.gmail.com> <20080321172644.GG2346@one.firstfloor.org> <a36005b50803212136s78dc2e4bx5ac715ebc7a6e48a@mail.gmail.com> <20080322071755.GP2346@one.firstfloor.org> <1206170695.2438.39.camel@entropy> <20080322091001.GA7264@one.firstfloor.org> <a36005b50803232120j63fb08d8p4a6cfdc8df2a3f21@mail.gmail.com> <1206335761.2438.63.camel@entropy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1206335761.2438.63.camel@entropy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nicholas Miell <nmiell@comcast.net>
Cc: Ulrich Drepper <drepper@gmail.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

First emacs is still a rather small executable, there are much larger
ones around.

> The limit is filesystem dependent -- I think ext2/3s is something like
> 4k total for attribute names and values per inode.

That large xattrs tend to be out of line on a separate block and that would cost 
an additional seek. It would be unlikely to be continuous to the rest of the file 
data and thus even be worse than the SHDR which is at least likely to be
served from the same track buffer as the executable.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
