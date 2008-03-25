Date: Tue, 25 Mar 2008 08:54:03 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
Message-ID: <20080325075403.GH2170@one.firstfloor.org>
References: <20080320090005.GA25734@one.firstfloor.org> <a36005b50803211015l64005f6emb80dbfc21dcfad9f@mail.gmail.com> <20080321172644.GG2346@one.firstfloor.org> <a36005b50803212136s78dc2e4bx5ac715ebc7a6e48a@mail.gmail.com> <20080322071755.GP2346@one.firstfloor.org> <1206170695.2438.39.camel@entropy> <20080322091001.GA7264@one.firstfloor.org> <a36005b50803232120j63fb08d8p4a6cfdc8df2a3f21@mail.gmail.com> <1206335761.2438.63.camel@entropy> <a36005b50803241242r2a9b38c5s57d9ac6b084021fa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a36005b50803241242r2a9b38c5s57d9ac6b084021fa@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@gmail.com>
Cc: Nicholas Miell <nmiell@comcast.net>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 24, 2008 at 12:42:14PM -0700, Ulrich Drepper wrote:
> On Sun, Mar 23, 2008 at 10:16 PM, Nicholas Miell <nmiell@comcast.net> wrote:
> >  The limit is filesystem dependent -- I think ext2/3s is something like
> >  4k total for attribute names and values per inode.
> >
> >  That's more than enough space for the largest executable on my system
> >  (emacs at 36788160 bytes) which would have a 1123 byte predictive bitmap
> >  (plus space for the name e.g. "system.predictive_bitmap"). The bitmap
> >  also could be compressed.
> 
> 4k attribute means support for about 32768 pages.  That's a total of
> 134MB.  I think this qualifies as sufficient.  Also, I assume the
> attribute limit is just a "because nobody needed more so far" limit
> and could in theory be extended.

There is still the additional seek. Large xattrs tend to be out of line
from the inode.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
