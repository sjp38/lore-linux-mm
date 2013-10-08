Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 69D606B0038
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 00:35:36 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so8152048pab.8
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 21:35:36 -0700 (PDT)
Received: by mail-qa0-f49.google.com with SMTP id i13so79979qae.15
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 21:35:33 -0700 (PDT)
Message-ID: <52538B95.6080208@gmail.com>
Date: Tue, 08 Oct 2013 00:35:33 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/14] vrange: Add new vrange(2) system call
References: <5253404D.2030503@linaro.org> <52534331.2060402@zytor.com> <52534692.7010400@linaro.org> <525347BE.7040606@zytor.com> <525349AE.1070904@linaro.org> <52534AEC.5040403@zytor.com> <20131008001306.GD25780@bbox> <52535EE1.3060700@zytor.com> <20131008020847.GH25780@bbox> <52537326.7000505@gmail.com> <20131008030736.GA29509@bbox>
In-Reply-To: <20131008030736.GA29509@bbox>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

(10/7/13 11:07 PM), Minchan Kim wrote:
> Hi KOSAKI,
>
> On Mon, Oct 07, 2013 at 10:51:18PM -0400, KOSAKI Motohiro wrote:
>>> Maybe, int madvise5(addr, length, MADV_DONTNEED|MADV_LAZY|MADV_SIGBUS,
>>>          &purged, &ret);
>>>
>>> Another reason to make it hard is that madvise(2) is tight coupled with
>>> with vmas split/merge. It needs mmap_sem's write-side lock and it hurt
>>> anon-vrange test performance much heavily and userland might want to
>>> make volatile range with small unit like "page size" so it's undesireable
>>> to make it with vma. Then, we should filter out to avoid vma split/merge
>>> in implementation if only MADV_LAZY case? Doable but it could make code
>>> complicated and lost consistency with other variant of madvise.
>>
>> I haven't seen your performance test result. Could please point out URLs?
>
> https://lkml.org/lkml/2013/3/12/105

It's not comparison with and without vma merge. I'm interest how much benefit
vmas operation avoiding have.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
