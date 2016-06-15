Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 44A0D6B0277
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:42:49 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a2so16510823lfe.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:42:49 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id x63si7010653wmb.105.2016.06.15.13.42.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 13:42:48 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id v199so167224390wmv.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:42:47 -0700 (PDT)
Date: Wed, 15 Jun 2016 22:49:33 +0200
From: Emese Revfy <re.emese@gmail.com>
Subject: Re: [PATCH v3 2/4] Add the latent_entropy gcc plugin
Message-Id: <20160615224933.6cbd6653a4d5d269ae008b0b@gmail.com>
In-Reply-To: <CAGXu5jLiPbAdjYhtyGxc7iZRLqa7d2Pks58utFCiD3ePtusLhw@mail.gmail.com>
References: <20160615001754.f9e986cf961d1466f5e086dc@gmail.com>
	<20160615002033.a318fa0dd807751a596185da@gmail.com>
	<CAGXu5jLiPbAdjYhtyGxc7iZRLqa7d2Pks58utFCiD3ePtusLhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, bart.vanassche@sandisk.com, "David S. Miller" <davem@davemloft.net>

On Wed, 15 Jun 2016 11:07:08 -0700
Kees Cook <keescook@chromium.org> wrote:

> On Tue, Jun 14, 2016 at 3:20 PM, Emese Revfy <re.emese@gmail.com> wrote:
 
> This doesn't look right to me: these are CFLAGS_REMOVE_* entries, and
> I think you want to _add_ the DISABLE_LATENT_ENTROPY_PLUGIN to the
> CFLAGS here.

Thanks for the report. I think this patch fixes it:
https://github.com/ephox-gcc-plugins/gcc-plugins_linux-next/commit/e7601ca00a0aeb5f6b96dc79a51a5089c4d32791

-- 
Emese

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
