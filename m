Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8D81F8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 18:39:54 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id p131so2462508oia.21
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 15:39:54 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id o3si3680979oia.31.2019.01.16.15.39.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 15:39:53 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm: hwpoison: use do_send_sig_info() instead of
 force_sig() (Re: PMEM error-handling forces SIGKILL causes kernel panic)
Date: Wed, 16 Jan 2019 23:32:07 +0000
Message-ID: <20190116233207.GA5868@hori1.linux.bs1.fc.nec.co.jp>
References: <e3c4c0e0-1434-4353-b893-2973c04e7ff7@oracle.com>
 <CAPcyv4j67n6H7hD6haXJqysbaauci4usuuj5c+JQ7VQBGngO1Q@mail.gmail.com>
 <20190111081401.GA5080@hori1.linux.bs1.fc.nec.co.jp>
 <20190116093046.GA29835@hori1.linux.bs1.fc.nec.co.jp>
 <97e179e1-8a3a-5acb-78c1-a4b06b33db4c@oracle.com>
In-Reply-To: <97e179e1-8a3a-5acb-78c1-a4b06b33db4c@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <68BC388A3267A242ADFC5973F8C41A59@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jane Chu <jane.chu@oracle.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Jane,

On Wed, Jan 16, 2019 at 09:56:02AM -0800, Jane Chu wrote:
> Hi, Naoya,
>=20
> On 1/16/2019 1:30 AM, Naoya Horiguchi wrote:
>=20
>     diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>     index 7c72f2a95785..831be5ff5f4d 100644
>     --- a/mm/memory-failure.c
>     +++ b/mm/memory-failure.c
>     @@ -372,7 +372,8 @@ static void kill_procs(struct list_head *to_kill,=
 int forcekill, bool fail,
>                             if (fail || tk->addr_valid =3D=3D 0) {
>                                     pr_err("Memory failure: %#lx: forcibl=
y killing %s:%d because of failure to unmap corrupted page\n",
>                                            pfn, tk->tsk->comm, tk->tsk->p=
id);
>     -                               force_sig(SIGKILL, tk->tsk);
>     +                               do_send_sig_info(SIGKILL, SEND_SIG_PR=
IV,
>     +                                                tk->tsk, PIDTYPE_PID=
);
>                             }
>=20
>=20
> Since we don't care the return from do_send_sig_info(), would you mind to
> prefix it with (void) ?

Sorry, I'm not sure about the benefit to do casting the return value
just being ignored, so personally I'd like keeping the code simple.
Do you have some in mind?

- Naoya=
