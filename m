Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F31018E0025
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:54:20 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b69-v6so7143537pfc.20
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:54:20 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id e7-v6si29105340pge.42.2018.09.21.15.54.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 15:54:19 -0700 (PDT)
Subject: Re: [RFC PATCH v4 00/27] Control Flow Enforcement: Shadow Stack
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <1ca5178d-60f3-ae70-ce95-7026ac0429b4@linux.intel.com>
Date: Fri, 21 Sep 2018 15:53:08 -0700
MIME-Version: 1.0
In-Reply-To: <20180921150351.20898-1-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 09/21/2018 08:03 AM, Yu-cheng Yu wrote:
> The previous version of CET patches can be found in the following
> link:
> 
>   https://lkml.org/lkml/2018/8/30/608

So, this is an RFC, but there no mention of what you want comments *on*. :)

What do you want folks to review?  What needs to get settled before this
is merged?
