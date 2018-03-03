Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8DE6B0008
	for <linux-mm@kvack.org>; Sat,  3 Mar 2018 10:13:34 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id p87so3777891lfg.8
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 07:13:34 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y70sor2126369lfk.97.2018.03.03.07.13.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Mar 2018 07:13:32 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
From: Ilya Smith <blackzert@gmail.com>
In-Reply-To: <20180302204808.GA671@bombadil.infradead.org>
Date: Sat, 3 Mar 2018 18:13:28 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <221A2345-53FF-4471-B4FA-C79AF90B70CE@gmail.com>
References: <20180227131338.3699-1-blackzert@gmail.com>
 <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
 <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com>
 <20180228183349.GA16336@bombadil.infradead.org>
 <C9D0E3BA-3AB9-4F0E-BDA5-32378E440986@gmail.com>
 <20180302204808.GA671@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

> On 2 Mar 2018, at 23:48, Matthew Wilcox <willy@infradead.org> wrote:
> Ah, I didn't mean that.  I was thinking that we can change the
> implementation to reserve 1-N pages after the end of the mapping.
> So you can't map anything else in there, and any load/store into that
> region will segfault.
>=20

I=E2=80=99m afraid it still will allow many attacks. The formula for new =
address would=20
be like: address_next =3D address_prev - mmap_size - random(N) as you =
suggested.=20
To prevent brute-force attacks N should be big enough  like more 2^32 =
for=20
example. This number 2^32 is just an example and right now I don=E2=80=99t=
 know the=20
exact value. What I=E2=80=99m trying to say that address computation =
formula has=20
dependency on concrete predictable address. In my scheme even =
address_prev was=20
chose randomly.=20

Best regards,
Ilya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
