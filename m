Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2574E6B025E
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 04:33:04 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id z203so340591wmc.18
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 01:33:04 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y14sor76868wmh.20.2017.09.28.01.33.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 01:33:03 -0700 (PDT)
Date: Thu, 28 Sep 2017 10:33:00 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv7 13/19] x86/mm: Make early boot code support boot-time
 switching of paging modes
Message-ID: <20170928083300.lxbnstw76hu3z746@gmail.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
 <20170918105553.27914-14-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170918105553.27914-14-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> Early boot code, that setup page table should be able to initialize page
> tables for both 4- and 5-level paging modes.

This sentence does not parse.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
