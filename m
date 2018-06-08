Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E71236B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 21:20:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a13-v6so5331853pfo.22
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 18:20:38 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 1-v6si54779635ply.226.2018.06.07.18.20.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 18:20:37 -0700 (PDT)
Subject: Re: [PATCH 6/9] x86/mm: Introduce ptep_set_wrprotect_flush and
 related functions
References: <20180607143705.3531-1-yu-cheng.yu@intel.com>
 <20180607143705.3531-7-yu-cheng.yu@intel.com>
 <CALCETrVa8MtxP9iqYkZLnetaQiN4UaWb=jGz1+rLsCuETHKydg@mail.gmail.com>
 <5c39caf1-2198-3c2b-b590-8c38a525747f@linux.intel.com>
 <CALCETrU7uNpSp8DWKnpH28wHE3JOeXkmp-H97n2nWHJEu4pDEA@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <ace8e8c2-3e0e-70fc-69f2-2aa22c5e4aa9@linux.intel.com>
Date: Thu, 7 Jun 2018 18:20:36 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrU7uNpSp8DWKnpH28wHE3JOeXkmp-H97n2nWHJEu4pDEA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On 06/07/2018 05:59 PM, Andy Lutomirski wrote:
> Can you ask the architecture folks to clarify the situation?  And, if
> your notes are indeed correct, don't we need code to handle spurious
> faults?

I'll double check that I didn't misunderstand the situation and that it
has not changed on processors with shadow stacks.

But, as far as spurious faults, wouldn't it just be a fault because
we've transiently gone to Present=0?  We already do that when clearing
the Dirty bit, so I'm not sure that's new.  We surely already handle
that one.
