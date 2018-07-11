Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 27B786B0010
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 17:06:16 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id y2-v6so5812402pll.16
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 14:06:16 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id z125-v6si3867945pfz.10.2018.07.11.14.06.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 14:06:15 -0700 (PDT)
Message-ID: <1531342956.15351.38.camel@intel.com>
Subject: Re: [RFC PATCH v2 27/27] x86/cet: Add arch_prctl functions for CET
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 11 Jul 2018 14:02:36 -0700
In-Reply-To: <bbd9d3d7-a456-d161-6bc6-19e555edcd01@redhat.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-28-yu-cheng.yu@intel.com>
	 <bbd9d3d7-a456-d161-6bc6-19e555edcd01@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Wed, 2018-07-11 at 14:19 +0200, Florian Weimer wrote:
> On 07/11/2018 12:26 AM, Yu-cheng Yu wrote:
> > 
> > arch_prctl(ARCH_CET_DISABLE, unsigned long features)
> > A A A A A Disable SHSTK and/or IBT specified in 'features'.A A Return
> > -EPERM
> > A A A A A if CET is locked out.
> > 
> > arch_prctl(ARCH_CET_LOCK)
> > A A A A A Lock out CET feature.
> Isn't it a a??lock ina?? rather than a a??lock outa???

Yes, that makes more sense. A I will fix it.
