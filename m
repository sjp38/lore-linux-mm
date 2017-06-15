Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id B43426B0292
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 13:19:59 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id 82so2042523vki.3
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 10:19:59 -0700 (PDT)
Received: from mail-ua0-x22d.google.com (mail-ua0-x22d.google.com. [2607:f8b0:400c:c08::22d])
        by mx.google.com with ESMTPS id j70si79vki.192.2017.06.15.10.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 10:19:58 -0700 (PDT)
Received: by mail-ua0-x22d.google.com with SMTP id q15so12236639uaa.2
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 10:19:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <be2440e4f5fd1c8cf30c8f636492aa18@airmail.cc>
References: <1497544976-7856-1-git-send-email-s.mesoraca16@gmail.com>
 <1497544976-7856-8-git-send-email-s.mesoraca16@gmail.com> <be2440e4f5fd1c8cf30c8f636492aa18@airmail.cc>
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Date: Thu, 15 Jun 2017 19:19:57 +0200
Message-ID: <CAJHCu1J6ntpqiFT=-vbDwOHHxsjHN4bf1v2eXrkVf2PxQb6jJg@mail.gmail.com>
Subject: Re: [kernel-hardening] [RFC v2 7/9] Trampoline emulation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aconcernedfossdev@airmail.cc
Cc: kernel list <linux-kernel@vger.kernel.org>, linux-security-module@vger.kernel.org, Kernel Hardening <kernel-hardening@lists.openwall.com>, Brad Spengler <spender@grsecurity.net>, PaX Team <pageexec@freemail.hu>, Casey Schaufler <casey@schaufler-ca.com>, Kees Cook <keescook@chromium.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-mm@kvack.org, x86@kernel.org, Jann Horn <jannh@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

2017-06-15 18:47 GMT+02:00  <aconcernedfossdev@airmail.cc>:
> Thanks for doing this porting work. Look forward to using GRSecurity/PAX
> features on ARM eventually. ARM's taking over as we know. x86 is almost
> done.

Do you have any suggestion about potential use of trampoline emulation on ARM?
Thank you for your comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
