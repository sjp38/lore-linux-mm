Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id BEB3F6B0039
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 23:28:40 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so8027368pde.24
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 20:28:40 -0700 (PDT)
Received: by mail-ie0-f180.google.com with SMTP id u16so17812417iet.39
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 20:28:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1380761503-14509-8-git-send-email-john.stultz@linaro.org>
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org> <1380761503-14509-8-git-send-email-john.stultz@linaro.org>
From: Zhan Jianyu <nasa4836@gmail.com>
Date: Tue, 8 Oct 2013 11:27:57 +0800
Message-ID: <CAHz2CGWS+jWQU=v=5AnAgab1DrPr+snWvc62mf43Tx0aQUA8nA@mail.gmail.com>
Subject: Re: [PATCH 07/14] vrange: Purge volatile pages when memory is tight
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Oct 3, 2013 at 8:51 AM, John Stultz <john.stultz@linaro.org> wrote:
>  static inline int page_referenced(struct page *page, int is_locked,
>                                   struct mem_cgroup *memcg,
> -                                 unsigned long *vm_flags)
> +                                 unsigned long *vm_flags,
> +                                 int *is_vrange)
>  {
>         *vm_flags = 0;
> +       *is_vrange = 0;
>         return 0;
>  }

I don't know if it is appropriate to add a parameter in such a  core
function for an optional functionality. Maybe the is_vrange flag
should be squashed into the vm_flags ? I am not sure .




--

Regards,
Zhan Jianyu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
