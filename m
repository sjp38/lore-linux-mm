Date: Fri, 19 Aug 2005 00:27:21 +0200
From: Pavel Machek <pavel@suse.cz>
Subject: Re: [RFC][PATCH] Rename PageChecked as PageMiscFS
Message-ID: <20050818222721.GC4275@elf.ucw.cz>
References: <20050816135900.GA3326@elf.ucw.cz> <200508121329.46533.phillips@istop.com> <200508110812.59986.phillips@arcor.de> <20050808145430.15394c3c.akpm@osdl.org> <26569.1123752390@warthog.cambridge.redhat.com> <5278.1123850479@warthog.cambridge.redhat.com> <7489.1124375598@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7489.1124375598@warthog.cambridge.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Daniel Phillips <phillips@istop.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi!

> > PageMisc would look less ugly
> 
> I disagree again. I don't think PageFsMisc() is particularly ugly or
> unreadable; and it makes it a touch more likely that someone reading code that
> uses it will notice that it's a miscellaneous flag specifically for filesystem
> use (you can't rely on them going and looking in the header file for a
> comment).

Well, is it PageFsMisc or PageFSMisc? Subject gets second variant, and
I like it better, too. (That does not mean I like it).

								Pavel
-- 
if you have sharp zaurus hardware you don't need... you know my address
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
