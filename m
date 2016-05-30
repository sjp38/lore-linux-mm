Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id DDE8A6B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 18:33:02 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id rs7so90322559lbb.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 15:33:02 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id m72si27673714wma.60.2016.05.30.15.33.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 15:33:01 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id a136so26912550wme.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 15:33:01 -0700 (PDT)
Date: Tue, 31 May 2016 00:39:55 +0200
From: Emese Revfy <re.emese@gmail.com>
Subject: Re: [PATCH v1 1/3] Add the latent_entropy gcc plugin
Message-Id: <20160531003955.032d11cad95c4439328b0128@gmail.com>
In-Reply-To: <CAGXu5jJ4iOHw+9khys3HVKAJH6q4Vu+8aSabycYWUCdK9GonKw@mail.gmail.com>
References: <20160524001405.3e6abd1d5a63a871cc366cff@gmail.com>
	<20160524001529.0e69232eff0b1b5bc566a763@gmail.com>
	<CAGXu5jJHenHARDZt=51m1XbSStTxpG90Dv=Fpkn79A6pZYtGOw@mail.gmail.com>
	<5744E665.28844.9DDA03D@pageexec.freemail.hu>
	<CAGXu5jJ4iOHw+9khys3HVKAJH6q4Vu+8aSabycYWUCdK9GonKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: PaX Team <pageexec@freemail.hu>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Brad Spengler <spender@grsecurity.net>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, bart.vanassche@sandisk.com, "David S. Miller" <davem@davemloft.net>

On Tue, 24 May 2016 19:55:17 -0700
Kees Cook <keescook@chromium.org> wrote:
 
> Yeah, answering "how random is this?" is not easy, but that's not what
> I meant. I'm more curious about specific build configs or hardware
> where calling get_random_int() early enough would always produce the
> same value (or the same value across all threads, etc), and in these
> cases, the new entropy should be visible when using the latent entropy
> plugin.

I booted minimal configs (not allnoconfig because it can't boot in qemu)
many times. I couldn't produce same values.

-- 
Emese

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
