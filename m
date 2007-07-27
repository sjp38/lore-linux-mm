Subject: Re: updatedb
From: Mike Galbraith <efault@gmx.de>
In-Reply-To: <46A98A14.3040300@gmail.com>
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com>
	 <46A773EA.5030103@gmail.com>
	 <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com>
	 <46A81C39.4050009@gmail.com>
	 <7e0bae390707252323k2552c701x5673c55ff2cf119e@mail.gmail.com>
	 <9a8748490707261746p638e4a98p3cdb7d9912af068a@mail.gmail.com>
	 <46A98A14.3040300@gmail.com>
Content-Type: text/plain
Date: Fri, 27 Jul 2007 09:54:04 +0200
Message-Id: <1185522844.6295.64.camel@Homer.simpson.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Jesper Juhl <jesper.juhl@gmail.com>, Andika Triwidada <andika@gmail.com>, Robert Deaton <false.hopes@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-07-27 at 08:00 +0200, Rene Herman wrote:

> The remaining issue of updatedb unnecessarily blowing away VFS caches is 
> being discussed (*) in a few thread-branches still running.

If you solve that, the swap thing dies too, they're one and the same
problem.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
