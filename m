Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 47D876B007E
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 05:39:49 -0500 (EST)
Date: Thu, 16 Feb 2012 11:39:44 +0100
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [PATCH v5 3/3] fadvise: implement POSIX_FADV_NOREUSE
Message-ID: <20120216103944.GA1440@thinkpad>
References: <1329006098-5454-1-git-send-email-andrea@betterlinux.com>
 <1329006098-5454-4-git-send-email-andrea@betterlinux.com>
 <20120215233537.GA20724@dev3310.snc6.facebook.com>
 <20120215234724.GA21685@thinkpad>
 <4F3C467B.1@fb.com>
 <20120216005608.GC21685@thinkpad>
 <4F3C6594.3030709@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F3C6594.3030709@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun Sharma <asharma@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shaohua.li@intel.com>, =?iso-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>, John Stultz <john.stultz@linaro.org>, Jerry James <jamesjer@betterlinux.com>, Julius Plenz <julius@plenz.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Feb 15, 2012 at 06:10:28PM -0800, Arun Sharma wrote:
> On 2/15/12 4:56 PM, Andrea Righi wrote:
> 
> >Oh sorry, you're right! nocache_tree is not a pointer inside
> >address_space, so the compiler must know the size.
> >
> >mmh... move the definition of the rb_root struct in linux/types.h? or
> >simply use a rb_root pointer. The (void *) looks a bit scary and too bug
> >prone.
> 
> Either way is fine. I did some black box testing of the patch
> (comparing noreuse vs dontneed) and it behaves as expected.
> 
> On a file copy, neither one pollutes the page cache. But if I run a
> random read benchmark on the source file right before and
> afterwards, page cache is warm with noreuse, but cold with dontneed.
> Copy performance was unaffected.
> 
> I can't really comment on the implementation details since I haven't
> reviewed it, but the functionality sounds useful.
> 
>  -Arun

Arun, thank you very much for your review and testing. Probably we'll
move to a different, memcg-based solution, so I don't think I'll post
another version of this patch set as is. In case, I'll apply one of
the workarounds for the rb_root attribute.

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
