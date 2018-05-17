Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A3F8D6B053A
	for <linux-mm@kvack.org>; Thu, 17 May 2018 16:46:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b64-v6so3360463pfl.13
        for <linux-mm@kvack.org>; Thu, 17 May 2018 13:46:32 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p9-v6si5714629plo.208.2018.05.17.13.46.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 13:46:31 -0700 (PDT)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E6BB620858
	for <linux-mm@kvack.org>; Thu, 17 May 2018 20:46:30 +0000 (UTC)
Received: by mail-wm0-f45.google.com with SMTP id o78-v6so11460586wmg.0
        for <linux-mm@kvack.org>; Thu, 17 May 2018 13:46:30 -0700 (PDT)
MIME-Version: 1.0
References: <82328ad006ebacb399d04d638f8dad4a@ispras.ru>
In-Reply-To: <82328ad006ebacb399d04d638f8dad4a@ispras.ru>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 17 May 2018 13:46:17 -0700
Message-ID: <CALCETrWRfW2jrDDp6SGb62tpHykK7U-fWmdxtK15LMWL_Gkqqw@mail.gmail.com>
Subject: Re: [4.11 Regression] 64-bit process gets AT_BASE in the first 4 GB
 if exec'ed from 32-bit process
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: izbyshev@ispras.ru
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Lutomirski <luto@kernel.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Monakov <amonakov@ispras.ru>, Linux-MM <linux-mm@kvack.org>

On Thu, May 17, 2018 at 1:25 PM Alexey Izbyshev <izbyshev@ispras.ru> wrote:

> Hello everyone,

> I've discovered the following strange behavior of a 4.15.13-based kernel
> (bisected to


https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=1b028f784e8c341e762c264f70dc0ca1418c8b7a
> between 4.11-rc2 and -rc3 thanks to Alexander Monakov).


It's definitely not intended.  Can you confirm that the problem still
exists in 4.16?  I have some vague recollection that this was a known issue
that got fixed, and we could plausibly just be missing a backport.
