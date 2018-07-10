Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0987E6B027D
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 19:57:44 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id s16-v6so13426781plr.22
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 16:57:43 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id z20-v6si20044320pfj.337.2018.07.10.16.57.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 16:57:43 -0700 (PDT)
Subject: Re: [RFC PATCH v2 23/27] mm/mmap: Add IBT bitmap size to address
 space limit check
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-24-yu-cheng.yu@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <7cdadb28-a9aa-550b-9e31-30691b64b504@linux.intel.com>
Date: Tue, 10 Jul 2018 16:57:39 -0700
MIME-Version: 1.0
In-Reply-To: <20180710222639.8241-24-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 07/10/2018 03:26 PM, Yu-cheng Yu wrote:
> The indirect branch tracking legacy bitmap takes a large address
> space.  This causes may_expand_vm() failure on the address limit
> check.  For a IBT-enabled task, add the bitmap size to the
> address limit.

This appears to require that we set up
current->thread.cet.ibt_bitmap_size _before_ calling may_expand_vm().
What keeps the ibt_mmap() itself from hitting the address limit?
