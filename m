Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1106B0036
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 20:45:49 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so3862930pab.20
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 17:45:48 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTP id ek3si8550488pbd.55.2014.01.30.17.45.47
        for <linux-mm@kvack.org>;
        Thu, 30 Jan 2014 17:45:48 -0800 (PST)
From: Jason Evans <je@fb.com>
Subject: Re: [PATCH v10 00/16] Volatile Ranges v10
Date: Fri, 31 Jan 2014 01:44:55 +0000
Message-ID: <CF103DE0.14877%je@fb.com>
In-Reply-To: <52EAFBF6.7020603@linaro.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8BCC5860534B7740B514F5A1A516E91F@fb.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, "pliard@google.com" <pliard@google.com>

On 1/30/14, 5:27 PM, "John Stultz" <john.stultz@linaro.org> wrote:
>I'm still not totally sure about, but willing to try
>* Page granular volatile tracking

In the malloc case (anonymous unused dirty memory), this would have very
similar characteristics to madvise(...MADV_FREE) as on e.g. FreeBSD, but
with the extra requirement that memory be marked nonvolatile prior to
reuse.  That wouldn't be terrible -- certainly an improvement over
madvise(...MADV_DONTNEED), but range-based volatile regions would actually
be an improvement over prior art, rather than a more cumbersome equivalent.

Either way, I'm really looking forward to being able to utilize volatile
ranges in jemalloc.

Thanks,
Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
