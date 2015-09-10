Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 047436B0256
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 18:18:32 -0400 (EDT)
Received: by ykei199 with SMTP id i199so73444927yke.0
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 15:18:31 -0700 (PDT)
Received: from BLU004-OMC1S28.hotmail.com (blu004-omc1s28.hotmail.com. [65.55.116.39])
        by mx.google.com with ESMTPS id s184si8107123ywb.139.2015.09.10.15.18.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 10 Sep 2015 15:18:31 -0700 (PDT)
Message-ID: <BLU436-SMTP253F123C92780B6AA4E637B9510@phx.gbl>
Date: Fri, 11 Sep 2015 06:20:27 +0800
From: Chen Gang <xili_gchen_5257@hotmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mmap.c: Remove useless statement "vma = NULL" in find_vma()
References: <COL130-W64A6555222F8CEDA513171B9560@phx.gbl> <COL130-W6916929C85FB1943CC1B11B9530@phx.gbl> <COL130-W43C0C45AA4E2A7AA6361D0B9520@phx.gbl> <20150910181935.GB21456@redhat.com>
In-Reply-To: <20150910181935.GB21456@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

On 9/11/15 02:19=2C Oleg Nesterov wrote:
> On 09/10=2C Chen Gang wrote:
>> - If "addr>=3D vm_start"=2C we return this vma (else continue searching)=
.
>=20
> This is optimization=2C we can stop the search because in this case
> vma =3D=3D tmp is obviously the 1st vma with "addr < vm_end".
>=20

OK=2C thanks.

I guess if we have additional comments for "if (tmp->vm_start <=3D addr)"=
=2C
the code will be more readable for readers (especially for newbies).

@@ -2064=2C7 +2064=2C7 @@ struct vm_area_struct *find_vma(struct mm_struct =
*mm=2C unsigned long addr)
                if (tmp->vm_end > addr) {
                        vma =3D tmp=3B
                        if (tmp->vm_start <=3D addr)
-                               break=3B
+                               break=3B /* It must be 1st "addr < vm_end" =
*/
                        rb_node =3D rb_node->rb_left=3B
                } else
                        rb_node =3D rb_node->rb_right=3B


> I simply can't understand your concerns. Perhaps you can make a
> patch=2C then it will be more clear what me-or-you have missed.
>=20

I guess=2C we need not (it is my missing). :-)


Thanks.
--=20
Chen Gang (=E9=99=88=E5=88=9A)

Open=2C share=2C and attitude like air=2C water=2C and life which God bless=
ed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
