Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EF9996B004F
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 03:30:51 -0400 (EDT)
Received: by qyk15 with SMTP id 15so4046052qyk.23
        for <linux-mm@kvack.org>; Wed, 07 Oct 2009 00:30:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20091007061223.GA17794@helight>
References: <20091007061223.GA17794@helight>
Date: Wed, 7 Oct 2009 15:30:50 +0800
Message-ID: <2375c9f90910070030u3ee74d5csf81ff6d93a207c50@mail.gmail.com>
Subject: Re: [PATCH] fix two warnings on mm/percpu.c
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Zhenwen Xu <helight.xu@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 7, 2009 at 2:12 PM, Zhenwen Xu <helight.xu@gmail.com> wrote:
> fix those two warnings:
>
> mm/percpu.c: In function =E2=80=98pcpu_embed_first_chunk=E2=80=99:
> mm/percpu.c:1873: warning: comparison of distinct pointer types lacks a c=
ast
> mm/percpu.c:1879: warning: format =E2=80=98%lx=E2=80=99 expects type =E2=
=80=98long unsigned int=E2=80=99, but
> argument 2 has type =E2=80=98size_t

It is fixed:

http://patchwork.kernel.org/patch/51565/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
