Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 121776B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 12:42:44 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id 6so2254396iti.4
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 09:42:44 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b204sor11470976itb.71.2018.02.16.09.42.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Feb 2018 09:42:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180216152608.1626885-1-arnd@arndb.de>
References: <20180216152608.1626885-1-arnd@arndb.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 16 Feb 2018 09:42:42 -0800
Message-ID: <CA+55aFxRo=X3_fb5JC55JjWt8KOWAdaMaBt5k5VPZhosT25WpQ@mail.gmail.com>
Subject: Re: [PATCH] mm: hide a #warning for COMPILE_TEST
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable <stable@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Jiang <dave.jiang@intel.com>, Jan Kara <jack@suse.cz>, Ingo Molnar <mingo@kernel.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Huang Ying <ying.huang@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Tobin C Harding <me@tobin.cc>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Feb 16, 2018 at 7:25 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>
> The warning is reasonable by itself, but gets in the way of
> randconfig build testing, so I'm hiding it whenever CONFIG_COMPILE_TEST
> is set.

Ack, looks sane, so I just applied it directly to my tree instead of
waiting for this to get back to me from Andrew ;)

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
