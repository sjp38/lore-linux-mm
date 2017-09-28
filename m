Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3F46B025E
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 04:36:15 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id y83so359343wmc.2
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 01:36:15 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d20sor59850wmi.74.2017.09.28.01.36.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 01:36:14 -0700 (PDT)
Date: Thu, 28 Sep 2017 10:36:11 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv7 00/19] Boot-time switching between 4- and 5-level
 paging for 4.15
Message-ID: <20170928083611.2oynrcco23e2ofu7@gmail.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


A general patch flow request: please only send a maximum of 5-7 patches in the 
next round, to make it all easier to review and handle.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
