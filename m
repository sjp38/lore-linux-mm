Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 066536B01AA
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 11:03:37 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c4so1691276eek.10
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 08:03:36 -0700 (PDT)
Message-ID: <51603799.9070008@gmail.com>
Date: Sat, 06 Apr 2013 16:56:25 +0200
From: Marco Stornelli <marco.stornelli@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] fsfreeze: manage kill signal when sb_start_write
 is called
References: <515FF344.8040705@gmail.com> <20130406131703.GC28744@parisc-linux.org>
In-Reply-To: <20130406131703.GC28744@parisc-linux.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>, Chris Mason <chris.mason@fusionio.com>, Steve French <sfrench@samba.org>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Miklos Szeredi <miklos@szeredi.hu>, Alexander Viro <viro@zeniv.linux.org.uk>, Anton Altaparmakov <anton@tuxera.com>, Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>, Ben Myers <bpm@sgi.com>, Alex Elder <elder@kernel.org>, xfs@oss.sgi.com, Mike Snitzer <snitzer@redhat.com>, Alasdair G Kergon <agk@redhat.com>, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-ext4@vger.kernel.org, fuse-devel@lists.sourceforge.net, linux-ntfs-dev@lists.sourceforge.net, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

Il 06/04/2013 15:17, Matthew Wilcox ha scritto:
> On Sat, Apr 06, 2013 at 12:04:52PM +0200, Marco Stornelli wrote:
>> In every place where sb_start_write was called now we must manage
>> the error code and return -EINTR.
>
> If we must manage the error code, then these functions should be marked
> __must_check.
>

Yep, good point.

Marco

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
