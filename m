Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 19DF16B0005
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 23:05:08 -0500 (EST)
Date: Wed, 6 Mar 2013 23:05:04 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1648837228.10483479.1362629104045.JavaMail.root@redhat.com>
In-Reply-To: <1543700056.10481632.1362628775559.JavaMail.root@redhat.com>
Subject: change of behavior for madvise in 3.9-rc1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Bisecting indicated that this commit,
1998cc048901109a29924380b8e91bc049b32951
mm: make madvise(MADV_WILLNEED) support swap file prefetch

Caused an LTP test failure,
http://goo.gl/1FVPy

madvise02    1  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
madvise02    2  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
madvise02    3  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
madvise02    4  TPASS  :  failed as expected: TEST_ERRNO=ENOMEM(12): Cannot allocate memory
madvise02    5  TFAIL  :  madvise succeeded unexpectedly

While it passed without the above commit
madvise02    1  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
madvise02    2  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
madvise02    3  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
madvise02    4  TPASS  :  failed as expected: TEST_ERRNO=ENOMEM(12): Cannot allocate memory
madvise02    5  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
