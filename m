Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 647076B0261
	for <linux-mm@kvack.org>; Tue, 24 May 2016 17:16:25 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id ga2so13864732lbc.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 14:16:25 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id da9si6574314wjb.105.2016.05.24.14.16.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 14:16:24 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id 67so9775670wmg.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 14:16:24 -0700 (PDT)
Date: Tue, 24 May 2016 23:23:24 +0200
From: Emese Revfy <re.emese@gmail.com>
Subject: Re: [PATCH v1 1/3] Add the latent_entropy gcc plugin
Message-Id: <20160524232324.45fbcf77916866f30b0d6cec@gmail.com>
In-Reply-To: <CAGXu5jJHenHARDZt=51m1XbSStTxpG90Dv=Fpkn79A6pZYtGOw@mail.gmail.com>
References: <20160524001405.3e6abd1d5a63a871cc366cff@gmail.com>
	<20160524001529.0e69232eff0b1b5bc566a763@gmail.com>
	<CAGXu5jJHenHARDZt=51m1XbSStTxpG90Dv=Fpkn79A6pZYtGOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, bart.vanassche@sandisk.com, "David S. Miller" <davem@davemloft.net>

On Tue, 24 May 2016 10:32:15 -0700
Kees Cook <keescook@chromium.org> wrote:

> Also, does this matter that it's non-atomic? It seems like the u64
> below is being written to by multiple threads and even read by
> multiple threads. Am I misunderstanding something?

The non-atomic accesses are intentional because
they can extract more latent entropy from these data races.
 
> > [...]
> > new file mode 100644
> > index 0000000..7295c39
> > --- /dev/null
> > +++ b/scripts/gcc-plugins/latent_entropy_plugin.c
> 
> I feel like most of the functions in this plugin could use some more
> comments about what each one does.

I think the important parts are commented (most parts just use the gcc API).
Where would you like more comments?

-- 
Emese

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
