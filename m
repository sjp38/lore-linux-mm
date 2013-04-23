Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id B6EE36B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 21:53:52 -0400 (EDT)
Date: Tue, 23 Apr 2013 10:53:49 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 6/6] add documentation on proc.txt
Message-ID: <20130423015349.GC2603@blaptop>
References: <1366620306-30940-1-git-send-email-minchan@kernel.org>
 <1366620306-30940-6-git-send-email-minchan@kernel.org>
 <51756286.4020704@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51756286.4020704@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Rik van Riel <riel@redhat.com>, Rob Landley <rob@landley.net>, Namhyung Kim <namhyung@kernel.org>

Hello Dave,

On Mon, Apr 22, 2013 at 09:17:10AM -0700, Dave Hansen wrote:
> On 04/22/2013 01:45 AM, Minchan Kim wrote:
> > +The /proc/PID/reclaim is used to reclaim pages in this process.
> > +To reclaim file-backed pages,
> > +    > echo 1 > /proc/PID/reclaim
> > +
> > +To reclaim anonymous pages,
> > +    > echo 2 > /proc/PID/reclaim
> > +
> > +To reclaim both pages,
> > +    > echo 3 > /proc/PID/reclaim
> 
> This seems to be in the same spirit as /proc/sys/vm/drop_caches.  That's
> not a sin in and of itself.  But, why use numbers here?
> 
> Any chance I could talk you in to using some strings, say like:
> 
> 	echo 'anonymous' > /proc/PID/reclaim
> 	echo 'anonymous|file' > /proc/PID/reclaim

I discussed with Namhyung about interface.
His suggestion looks sane to me.

echo 'file' > /proc/PID/reclaim
echo 'anon' > /proc/PID/reclaim
echo 'both' > /proc/PID/reclaim

For range reclaim,

echo $((1<<20)) 8192 > /proc/PID/reclaim.

IOW, we don't need any type for range reclaim because only thing
user takes care is address range which has mapped page regardless
of that it's anon or file.

Does it make sense to you?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
