From: David Howells <dhowells@redhat.com>
In-Reply-To: <20050816135900.GA3326@elf.ucw.cz> 
References: <20050816135900.GA3326@elf.ucw.cz>  <200508121329.46533.phillips@istop.com> <200508110812.59986.phillips@arcor.de> <20050808145430.15394c3c.akpm@osdl.org> <26569.1123752390@warthog.cambridge.redhat.com> <5278.1123850479@warthog.cambridge.redhat.com> 
Subject: Re: [RFC][PATCH] Rename PageChecked as PageMiscFS 
Date: Thu, 18 Aug 2005 15:33:18 +0100
Message-ID: <7489.1124375598@warthog.cambridge.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: David Howells <dhowells@redhat.com>, Daniel Phillips <phillips@istop.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Pavel Machek <pavel@ucw.cz> wrote:

> > My patch has been around for quite a while, and no-one else has
> > complained, not even you before this point. Plus, you don't seem to be
> > complaining about PageSwapCache... nor even PageLocked.
> 
> PageFsMisc really *is* ugly and hard to read. PageLocked etc. look
> bad, too but ThIs iS rEaLlY WrOnG.

And PageMappedToDisk()?

I disagree. For the most part weird capsage is wrong, but this is readable.
Whilst it could make it page_fs_misc() instead, that'd be against the style of
the rest of the file, though maybe you want to go through and change all of
that too.

Maybe you'd prefer bPageFsMisc()? :-)

Actually, all these functions should really be called something like
IsPageXxxx() to note they're asking a question rather than giving a command.

> PageMisc would look less ugly

I disagree again. I don't think PageFsMisc() is particularly ugly or
unreadable; and it makes it a touch more likely that someone reading code that
uses it will notice that it's a miscellaneous flag specifically for filesystem
use (you can't rely on them going and looking in the header file for a
comment).

> , make note in a comment that it is for filesystems only.

There should be a comment as well, I suppose. I'll amend the patch for Andrew.

All this should also be documented in Documentation/ somewhere too, I suppose.

David
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
