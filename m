Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B11D66B004F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 06:27:36 -0400 (EDT)
Date: Tue, 16 Jun 2009 12:28:23 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/10] Fix page_mkwrite() for blocksize < pagesize
	(version 3)
Message-ID: <20090616102823.GA12577@duck.suse.cz>
References: <1245088797-29533-1-git-send-email-jack@suse.cz> <20090615181753.GA26615@skywalker>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090615181753.GA26615@skywalker>
Sender: owner-linux-mm@kvack.org
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

  Hi,

On Mon 15-06-09 23:47:53, Aneesh Kumar K.V wrote:
> On Mon, Jun 15, 2009 at 07:59:47PM +0200, Jan Kara wrote:
> > 
> > patches below are an attempt to solve problems filesystems have with
> > page_mkwrite() when blocksize < pagesize (see the changelog of the second patch
> > for details).
> > 
> > Could someone please review them so that they can get merged - especially the
> > generic VFS/MM part? It fixes observed problems (WARN_ON triggers) for ext4 and
> > makes ext2/ext3 behave more nicely (mmapped write getting page fault instead
> > of silently discarding data).
> 
> Will you be able to send it as two series.
> 
> a) One that fix the blocksize < page size bug
> b) making ext2/3 mmaped write give better allocation pattern.
> 
> Doing that will make sure (a) can go in this merge window. There are
> other ext4 fixes waiting for (a) to be merged in.
  Of course, there is no problem in merging just patches 2, 4 which are
needed for ext4, and leave the rest for the next merge window. Actually,
I'd rather leave at least ext3 patch for the next merge window because that
has the highest chance of breaking something...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
