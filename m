Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id DEDB86B0031
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 12:23:19 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so8988184pdi.28
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 09:23:19 -0700 (PDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so8931936pbb.27
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 09:23:17 -0700 (PDT)
Message-ID: <5254315C.70401@linaro.org>
Date: Tue, 08 Oct 2013 09:22:52 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 07/14] vrange: Purge volatile pages when memory is tight
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org> <1380761503-14509-8-git-send-email-john.stultz@linaro.org> <CAHz2CGWS+jWQU=v=5AnAgab1DrPr+snWvc62mf43Tx0aQUA8nA@mail.gmail.com>
In-Reply-To: <CAHz2CGWS+jWQU=v=5AnAgab1DrPr+snWvc62mf43Tx0aQUA8nA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhan Jianyu <nasa4836@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 10/07/2013 08:27 PM, Zhan Jianyu wrote:
> On Thu, Oct 3, 2013 at 8:51 AM, John Stultz <john.stultz@linaro.org> wrote:
>>  static inline int page_referenced(struct page *page, int is_locked,
>>                                   struct mem_cgroup *memcg,
>> -                                 unsigned long *vm_flags)
>> +                                 unsigned long *vm_flags,
>> +                                 int *is_vrange)
>>  {
>>         *vm_flags = 0;
>> +       *is_vrange = 0;
>>         return 0;
>>  }
> I don't know if it is appropriate to add a parameter in such a  core
> function for an optional functionality. Maybe the is_vrange flag
> should be squashed into the vm_flags ? I am not sure .
Yea, this wasn't either Minchan or I were particularly fond of, but with
the vm_flags exausted, there wasn't a clear way to do so without doing
the rmap traversal again.

Other suggestions?  Extending the vm_flags to 64bits is something many
better mm devs have tried to merge unsuccessfully, so I'm hesitant to
try pushing it myself.

thanks
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
