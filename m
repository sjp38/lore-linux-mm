Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3426C6B0253
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 14:40:19 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id c1so22546034lbw.0
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 11:40:19 -0700 (PDT)
Received: from mail-lb0-x22b.google.com (mail-lb0-x22b.google.com. [2a00:1450:4010:c04::22b])
        by mx.google.com with ESMTPS id ku1si6603651lbc.31.2016.06.21.11.40.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 11:40:17 -0700 (PDT)
Received: by mail-lb0-x22b.google.com with SMTP id oe3so15877588lbb.1
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 11:40:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160620203910.a8b6b5b10d18f24661916e7b@gmail.com>
References: <20160620203910.a8b6b5b10d18f24661916e7b@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 21 Jun 2016 11:40:16 -0700
Message-ID: <CAGXu5jJ4G0u8JPG49ehmgPPk4tQG=nrXm0qPRCbT6PcbwD8hSw@mail.gmail.com>
Subject: Re: [PATCH v4 0/4] Introduce the latent_entropy gcc plugin
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Emese Revfy <re.emese@gmail.com>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, bart.vanassche@sandisk.com, "David S. Miller" <davem@davemloft.net>

On Mon, Jun 20, 2016 at 11:39 AM, Emese Revfy <re.emese@gmail.com> wrote:
> I would like to introduce the latent_entropy gcc plugin. This plugin
> mitigates the problem of the kernel having too little entropy during and
> after boot for generating crypto keys.
>
> This plugin mixes random values into the latent_entropy global variable
> in functions marked by the __latent_entropy attribute.
> The value of this global variable is added to the kernel entropy pool
> to increase the entropy.
>
> It is a CII project supported by the Linux Foundation.
>
> The latent_entropy plugin was ported from grsecurity/PaX originally written
> by the PaX Team. You can find more about the plugin here:
> https://grsecurity.net/pipermail/grsecurity/2012-July/001093.html
>
> The plugin supports all gcc version from 4.5 to 6.0.
>
> I do some changes above the PaX version. The important one is mixing
> the stack pointer into the global variable too.
> You can find more about the changes here:
> https://github.com/ephox-gcc-plugins/latent_entropy
>
> This patch set is based on the "Introduce GCC plugin infrastructure"
> patch set (git/mmarek/kbuild.git#kbuild HEAD: 543c37cb165049c3be).
>
> Emese Revfy (4):
>  Add support for passing gcc plugin arguments
>  Add the latent_entropy gcc plugin
>  Mark functions with the latent_entropy attribute
>  Add the extra_latent_entropy kernel parameter

Thanks! This looks good to me. I've adjusted some of the commit
message language for clarity and fixed a few other >80 lines that
stood out to me.

I've applied this to for-next/kspp and after I finish local build
testing, it should appear in linux-next.

Yay! :)

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
