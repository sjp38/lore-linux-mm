From: Daniel Phillips <phillips@istop.com>
Subject: Re: [RFC][PATCH] Rename PageChecked as PageMiscFS
Date: Sat, 20 Aug 2005 02:31:18 +1000
References: <20050818222721.GC4275@elf.ucw.cz> <7489.1124375598@warthog.cambridge.redhat.com> <8880.1124445882@warthog.cambridge.redhat.com>
In-Reply-To: <8880.1124445882@warthog.cambridge.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508200231.19341.phillips@istop.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Pavel Machek <pavel@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Friday 19 August 2005 20:04, David Howells wrote:
> Pavel Machek <pavel@suse.cz> wrote:
> > > I disagree again. I don't think PageFsMisc() is particularly ugly or
> > > unreadable; and it makes it a touch more likely that someone reading
> > > code that uses it will notice that it's a miscellaneous flag
> > > specifically for filesystem use (you can't rely on them going and
> > > looking in the header file for a comment).
> >
> > Well, is it PageFsMisc or PageFSMisc? Subject gets second variant, and
> > I like it better, too. (That does not mean I like it).
>
> The Subject wasn't set by me. Somehow the PageFsMisc variant looks better
> to me, but I could just be biased.

Biased.  Fs is a mixed case acronym, nuff said.

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
