Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id BD4256B0007
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 00:55:54 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id d52-v6so4065504qta.9
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 21:55:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e41-v6si133393qtc.139.2018.10.02.21.55.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 21:55:53 -0700 (PDT)
Date: Wed, 3 Oct 2018 06:56:11 +0200
From: Eugene Syromiatnikov <esyr@redhat.com>
Subject: Re: [RFC PATCH v4 24/27] mm/mmap: Create a guard area between VMAs
Message-ID: <20181003045611.GB22724@asgard.redhat.com>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
 <20180921150351.20898-25-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180921150351.20898-25-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Fri, Sep 21, 2018 at 08:03:48AM -0700, Yu-cheng Yu wrote:
> Create a guard area between VMAs, to detect memory corruption.

Do I understand correctly that with this patch a user space program
no longer be able to place two mappings back to back? If it is so,
it will likely break a lot of things; for example, it's a common ring
buffer implementations technique, to map buffer memory twice back
to back in order to avoid special handling of items wrapping its end.
