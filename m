Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 54D416B0003
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 07:38:28 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id y14-v6so12407547ioa.22
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 04:38:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j79sor16032507jad.11.2018.11.13.04.38.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 04:38:27 -0800 (PST)
MIME-Version: 1.0
From: Yongkai Wu <nic.wuyk@gmail.com>
Date: Tue, 13 Nov 2018 20:38:16 +0800
Message-ID: <CAJtqMcZp5AVva2yOM4gJET8Gd_j_BGJDLTkcqRdJynVCiRRFxQ@mail.gmail.com>
Subject: [PATCH] mm/hugetl.c: keep the page mapping info when free_huge_page()
 hit the VM_BUG_ON_PAGE
Content-Type: multipart/alternative; boundary="00000000000017adeb057a8b18d7"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mike.kravetz@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

--00000000000017adeb057a8b18d7
Content-Type: text/plain; charset="UTF-8"

It is better to keep page mapping info when free_huge_page() hit the
VM_BUG_ON_PAGE,
so we can get more infomation from the coredump for further analysis.

Signed-off-by: Yongkai Wu <nic_w@163.com>
---
 mm/hugetlb.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c007fb5..ba693bb 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1248,10 +1248,11 @@ void free_huge_page(struct page *page)
  (struct hugepage_subpool *)page_private(page);
  bool restore_reserve;

+        VM_BUG_ON_PAGE(page_count(page), page);
+        VM_BUG_ON_PAGE(page_mapcount(page), page);
+
  set_page_private(page, 0);
  page->mapping = NULL;
- VM_BUG_ON_PAGE(page_count(page), page);
- VM_BUG_ON_PAGE(page_mapcount(page), page);
  restore_reserve = PagePrivate(page);
  ClearPagePrivate(page);

-- 
1.8.3.1

--00000000000017adeb057a8b18d7
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div>It is better to keep page mapping in=
fo when free_huge_page() hit the VM_BUG_ON_PAGE,</div><div>so we can get mo=
re infomation from the coredump for further analysis.</div><div><br></div><=
div>Signed-off-by: Yongkai Wu &lt;<a href=3D"mailto:nic_w@163.com">nic_w@16=
3.com</a>&gt;</div><div>---</div><div>=C2=A0mm/hugetlb.c | 5 +++--</div><di=
v>=C2=A01 file changed, 3 insertions(+), 2 deletions(-)</div><div><br></div=
><div>diff --git a/mm/hugetlb.c b/mm/hugetlb.c</div><div>index c007fb5..ba6=
93bb 100644</div><div>--- a/mm/hugetlb.c</div><div>+++ b/mm/hugetlb.c</div>=
<div>@@ -1248,10 +1248,11 @@ void free_huge_page(struct page *page)</div><d=
iv>=C2=A0<span style=3D"white-space:pre">		</span>(struct hugepage_subpool =
*)page_private(page);</div><div>=C2=A0<span style=3D"white-space:pre">	</sp=
an>bool restore_reserve;</div><div>=C2=A0</div><div>+=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 VM_BUG_ON_PAGE(page_count(page), page);</div><div>+=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 VM_BUG_ON_PAGE(page_mapcount(page), page);</div><div>+</div><div=
>=C2=A0<span style=3D"white-space:pre">	</span>set_page_private(page, 0);</=
div><div>=C2=A0<span style=3D"white-space:pre">	</span>page-&gt;mapping =3D=
 NULL;</div><div>-<span style=3D"white-space:pre">	</span>VM_BUG_ON_PAGE(pa=
ge_count(page), page);</div><div>-<span style=3D"white-space:pre">	</span>V=
M_BUG_ON_PAGE(page_mapcount(page), page);</div><div>=C2=A0<span style=3D"wh=
ite-space:pre">	</span>restore_reserve =3D PagePrivate(page);</div><div>=C2=
=A0<span style=3D"white-space:pre">	</span>ClearPagePrivate(page);</div><di=
v>=C2=A0</div><div>--=C2=A0</div><div>1.8.3.1</div></div></div>

--00000000000017adeb057a8b18d7--
