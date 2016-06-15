Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id B0EF46B0261
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:33:07 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id na2so18417343lbb.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:33:07 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id vx5si1161241wjc.102.2016.06.15.13.33.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 13:33:06 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id r5so6715398wmr.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:33:06 -0700 (PDT)
Date: Wed, 15 Jun 2016 22:39:52 +0200
From: Emese Revfy <re.emese@gmail.com>
Subject: Re: [PATCH v3 0/4] Introduce the latent_entropy gcc plugin
Message-Id: <20160615223952.f3a4ece452b15c62babf4629@gmail.com>
In-Reply-To: <CAGXu5jK-QVhbuOnNENq9PesPTdPCnbgODzb0qn=q4ZMS0-ndBA@mail.gmail.com>
References: <20160615001754.f9e986cf961d1466f5e086dc@gmail.com>
	<CAGXu5jK-QVhbuOnNENq9PesPTdPCnbgODzb0qn=q4ZMS0-ndBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, bart.vanassche@sandisk.com, "David S. Miller" <davem@davemloft.net>

On Wed, 15 Jun 2016 11:55:44 -0700
Kees Cook <keescook@chromium.org> wrote:

>  The limit on the length of lines is 80 columns and this is a strongly
>  preferred limit.

I think the code looks worse when it is truncated to 80 columns but
I'll do it and resend the patches.

-- 
Emese

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
