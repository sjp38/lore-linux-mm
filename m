Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0E0FB6B0005
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 13:56:27 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x17-v6so423447pfm.18
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 10:56:27 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id z190-v6si29096785pgd.646.2018.06.07.10.56.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 10:56:26 -0700 (PDT)
Subject: Re: [PATCH 01/10] x86/cet: User-mode shadow stack support
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
 <20180607143807.3611-2-yu-cheng.yu@intel.com>
 <CALCETrX4ALKbphJiZs4MXWtRFvQYD905bNAMTogbOeLh0Pp6xw@mail.gmail.com>
 <1528393611.4636.70.camel@2b52.sc.intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <67d8a813-b46a-d1da-3897-c38dd5b46b8e@linux.intel.com>
Date: Thu, 7 Jun 2018 10:55:04 -0700
MIME-Version: 1.0
In-Reply-To: <1528393611.4636.70.camel@2b52.sc.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, Andy Lutomirski <luto@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On 06/07/2018 10:46 AM, Yu-cheng Yu wrote:
>> Also, did you add all the needed checks to make get_user_pages(),
>> access_process_vm(), etc fail when called on the shadow stack?  (Or at
>> least fail if they're requesting write access and the FORCE bit isn't
>> set.)
> Currently if FORCE bit is set, these functions can write to shadow
> stack, otherwise write access will fail.  I will test it.

Is this a part of your selftests/ for this feature?
