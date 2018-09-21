Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 80DCC8E0002
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 12:55:37 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id s18-v6so9586866wrw.22
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 09:55:37 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id y2-v6si29116583wrv.61.2018.09.21.09.55.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Sep 2018 09:55:36 -0700 (PDT)
Subject: Re: [RFC PATCH v4 23/27] mm/map: Add Shadow stack pages to memory
 accounting
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
 <20180921150351.20898-24-yu-cheng.yu@intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <8c18fabf-170f-9010-3075-238e34c9f09b@infradead.org>
Date: Fri, 21 Sep 2018 09:55:01 -0700
MIME-Version: 1.0
In-Reply-To: <20180921150351.20898-24-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 9/21/18 8:03 AM, Yu-cheng Yu wrote:
> Add shadow stack pages to memory accounting.
> Also check if the system has enough memory before enabling CET.
> 
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu.intel.com>

oops. typo above.

> ---
>  mm/mmap.c | 5 +++++
>  1 file changed, 5 insertions(+)


-- 
~Randy
