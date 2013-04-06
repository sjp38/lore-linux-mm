Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 902E46B014B
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 09:17:06 -0400 (EDT)
Date: Sat, 6 Apr 2013 07:17:03 -0600
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH 2/4] fsfreeze: manage kill signal when sb_start_write
	is called
Message-ID: <20130406131703.GC28744@parisc-linux.org>
References: <515FF344.8040705@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515FF344.8040705@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marco Stornelli <marco.stornelli@gmail.com>
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>, Chris Mason <chris.mason@fusionio.com>, Steve French <sfrench@samba.org>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Miklos Szeredi <miklos@szeredi.hu>, Alexander Viro <viro@zeniv.linux.org.uk>, Anton Altaparmakov <anton@tuxera.com>, Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>, Ben Myers <bpm@sgi.com>, Alex Elder <elder@kernel.org>, xfs@oss.sgi.com, Mike Snitzer <snitzer@redhat.com>, Alasdair G Kergon <agk@redhat.com>, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-ext4@vger.kernel.org, fuse-devel@lists.sourceforge.net, linux-ntfs-dev@lists.sourceforge.net, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

On Sat, Apr 06, 2013 at 12:04:52PM +0200, Marco Stornelli wrote:
> In every place where sb_start_write was called now we must manage
> the error code and return -EINTR.

If we must manage the error code, then these functions should be marked
__must_check.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
