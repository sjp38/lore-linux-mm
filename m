Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 092306B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 14:02:37 -0400 (EDT)
Date: Mon, 15 Jun 2009 20:02:39 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/10] Fix page_mkwrite() for blocksize < pagesize (version 3)
Message-ID: <20090615180239.GA3289@atrey.karlin.mff.cuni.cz>
References: <1245088797-29533-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1245088797-29533-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

> 
> patches below are an attempt to solve problems filesystems have with
> page_mkwrite() when blocksize < pagesize (see the changelog of the second patch
> for details).
> 
> Could someone please review them so that they can get merged - especially the
> generic VFS/MM part? It fixes observed problems (WARN_ON triggers) for ext4 and
> makes ext2/ext3 behave more nicely (mmapped write getting page fault instead
> of silently discarding data).
> 
> The series is against Linus's tree from today. The differences against previous
> version are one bugfix in ext3 delalloc implementation... Please test and review.
> Thanks.
  Sorry for the wrong patch numbering [x/11]. There are really just 10
patches in the series. The eleventh one is just a debugging patch I
don't want to merge.

									Honza
-- 
Jan Kara <jack@suse.cz>
SuSE CR Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
