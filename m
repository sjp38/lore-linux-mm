Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2C6B26B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:24:53 -0400 (EDT)
Date: Wed, 2 Jun 2010 09:24:27 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V2 0/7] Cleancache (was Transcendent Memory): overview
Message-ID: <20100602132427.GA32110@infradead.org>
References: <20100528173510.GA12166@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100528173510.GA12166@ca-server1.us.oracle.com>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

Please give your patches some semi-resonable subject line.

>  fs/btrfs/super.c           |    2 
>  fs/buffer.c                |    5 +
>  fs/ext3/super.c            |    2 
>  fs/ext4/super.c            |    2 
>  fs/mpage.c                 |    7 +
>  fs/ocfs2/super.c           |    3 
>  fs/super.c                 |    8 +

This is missing out a whole lot of filesystems.  Even more so why the
hell do you need hooks into the filesystem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
