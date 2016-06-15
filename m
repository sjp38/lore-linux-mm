Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AC3B46B0253
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 18:38:31 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r5so17415172wmr.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 15:38:31 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id e14si13181050wmd.17.2016.06.15.15.38.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 15:38:30 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id m124so44179093wme.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 15:38:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160615224933.6cbd6653a4d5d269ae008b0b@gmail.com>
References: <20160615001754.f9e986cf961d1466f5e086dc@gmail.com>
 <20160615002033.a318fa0dd807751a596185da@gmail.com> <CAGXu5jLiPbAdjYhtyGxc7iZRLqa7d2Pks58utFCiD3ePtusLhw@mail.gmail.com>
 <20160615224933.6cbd6653a4d5d269ae008b0b@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 15 Jun 2016 15:38:29 -0700
Message-ID: <CAGXu5j+TznrmbLNZ=c0BU4DmUYqbnktriZqwSEmNsOZTnr+7jw@mail.gmail.com>
Subject: Re: [PATCH v3 2/4] Add the latent_entropy gcc plugin
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Emese Revfy <re.emese@gmail.com>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, bart.vanassche@sandisk.com, "David S. Miller" <davem@davemloft.net>

On Wed, Jun 15, 2016 at 1:49 PM, Emese Revfy <re.emese@gmail.com> wrote:
> On Wed, 15 Jun 2016 11:07:08 -0700
> Kees Cook <keescook@chromium.org> wrote:
>
>> On Tue, Jun 14, 2016 at 3:20 PM, Emese Revfy <re.emese@gmail.com> wrote:
>
>> This doesn't look right to me: these are CFLAGS_REMOVE_* entries, and
>> I think you want to _add_ the DISABLE_LATENT_ENTROPY_PLUGIN to the
>> CFLAGS here.
>
> Thanks for the report. I think this patch fixes it:
> https://github.com/ephox-gcc-plugins/gcc-plugins_linux-next/commit/e7601ca00a0aeb5f6b96dc79a51a5089c4d32791

Yup, that looks correct, thanks!

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
