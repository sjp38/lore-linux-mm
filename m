Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id D449D6B0044
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 17:30:45 -0400 (EDT)
Received: from /spool/local
	by e3.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <john.stultz@linaro.org>;
	Tue, 9 Oct 2012 17:30:44 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q99LUBeG155868
	for <linux-mm@kvack.org>; Tue, 9 Oct 2012 17:30:11 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q99LU8up005065
	for <linux-mm@kvack.org>; Tue, 9 Oct 2012 17:30:10 -0400
Message-ID: <5074975B.20809@linaro.org>
Date: Tue, 09 Oct 2012 14:30:03 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Volatile Ranges (v7) & Lots of words
References: <1348888593-23047-1-git-send-email-john.stultz@linaro.org> <20121009080735.GA24375@glandium.org>
In-Reply-To: <20121009080735.GA24375@glandium.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Hommey <mh@glandium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 10/09/2012 01:07 AM, Mike Hommey wrote:
> Note it doesn't have to be a vs. situation. madvise could be an
> additional way to interface with volatile ranges on a given fd.
>
> That is, madvise doesn't have to mean anonymous memory. As a matter of
> fact, MADV_WILLNEED/MADV_DONTNEED are usually used on mmaped files.
> Similarly, there could be a way to use madvise to mark volatile ranges,
> without the application having to track what memory ranges are
> associated to what part of what file, which the kernel already tracks.

Good point. We could add madvise() interface, but limit it only to 
mmapped tmpfs files, in parallel with the fallocate() interface.

However, I would like to think through how MADV_MARK_VOLATILE with 
purely anonymous memory could work, before starting that approach. That 
and Neil's point that having an identical kernel interface restricted to 
tmpfs, only as a convenience to userland in switching from virtual 
address to/from mmapped file offset may be better left to a userland 
library.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
