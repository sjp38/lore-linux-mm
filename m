Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 483836B02A8
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 12:53:08 -0400 (EDT)
Received: by bwz9 with SMTP id 9so4963417bwz.14
        for <linux-mm@kvack.org>; Wed, 28 Jul 2010 09:53:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1280335203-23305-1-git-send-email-segooon@gmail.com>
References: <1280335203-23305-1-git-send-email-segooon@gmail.com>
Date: Wed, 28 Jul 2010 19:53:06 +0300
Message-ID: <AANLkTimhz5D4jthc8__HvHekznWSftXqqDihzjKbW9=P@mail.gmail.com>
Subject: Re: [PATCH 05/10] mm: check kmalloc() return value
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Kulikov Vasiliy <segooon@gmail.com>
Cc: kernel-janitors@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jan Beulich <jbeulich@novell.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 28, 2010 at 7:40 PM, Kulikov Vasiliy <segooon@gmail.com> wrote:
> kmalloc() may fail, if so return -ENOMEM.
>
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

> ---
> =A0mm/vmalloc.c | =A0 =A05 ++++-
> =A01 files changed, 4 insertions(+), 1 deletions(-)
>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index b7e314b..f63684a 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2437,8 +2437,11 @@ static int vmalloc_open(struct inode *inode, struc=
t file *file)
> =A0 =A0 =A0 =A0unsigned int *ptr =3D NULL;
> =A0 =A0 =A0 =A0int ret;
>
> - =A0 =A0 =A0 if (NUMA_BUILD)
> + =A0 =A0 =A0 if (NUMA_BUILD) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ptr =3D kmalloc(nr_node_ids * sizeof(unsig=
ned int), GFP_KERNEL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ptr =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0ret =3D seq_open(file, &vmalloc_op);
> =A0 =A0 =A0 =A0if (!ret) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct seq_file *m =3D file->private_data;
> --
> 1.7.0.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
