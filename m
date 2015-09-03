From: Chen Gang <gchen_5i5j@21cn.com>
Subject: Re: [PATCH] mm/mmap.c: Remove useless statement "vma = NULL" in find_vma()
Date: Thu, 03 Sep 2015 12:02:28 +0800
Message-ID: <55E7C654.2080309@21cn.com>
References: <1441252346-2323-1-git-send-email-gang.chen.5i5j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441252346-2323-1-git-send-email-gang.chen.5i5j@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: gang.chen.5i5j@gmail.com, akpm@linux-foundation.org, mhocko@suse.cz
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

Hello all:

I also want to consult: the comments of find_vma() says:

  "Look up the first VMA which satisfies  addr < vm_end, ..."

Is it OK? (why not "vm_start <=3D addr < vm_end"), need we let "vma =3D=
 tmp"
in "if (tmp->vm_start <=3D addr)"? -- it looks the comments is not matc=
h
the implementation, precisely (maybe not 1st VMA).


Thanks.


On 9/3/15 11:52, gang.chen.5i5j@gmail.com wrote:
> From: Chen Gang <gang.chen.5i5j@gmail.com>
>=20
> Before the main looping, vma is already is NULL, so need not set it t=
o
> NULL, again.
>=20
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> ---
>  mm/mmap.c | 1 -
>  1 file changed, 1 deletion(-)
>=20
> diff --git a/mm/mmap.c b/mm/mmap.c
> index df6d5f0..4db7cf0 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2054,7 +2054,6 @@ struct vm_area_struct *find_vma(struct mm_struc=
t *mm, unsigned long addr)
>  		return vma;
> =20
>  	rb_node =3D mm->mm_rb.rb_node;
> -	vma =3D NULL;
> =20
>  	while (rb_node) {
>  		struct vm_area_struct *tmp;
>=20

--=20
Chen Gang (=E9=99=88=E5=88=9A)

Open, share, and attitude like air, water, and life which God blessed
