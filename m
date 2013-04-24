Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 1EB686B0033
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 19:13:23 -0400 (EDT)
Date: Wed, 24 Apr 2013 19:13:08 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1366845188-h0p3gpna-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1366844735-kqynvvnu-mutt-n-horiguchi@ah.jp.nec.com>
References: <bug-56881-27@https.bugzilla.kernel.org/>
 <20130423132522.042fa8d27668bbca6a410a92@linux-foundation.org>
 <20130424081454.GA13994@cmpxchg.org>
 <1366816599-7fr82iw1-mutt-n-horiguchi@ah.jp.nec.com>
 <20130424153951.GQ2018@cmpxchg.org>
 <1366844735-kqynvvnu-mutt-n-horiguchi@ah.jp.nec.com>
Subject: Re: [Bug 56881] New: MAP_HUGETLB mmap fails for certain sizes
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, iceman_dvd@yahoo.com, Steven Truelove <steven.truelove@utoronto.ca>

On Wed, Apr 24, 2013 at 07:05:35PM -0400, Naoya Horiguchi wrote:
...
> diff --git a/ipc/shm.c b/ipc/shm.c
> index cb858df..e2cb809 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -494,7 +494,7 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
>  		/* hugetlb_file_setup applies strict accounting */
>  		if (shmflg & SHM_NORESERVE)
>  			acctflag = VM_NORESERVE;
> -		file = hugetlb_file_setup(name, 0, size, acctflag,
> +		file = hugetlb_file_setup(name, NULL, acctflag,
>  				  &shp->mlock_user, HUGETLB_SHMFS_INODE,
>  				(shmflg >> SHM_HUGE_SHIFT) & SHM_HUGE_MASK);
>  	} else {

Ugh, NULL is not correct, it should be &size.
But anyway, I want your comment, and after that I'll repost with fixing this.

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
