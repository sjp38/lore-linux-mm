Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 118A76B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 06:56:54 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j14-v6so11754607pfn.11
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 03:56:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r7-v6sor212732ple.132.2018.06.12.03.56.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Jun 2018 03:56:53 -0700 (PDT)
Subject: Re: [PATCH 00/10] Control Flow Enforcement - Part (3)
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <bbfde1b3-5e1b-80e3-30e8-fd1e46a2ceb1@gmail.com>
Date: Tue, 12 Jun 2018 20:56:30 +1000
MIME-Version: 1.0
In-Reply-To: <20180607143807.3611-1-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>



On 08/06/18 00:37, Yu-cheng Yu wrote:
> This series introduces CET - Shadow stack
> 
> At the high level, shadow stack is:
> 
> 	Allocated from a task's address space with vm_flags VM_SHSTK;
> 	Its PTEs must be read-only and dirty;
> 	Fixed sized, but the default size can be changed by sys admin.
> 
> For a forked child, the shadow stack is duplicated when the next
> shadow stack access takes place.
> 
> For a pthread child, a new shadow stack is allocated.
> 
> The signal handler uses the same shadow stack as the main program.
> 

Even with sigaltstack()?


Balbir Singh.
