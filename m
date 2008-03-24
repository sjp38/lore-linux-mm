Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
From: Nicholas Miell <nmiell@comcast.net>
In-Reply-To: <a36005b50803241242r2a9b38c5s57d9ac6b084021fa@mail.gmail.com>
References: <20080318104437.966c10ec.akpm@linux-foundation.org>
	 <20080320090005.GA25734@one.firstfloor.org>
	 <a36005b50803211015l64005f6emb80dbfc21dcfad9f@mail.gmail.com>
	 <20080321172644.GG2346@one.firstfloor.org>
	 <a36005b50803212136s78dc2e4bx5ac715ebc7a6e48a@mail.gmail.com>
	 <20080322071755.GP2346@one.firstfloor.org>
	 <1206170695.2438.39.camel@entropy>
	 <20080322091001.GA7264@one.firstfloor.org>
	 <a36005b50803232120j63fb08d8p4a6cfdc8df2a3f21@mail.gmail.com>
	 <1206335761.2438.63.camel@entropy>
	 <a36005b50803241242r2a9b38c5s57d9ac6b084021fa@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 24 Mar 2008 14:47:18 -0700
Message-Id: <1206395238.2438.68.camel@entropy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-03-24 at 12:42 -0700, Ulrich Drepper wrote:
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

The on-disk format theoretically supports multi-block xattrs, but the
kernel driver is hardcoded to support only one.

Also, keep in mind that that 4k limit is for all attributes for an inode
and includes xattr names, values, and various bits of meta data. As
such, the limit is actually less than 4k total and the space is shared
among POSIX ACLs, SELinux contexts and whatever other attributes the
user would like to store on the file.

(Actually, it's 4k plus whatever xattr space there is in the inode,
which depends on how the filesystem was formatted.)

-- 
Nicholas Miell <nmiell@comcast.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
