Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 28A1F6B0003
	for <linux-mm@kvack.org>; Sun, 18 Mar 2018 22:37:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j12so8753314pff.18
        for <linux-mm@kvack.org>; Sun, 18 Mar 2018 19:37:04 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 197si8874901pge.78.2018.03.18.19.37.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Mar 2018 19:37:03 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH] mm: add config for readahead window
References: <20180316182512.118361-1-wvw@google.com>
	<CAGXk5yoVMd9B=nvob7s=niCAQ9oHAX84eupF9Eet_dAk7WTStg@mail.gmail.com>
Date: Mon, 19 Mar 2018 10:36:58 +0800
In-Reply-To: <CAGXk5yoVMd9B=nvob7s=niCAQ9oHAX84eupF9Eet_dAk7WTStg@mail.gmail.com>
	(Wei Wang's message of "Fri, 16 Mar 2018 18:49:08 +0000")
Message-ID: <87zi34zt85.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wvw@google.com>
Cc: gregkh@linuxfoundation.org, Todd Poynor <toddpoynor@google.com>, Wei Wang <wei.vince.wang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@kernel.org>, Sherry Cheung <SCheung@nvidia.com>, Oliver
 O'Halloran <oohall@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dennis Zhou <dennisz@fb.com>, Pavel
 Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Wei Wang <wvw@google.com> writes:

> Android devices boot time benefits by bigger readahead window setting from
> init. This patch will make readahead window a config so early boot can
> benefit by it as well.

Can you change the source code of init to call ioctl(BLKRASET) early?

Best Regards,
Huang, Ying
