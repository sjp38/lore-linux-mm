Date: Thu, 27 Jan 2005 16:41:37 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [patch] ext2: Apply Jack's ext3 speedups
Message-ID: <20050127214137.GA9509@thunk.org>
References: <200501270722.XAA10830@allur.sanmateo.akamai.com> <20050127205233.GB9225@thunk.org> <20050127131158.126f0f09.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050127131158.126f0f09.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: pmeda@akamai.com, jack@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 27, 2005 at 01:11:58PM -0800, Andrew Morton wrote:
> "Theodore Ts'o" <tytso@mit.edu> wrote:
> >
> > On Wed, Jan 26, 2005 at 11:22:39PM -0800, pmeda@akamai.com wrote:
> > > 
> > > Apply ext3 speedups added by Jan Kara to ext2.
> > > Reference: http://linus.bkbits.net:8080/linux-2.5/gnupatch@41f127f2jwYahmKm0eWTJNpYcSyhPw
> > > 
> > 
> > This patch isn't right, as it causes ext2_sparse_group(1) to return 0
> > instead of 1.  Block groups number 0 and 1 must always contain a
> > superblock.
> 
> I'd already queued up the below actually.  It seems to get things right?

Looks good to me.

						- Ted
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
