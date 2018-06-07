Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 971886B0008
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 14:49:14 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id e11-v6so3838004pgt.19
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 11:49:14 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 35-v6si20996337pla.543.2018.06.07.11.49.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 11:49:13 -0700 (PDT)
Received: from mail-wr0-f177.google.com (mail-wr0-f177.google.com [209.85.128.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2AF5E20895
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 18:49:13 +0000 (UTC)
Received: by mail-wr0-f177.google.com with SMTP id a12-v6so10893554wro.1
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 11:49:13 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143807.3611-1-yu-cheng.yu@intel.com> <20180607143807.3611-9-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143807.3611-9-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 7 Jun 2018 11:48:59 -0700
Message-ID: <CALCETrVX8nE6oFnJH7yZCydxtnC-VAhhnYs=ekJELc07a2UKiQ@mail.gmail.com>
Subject: Re: [PATCH 08/10] mm: Prevent mremap of shadow stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>

Please justify.  This seems actively harmful to me.
