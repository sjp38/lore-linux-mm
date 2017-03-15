Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 988C56B0038
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 05:01:10 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id z13so21168926iof.7
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 02:01:10 -0700 (PDT)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id w75si13039537itc.32.2017.03.15.02.01.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 02:01:09 -0700 (PDT)
Received: by mail-it0-x241.google.com with SMTP id r141so2472362ita.1
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 02:01:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <58C866B6.4040800@cs.rutgers.edu>
References: <201703150534.RFh2ClRg%fengguang.wu@intel.com> <58C866B6.4040800@cs.rutgers.edu>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 15 Mar 2017 10:01:08 +0100
Message-ID: <CAMuHMdXQqdZpvtv9un8AoNu-9D5Aq+ZdoPjTrCqka1afi5RQsA@mail.gmail.com>
Subject: Re: [PATCH v4 05/11] mm: thp: enable thp migration in generic path
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: kbuild test robot <lkp@intel.com>, "kbuild-all@01.org" <kbuild-all@01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, dnellans@nvidia.com

On Tue, Mar 14, 2017 at 10:55 PM, Zi Yan <zi.yan@cs.rutgers.edu> wrote:
>>>> include/linux/swapops.h:223:2: warning: missing braces around initializer [-Wmissing-braces]
>>      return (pmd_t){ 0 };
>>      ^
>>    include/linux/swapops.h:223:2: warning: (near initialization for '(anonymous).pmd') [-Wmissing-braces]
>
> I do not have any warning with gcc 6.3.0. This seems to be a GCC bug
> (https://gcc.gnu.org/bugzilla/show_bug.cgi?id=53119).

I guess you need

    return (pmd_t) { { 0, }};

to kill the warning.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
