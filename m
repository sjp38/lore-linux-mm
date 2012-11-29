Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id CF2936B007D
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 15:17:52 -0500 (EST)
From: Jim Meyering <jim@meyering.net>
Subject: Re: [PATCH] tmpfs: support SEEK_DATA and SEEK_HOLE (reprise)
In-Reply-To: <20121129195206.GB6434@dastard> (Dave Chinner's message of "Fri,
	30 Nov 2012 06:52:07 +1100")
References: <alpine.LNX.2.00.1211281706390.1516@eggly.anvils>
	<20121129012933.GA9112@kernel>
	<alpine.LNX.2.00.1211281745200.1641@eggly.anvils>
	<87lidlxcw9.fsf@rho.meyering.net> <20121129195206.GB6434@dastard>
Date: Thu, 29 Nov 2012 21:17:51 +0100
Message-ID: <87ip8o17v4.fsf@rho.meyering.net>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Hugh Dickins <hughd@google.com>, Jaegeuk Hanse <jaegeuk.hanse@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Zheng Liu <wenqing.lz@taobao.com>, Jeff liu <jeff.liu@oracle.com>, Paul Eggert <eggert@cs.ucla.edu>, Christoph Hellwig <hch@infradead.org>, Josef Bacik <josef@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andreas Dilger <adilger@dilger.ca>, Marco Stornelli <marco.stornelli@gmail.com>, Chris Mason <chris.mason@fusionio.com>, Sunil Mushran <sunil.mushran@oracle.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Dave Chinner wrote:
...
>> So, yes, GNU cp will soon use this feature.
>
> It would be nice if utilities like grep used it, too, because having
> grep burn gigabytes of memory scanning holes in large files and
> then going OOM is, well, kind of nasty:
>
> $ xfs_io -f -c "truncate 1t" blah
> $ ls -l
> total 0
> -rw-r--r-- 1 dave dave 1.0T Nov 30 06:42 blah
> $ grep foo blah
> grep: memory exhausted
> $ $ grep -V
> grep (GNU grep) 2.12

Hi Dave,

Yes, adapting grep is also on the road map.
That precise case was one of my arguments for making SEEK_DATA/SEEK_HOLE
support more widespread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
