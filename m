Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF2E56B000C
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 07:13:04 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o18-v6so14396119qtm.11
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 04:13:04 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 135-v6si6658287qkh.385.2018.07.11.04.13.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 04:13:03 -0700 (PDT)
Subject: Re: [RFC PATCH v2 20/27] x86/cet/shstk: ELF header parsing of CET
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-21-yu-cheng.yu@intel.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <10c224e9-933a-20d8-a286-5065a6cb10f1@redhat.com>
Date: Wed, 11 Jul 2018 13:12:57 +0200
MIME-Version: 1.0
In-Reply-To: <20180710222639.8241-21-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 07/11/2018 12:26 AM, Yu-cheng Yu wrote:
> +	/*
> +	 * PT_NOTE segment is small.  Read at most
> +	 * PAGE_SIZE.
> +	 */
> +	if (note_size > PAGE_SIZE)
> +		note_size = PAGE_SIZE;

That's not really true.  There are some huge PT_NOTE segments out there.

Why can't you check the notes after the executable has been mapped?

Thanks,
Florian
