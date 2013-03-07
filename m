Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 44CA56B0006
	for <linux-mm@kvack.org>; Thu,  7 Mar 2013 13:50:30 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id up1so564800pbc.23
        for <linux-mm@kvack.org>; Thu, 07 Mar 2013 10:50:29 -0800 (PST)
Date: Thu, 7 Mar 2013 10:49:48 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: change of behavior for madvise in 3.9-rc1
In-Reply-To: <20130307043938.GA4393@kernel.org>
Message-ID: <alpine.LNX.2.00.1303071042390.6087@eggly.anvils>
References: <1543700056.10481632.1362628775559.JavaMail.root@redhat.com> <1648837228.10483479.1362629104045.JavaMail.root@redhat.com> <20130307043938.GA4393@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: CAI Qian <caiqian@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, 7 Mar 2013, Shaohua Li wrote:
> On Wed, Mar 06, 2013 at 11:05:04PM -0500, CAI Qian wrote:
> > Bisecting indicated that this commit,
> > 1998cc048901109a29924380b8e91bc049b32951
> > mm: make madvise(MADV_WILLNEED) support swap file prefetch
> > 
> > Caused an LTP test failure,
> > http://goo.gl/1FVPy
> > 
> > madvise02    1  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
> > madvise02    2  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
> > madvise02    3  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
> > madvise02    4  TPASS  :  failed as expected: TEST_ERRNO=ENOMEM(12): Cannot allocate memory
> > madvise02    5  TFAIL  :  madvise succeeded unexpectedly
> > 
> > While it passed without the above commit
> > madvise02    1  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
> > madvise02    2  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
> > madvise02    3  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
> > madvise02    4  TPASS  :  failed as expected: TEST_ERRNO=ENOMEM(12): Cannot allocate memory
> > madvise02    5  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
> 
> I thought this is expected behavior. madvise(MADV_WILLNEED) to anonymous memory
> doesn't return -EBADF now, as now we support swap prefretch.

I agree with Shaohua: although the kernel strives for back-compatibility
with userspace, I don't think that goes so far as to tell an arbitrary LTP
test that it has failed, once the kernel has been enhanced to support new
functionality.  We could never add or extend system calls if that were so.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
