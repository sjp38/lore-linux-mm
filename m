Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 530816B053E
	for <linux-mm@kvack.org>; Thu, 17 May 2018 16:53:52 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id u13-v6so2394911lff.0
        for <linux-mm@kvack.org>; Thu, 17 May 2018 13:53:52 -0700 (PDT)
Received: from smtp.ispras.ru (bran.ispras.ru. [83.149.199.196])
        by mx.google.com with ESMTP id w62-v6si2645666lfk.223.2018.05.17.13.53.50
        for <linux-mm@kvack.org>;
        Thu, 17 May 2018 13:53:50 -0700 (PDT)
Date: Thu, 17 May 2018 23:53:05 +0300 (MSK)
From: Alexander Monakov <amonakov@ispras.ru>
Subject: Re: [4.11 Regression] 64-bit process gets AT_BASE in the first 4 GB
 if exec'ed from 32-bit process
In-Reply-To: <CALCETrWRfW2jrDDp6SGb62tpHykK7U-fWmdxtK15LMWL_Gkqqw@mail.gmail.com>
Message-ID: <alpine.LNX.2.20.13.1805172349210.5460@monopod.intra.ispras.ru>
References: <82328ad006ebacb399d04d638f8dad4a@ispras.ru> <CALCETrWRfW2jrDDp6SGb62tpHykK7U-fWmdxtK15LMWL_Gkqqw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: izbyshev@ispras.ru, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux-MM <linux-mm@kvack.org>

On Thu, 17 May 2018, Andy Lutomirski wrote:
> It's definitely not intended.  Can you confirm that the problem still
> exists in 4.16?  I have some vague recollection that this was a known issue
> that got fixed, and we could plausibly just be missing a backport.

I could reproduce it on 4.16.0 on my laptop.

Alexander
