Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D954B280255
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 19:49:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 21so193511595pfy.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 16:49:02 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id g2si4379781pav.59.2016.09.22.16.49.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 16:49:02 -0700 (PDT)
From: "Chen, Tim C" <tim.c.chen@intel.com>
Subject: RE: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping
 out
Date: Thu, 22 Sep 2016 23:49:00 +0000
Message-ID: <045D8A5597B93E4EBEDDCBF1FC15F50935C1AD83@fmsmsx104.amr.corp.intel.com>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
 <20160922225608.GA3898@kernel.org>
In-Reply-To: <20160922225608.GA3898@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>, "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, "Lu, Aaron" <aaron.lu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

>
>So this is impossible without THP swapin. While 2M swapout makes a lot of
>sense, I doubt 2M swapin is really useful. What kind of application is 'op=
timized'
>to do sequential memory access?

We waste a lot of cpu cycles to re-compact 4K pages back to a large page
under THP.  Swapping it back in as a single large page can avoid
fragmentation and this overhead.

Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
