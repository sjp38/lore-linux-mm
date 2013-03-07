Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 92E466B0005
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 23:39:47 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fb1so138321pad.25
        for <linux-mm@kvack.org>; Wed, 06 Mar 2013 20:39:46 -0800 (PST)
Date: Thu, 7 Mar 2013 12:39:38 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: change of behavior for madvise in 3.9-rc1
Message-ID: <20130307043938.GA4393@kernel.org>
References: <1543700056.10481632.1362628775559.JavaMail.root@redhat.com>
 <1648837228.10483479.1362629104045.JavaMail.root@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1648837228.10483479.1362629104045.JavaMail.root@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Mar 06, 2013 at 11:05:04PM -0500, CAI Qian wrote:
> Bisecting indicated that this commit,
> 1998cc048901109a29924380b8e91bc049b32951
> mm: make madvise(MADV_WILLNEED) support swap file prefetch
> 
> Caused an LTP test failure,
> http://goo.gl/1FVPy
> 
> madvise02    1  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
> madvise02    2  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
> madvise02    3  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
> madvise02    4  TPASS  :  failed as expected: TEST_ERRNO=ENOMEM(12): Cannot allocate memory
> madvise02    5  TFAIL  :  madvise succeeded unexpectedly
> 
> While it passed without the above commit
> madvise02    1  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
> madvise02    2  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
> madvise02    3  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
> madvise02    4  TPASS  :  failed as expected: TEST_ERRNO=ENOMEM(12): Cannot allocate memory
> madvise02    5  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor

I thought this is expected behavior. madvise(MADV_WILLNEED) to anonymous memory
doesn't return -EBADF now, as now we support swap prefretch.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
