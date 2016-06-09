Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C0546B007E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 19:26:53 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 132so23189043lfz.3
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 16:26:53 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id p5si11070456wmd.116.2016.06.09.16.26.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 16:26:51 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id m124so79969071wme.1
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 16:26:51 -0700 (PDT)
Date: Fri, 10 Jun 2016 01:33:43 +0200
From: Emese Revfy <re.emese@gmail.com>
Subject: Re: [PATCH v2 0/3] Introduce the latent_entropy gcc plugin
Message-Id: <20160610013343.bad451f3e132b76ba2458e39@gmail.com>
In-Reply-To: <CAGXu5jLS_NNFYPXgjaHfiF6Bfg4TbzogadOPkdTcxXG8nm7Y2A@mail.gmail.com>
References: <20160531013029.4c5db8b570d86527b0b53fe4@gmail.com>
	<CAGXu5jLS_NNFYPXgjaHfiF6Bfg4TbzogadOPkdTcxXG8nm7Y2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, bart.vanassche@sandisk.com, "David S. Miller" <davem@davemloft.net>

On Thu, 9 Jun 2016 14:18:08 -0700
Kees Cook <keescook@chromium.org> wrote:

> By the way, as you work on v3, can you also be sure to put your
> patches through scripts/checkpatch.pl? There are a lot of >80
> character lines, and other nits. I'd like to minimize the warnings.

I only split those lines where the split doesn't make the code worse.
I checked it again and I made some changes:
https://github.com/ephox-gcc-plugins/latent_entropy/commit/e8e7c885b49db16903ea5bd4d6318ce1246f85f3

-- 
Emese

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
