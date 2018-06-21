Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 355556B0005
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 09:05:22 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id h81-v6so1814336wmf.6
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 06:05:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d11-v6sor2519823wrq.64.2018.06.21.06.05.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Jun 2018 06:05:15 -0700 (PDT)
Date: Thu, 21 Jun 2018 15:05:11 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 5/5] Documentation/x86: Add CET description
Message-ID: <20180621130511.GA7895@gmail.com>
References: <20180607143544.3477-1-yu-cheng.yu@intel.com>
 <20180607143544.3477-6-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180607143544.3477-6-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>


* Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:

> +Control Flow Enforcement Technology (CET) provides protection against
> +return/jump-oriented programing (ROP) attacks.

So the obvious abbreviation would be CFT or CFET.

Exactly why is 'CET' used, which not only has very little to do with what it's 
supposed to mean, but is also a well-known timezone, Central European Time?

Thanks,

	Ingo
