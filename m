Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD4166B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 13:02:51 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id i27so313513542qte.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 10:02:51 -0700 (PDT)
Received: from mail-yw0-x22e.google.com (mail-yw0-x22e.google.com. [2607:f8b0:4002:c05::22e])
        by mx.google.com with ESMTPS id s7si2043063qtc.72.2016.08.02.10.02.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 10:02:51 -0700 (PDT)
Received: by mail-yw0-x22e.google.com with SMTP id z8so203892581ywa.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 10:02:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <476DC76E7D1DF2438D32BFADF679FC5601276FB4@ORSMSX103.amr.corp.intel.com>
References: <1469557346-5534-1-git-send-email-william.c.roberts@intel.com>
 <1469557346-5534-2-git-send-email-william.c.roberts@intel.com>
 <20160726200309.GJ4541@io.lakedaemon.net> <476DC76E7D1DF2438D32BFADF679FC560125F29C@ORSMSX103.amr.corp.intel.com>
 <20160726205944.GM4541@io.lakedaemon.net> <CAFJ0LnEZW7Y1zfN8v0_ckXQZn1n-UKEhf_tSmNOgHwrrnNnuMg@mail.gmail.com>
 <476DC76E7D1DF2438D32BFADF679FC5601276FB4@ORSMSX103.amr.corp.intel.com>
From: Nick Kralevich <nnk@google.com>
Date: Tue, 2 Aug 2016 10:02:49 -0700
Message-ID: <CAFJ0LnF7GGCk0LaJXQtBP9sROM3S3+d6hJ=1SjjgwpBcfGqJ1g@mail.gmail.com>
Subject: Re: [PATCH] [RFC] Introduce mmap randomization
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Roberts, William C" <william.c.roberts@intel.com>
Cc: Jason Cooper <jason@lakedaemon.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "keescook@chromium.org" <keescook@chromium.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "jeffv@google.com" <jeffv@google.com>, "salyzyn@android.com" <salyzyn@android.com>, "dcashman@android.com" <dcashman@android.com>

On Tue, Aug 2, 2016 at 9:57 AM, Roberts, William C
<william.c.roberts@intel.com> wrote:
> @nnk, disabling ASLR via set_arch() on Android, is that only for 32 bit address spaces where
> you had that problem?

Yes. Only 32 bit address spaces had the fragmentation problem.

-- 
Nick Kralevich | Android Security | nnk@google.com | 650.214.4037

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
