Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A64CC6B0010
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 13:00:14 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id q18-v6so15303396pll.3
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 10:00:14 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id f11-v6si437577pgk.403.2018.07.11.10.00.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 10:00:13 -0700 (PDT)
Message-ID: <1531328187.13297.35.camel@intel.com>
Subject: Re: [RFC PATCH v2 23/27] mm/mmap: Add IBT bitmap size to address
 space limit check
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 11 Jul 2018 09:56:27 -0700
In-Reply-To: <7cdadb28-a9aa-550b-9e31-30691b64b504@linux.intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-24-yu-cheng.yu@intel.com>
	 <7cdadb28-a9aa-550b-9e31-30691b64b504@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter
 Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, 2018-07-10 at 16:57 -0700, Dave Hansen wrote:
> On 07/10/2018 03:26 PM, Yu-cheng Yu wrote:
> > 
> > The indirect branch tracking legacy bitmap takes a large address
> > space.A A This causes may_expand_vm() failure on the address limit
> > check.A A For a IBT-enabled task, add the bitmap size to the
> > address limit.
> This appears to require that we set up
> current->thread.cet.ibt_bitmap_size _before_ calling may_expand_vm().
> What keeps the ibt_mmap() itself from hitting the address limit?

Yes, that is overlooked. A I will fix it.

Thanks,
Yu-cheng
