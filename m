Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 47CD26B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 11:04:53 -0500 (EST)
Received: by pwi6 with SMTP id 6so1279478pwi.14
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 08:04:52 -0800 (PST)
Date: Mon, 22 Nov 2010 00:39:49 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [BUG?] [Ext4] INFO: suspicious rcu_dereference_check() usage
Message-ID: <20101121153949.GD20947@barrios-desktop>
References: <20101121112611.GB4267@deepthought.bhanu.net>
 <20101121133024.GF23423@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101121133024.GF23423@thunk.org>
Sender: owner-linux-mm@kvack.org
To: Ted Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andreas Dilger <adilger.kernel@dilger.ca>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Eric Sandeen <sandeen@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, Nov 21, 2010 at 08:30:24AM -0500, Ted Ts'o wrote:
> On Sun, Nov 21, 2010 at 07:26:11PM +0800, Arun Bhanu wrote:
> > I saw this in kernel log messages while testing 2.6.37-rc2. I think it
> > appeared while mounting an external hard-disk. I can't seem to
> > reproduce it.
> 
> I could be wrong but this looks like it's a bug in mm/migrate.c in
> migrate_page_move_mapping(): it is calling radix_tree_lookup_slot()
> without first taking an rcu_read_lock().
> 
> It was triggered by a memory allocation out of ext4_fill_super(),
> which then triggered a memory compaction/migration, but I don't
> believe it's otherwise related to the ext4 code.
> 
> Over to the linux-mm folks for confirmation...

I think it's no problem. 

That's because migration always holds lock_page on the file page.
So the page couldn't remove from radix. 


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
