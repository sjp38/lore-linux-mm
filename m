Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 449616B0279
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 20:10:45 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 140-v6so11282072iou.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 17:10:45 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id f196-v6si2286241itc.17.2018.06.08.17.10.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Jun 2018 17:10:44 -0700 (PDT)
Subject: Re: [PATCH 5/5] Documentation/x86: Add CET description
References: <20180607143544.3477-1-yu-cheng.yu@intel.com>
 <20180607143544.3477-6-yu-cheng.yu@intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <0c91f979-85e1-6deb-9570-9749c8eaf15b@infradead.org>
Date: Fri, 8 Jun 2018 17:10:13 -0700
MIME-Version: 1.0
In-Reply-To: <20180607143544.3477-6-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>

On 06/07/2018 07:35 AM, Yu-cheng Yu wrote:
> Explain how CET works and the noshstk/noibt kernel parameters.
> 
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  Documentation/admin-guide/kernel-parameters.txt |   6 +
>  Documentation/x86/intel_cet.txt                 | 161 ++++++++++++++++++++++++
>  2 files changed, 167 insertions(+)
>  create mode 100644 Documentation/x86/intel_cet.txt
> 

> diff --git a/Documentation/x86/intel_cet.txt b/Documentation/x86/intel_cet.txt
> new file mode 100644
> index 000000000000..1b902a6c49f4
> --- /dev/null
> +++ b/Documentation/x86/intel_cet.txt
> @@ -0,0 +1,161 @@
> +-----------------------------------------
> +Control Flow Enforcement Technology (CET)
> +-----------------------------------------
> +
> +[1] Overview
> +
> +Control Flow Enforcement Technology (CET) provides protection against
> +return/jump-oriented programing (ROP) attacks.  It can be implemented to

                        programming

> +protect both the kernel and applications.  In the first phase, only the
> +user-mode protection is implemented for the 64-bit kernel.  Thirty-two bit
> +applications are supported under the compatibility mode.
> +
> +CET includes shadow stack (SHSTK) and indirect branch tracking (IBT) and
> +they are enabled from two kernel configuration options:
> +
> +  INTEL_X86_SHADOW_STACK_USER, and

no comma.

> +  INTEL_X86_BRANCH_TRACKING_USER.
> +
> +There are two command-line options for disabling CET features:
> +
> +  noshstk - disables shadow stack, and
> +  noibt - disables indirect branch tracking.
> +
> +At run time, /proc/cpuinfo shows the availability of SHSTK and IBT.
> +

[snip]


thanks,
-- 
~Randy
