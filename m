Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D5D686B000C
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 11:39:02 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id z20-v6so3631238pgv.17
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 08:39:02 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t12-v6si21851128pgp.565.2018.06.07.08.39.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 08:39:00 -0700 (PDT)
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2C7EA208AC
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 15:39:00 +0000 (UTC)
Received: by mail-io0-f172.google.com with SMTP id r24-v6so12310746ioh.9
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 08:39:00 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143544.3477-1-yu-cheng.yu@intel.com> <20180607143544.3477-3-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143544.3477-3-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 7 Jun 2018 08:38:47 -0700
Message-ID: <CALCETrXAx4vBUxf3VaePNm3HHLZkdTFAR9TV0T+A-jb2QL7Uag@mail.gmail.com>
Subject: Re: [PATCH 2/5] x86/fpu/xstate: Change some names to separate XSAVES
 system and user states
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 7:40 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> To support XSAVES system states, change some names to distinguish
> user and system states.
>
> Change:
>   supervisor to system
>   copy_init_fpstate_to_fpregs() to copy_init_fpstate_user_settings_to_fpregs()
>   xfeatures_mask to xfeatures_mask_user
>   XCNTXT_MASK to SUPPORTED_XFEATURES_MASK (states supported)

How about copy_init_user_fpstate_to_fpregs()?  It's shorter and more
to the point.

--Andy
