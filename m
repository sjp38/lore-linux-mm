Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF8B76B02F4
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 16:07:39 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id a67so12401216vkf.12
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 13:07:39 -0700 (PDT)
Received: from mail-ua0-x241.google.com (mail-ua0-x241.google.com. [2607:f8b0:400c:c08::241])
        by mx.google.com with ESMTPS id j12si64572vkc.276.2017.06.27.13.07.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 13:07:38 -0700 (PDT)
Received: by mail-ua0-x241.google.com with SMTP id g40so3011314uaa.3
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 13:07:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170627175118.GA14286@infradead.org>
References: <20170627173323.11287-1-igor.stoppa@huawei.com>
 <20170627173323.11287-4-igor.stoppa@huawei.com> <20170627175118.GA14286@infradead.org>
From: "igor.stoppa@gmail.com" <igor.stoppa@gmail.com>
Date: Tue, 27 Jun 2017 23:07:17 +0300
Message-ID: <CAH2bzCQQyCEkBEe5tWRLnXek=L6MUJai1D77ogjaBjW7wJJmfA@mail.gmail.com>
Subject: Re: [PATCH 3/3] Make LSM Writable Hooks a command line option
Content-Type: multipart/alternative; boundary="94eb2c047dc68424bb0552f69e2c"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Igor Stoppa <igor.stoppa@huawei.com>, keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org, penguin-kernel@i-love.sakura.ne.jp, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

--94eb2c047dc68424bb0552f69e2c
Content-Type: text/plain; charset="UTF-8"

On 27 June 2017 at 20:51, Christoph Hellwig <hch@infradead.org> wrote:

> On Tue, Jun 27, 2017 at 08:33:23PM +0300, Igor Stoppa wrote:
>
> [...]


> > The default value is disabled, unless SE Linux debugging is turned on.
>
> Can we please just force it to be read-only?
>

I'm sorry, I'm not quite sure I understand your comment.

I'm trying to replicate the behavior of __lsm_ro_after_init:

line 1967 @ [1]   - Did I get it wrong?

thanks, igor



[1]
https://kernel.googlesource.com/pub/scm/linux/kernel/git/jmorris/linux-security/+/5965453d5e3fb425e6f9d6b4fec403bda3f33107/include/linux/lsm_hooks.h

--94eb2c047dc68424bb0552f69e2c
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On 2=
7 June 2017 at 20:51, Christoph Hellwig <span dir=3D"ltr">&lt;<a href=3D"ma=
ilto:hch@infradead.org" target=3D"_blank">hch@infradead.org</a>&gt;</span> =
wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8=
ex;border-left:1px solid rgb(204,204,204);padding-left:1ex"><span class=3D"=
gmail-">On Tue, Jun 27, 2017 at 08:33:23PM +0300, Igor Stoppa wrote:<br><br=
></span></blockquote><div>[...]</div><div>=C2=A0</div><blockquote class=3D"=
gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(20=
4,204,204);padding-left:1ex"><span class=3D"gmail-">
&gt; The default value is disabled, unless SE Linux debugging is turned on.=
<br>
<br>
</span>Can we please just force it to be read-only?<br>
</blockquote></div><br>I&#39;m sorry, I&#39;m not quite sure I understand y=
our comment.
</div><div class=3D"gmail_extra"><br></div><div class=3D"gmail_extra">I&#39=
;m trying to replicate the behavior of __lsm_ro_after_init:</div><div class=
=3D"gmail_extra"><br></div><div class=3D"gmail_extra">line 1967 @ [1] =C2=
=A0 - Did I get it wrong?</div><div class=3D"gmail_extra"><br></div><div cl=
ass=3D"gmail_extra">thanks, igor</div><div class=3D"gmail_extra"><br></div>=
<div class=3D"gmail_extra"><br></div><div class=3D"gmail_extra"><br></div><=
div class=3D"gmail_extra">[1] <a href=3D"https://kernel.googlesource.com/pu=
b/scm/linux/kernel/git/jmorris/linux-security/+/5965453d5e3fb425e6f9d6b4fec=
403bda3f33107/include/linux/lsm_hooks.h">https://kernel.googlesource.com/pu=
b/scm/linux/kernel/git/jmorris/linux-security/+/5965453d5e3fb425e6f9d6b4fec=
403bda3f33107/include/linux/lsm_hooks.h</a><br></div></div>

--94eb2c047dc68424bb0552f69e2c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
