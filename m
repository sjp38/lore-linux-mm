Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5FB7E6B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 13:22:24 -0500 (EST)
Received: from [193.150.134.105] (helo=serv30.sepura.co.uk)
	by mta01 with esmtp (Exim 4.02)
	id 1ROZGV-00002Q-00
	for linux-mm@kvack.org; Thu, 10 Nov 2011 18:22:19 +0000
Received: from p4admin by serv30.sepura.co.uk with local (Exim 4.71)
	(envelope-from <p4admin@sepura.com>)
	id 1ROZG1-00060q-BO
	for linux-mm@kvack.org; Thu, 10 Nov 2011 18:21:49 +0000
Date: Thu, 10 Nov 2011 18:21:49 +0000
Message-Id: <E1ROZG1-00060q-BO@serv30.sepura.co.uk>
From: p4admin@sepura.com
Reply-To: devtools@sepura.com ((Account for building software - Daniel Sherwood))
Subject: Perforce change 315103
Content-Type: multipart/alternative;
	boundary="MCBoundary=_111111018222006601"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: linux-mm@kvack.org

--MCBoundary=_111111018222006601
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable

Change 315103 by devtools@devtools_gitimport on 2011/11/10 18:21:16

=09commit 7bf07f3d4b4358aa6d99a26d7a0165f1e91c3fcc
=09Author: Adam Litke <agl@us.ibm.com>
=09Date:   Sat Sep 3 15:55:00 2005 -0700
=09
=09    [PATCH] hugetlb: move stale pte check into huge_pte_alloc()
=09
=09    Initial Post (Wed, 17 Aug 2005)
=09
=09    This patch moves the
=09    =09if (! pte_none(*pte))
=09    =09=09hugetlb_clean_stale_pgtable(pte);
=09    logic into huge_pte_alloc() so all of its callers can be immune to t=
he bug
=09    described by Kenneth Chen at http://lkml.org/lkml/2004/6/16/246
=09
=09    > It turns out there is a bug in hugetlb_prefault(): with 3 level pa=
ge table,
=09    > huge_pte_alloc() might return a pmd that points to a PTE page. It =
happens
=09    > if the virtual address for hugetlb mmap is recycled from previousl=
y used
=09    > normal page mmap. free_pgtables() might not scrub the pmd entry on
=09    > munmap and hugetlb_prefault skips on any pmd presence regardless w=
hat type
=09    > it is.
=09
=09    Unless I am missing something, it seems more correct to place the ch=
eck inside
=09    huge_pte_alloc() to prevent a the same bug wherever a huge pte is al=
located.
=09    It also allows checking for this condition when lazily faulting huge=
 pages
=09    later in the series.
=09
=09    Signed-off-by: Adam Litke <agl@us.ibm.com>
=09    Cc: <linux-mm@kvack.org>
=09    Signed-off-by: Andrew Morton <akpm@osdl.org>
=09    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

Affected files ...

... //sw/components_third_party/linux/git/master/.versions.submit#1694 edit
... //sw/components_third_party/linux/git/master/component/arch/i386/mm/hug=
etlbpage.c#4 edit
... //sw/components_third_party/linux/git/master/component/mm/hugetlb.c#4 e=
dit

  http://serv30:8666/315103?ac=3D10


The information in this email is confidential. It is intended
solely for the addressee. Access to this email by anyone else
is unauthorised. If you are not the intended recipient, any
disclosure, copying, or distribution is prohibited and may be
unlawful. If you have received this email in error please delete
it immediately and contact commercial@sepura.com.

Sepura plc. Registered Office: Radio House, St Andrew=92s Road, Cambridge, =
CB4 1GR, England. Registered in England and Wales. Registration Number 4353=
801
=20
--MCBoundary=_111111018222006601
Content-Type: text/html; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable

<HTML><BODY>
    <BR>
    <BR>
    Change 315103 by <a href=3D"mailto:devtools@devtools_gitimport">devtool=
s@devtools_gitimport</a> on 2011/11/10 18:21:16 <BR>
<BR>
=09commit 7bf07f3d4b4358aa6d99a26d7a0165f1e91c3fcc<BR>
=09Author: Adam Litke &lt;<a href=3D"mailto:agl@us.ibm.com">agl@us.ibm.com<=
/a>&gt; <BR>
=09Date:   Sat Sep 3 15:55:00 2005 -0700<BR>
=09<BR>
=09    [PATCH] hugetlb: move stale pte check into huge_pte_alloc()<BR>
=09<BR>
=09    Initial Post (Wed, 17 Aug 2005)<BR>
=09<BR>
=09    This patch moves the<BR>
=09    =09if (! pte_none(*pte))<BR>
=09    =09=09hugetlb_clean_stale_pgtable(pte);<BR>
=09    logic into huge_pte_alloc() so all of its callers can be immune to t=
he bug<BR>
=09    described by Kenneth Chen at <a href=3D"http://lkml.org/lkml/2004/6/=
16/246" target=3D"_blank">http://lkml.org/lkml/2004/6/16/246</a> <BR>
=09<BR>
=09    &gt; It turns out there is a bug in hugetlb_prefault(): with 3 level=
 page table,<BR>
=09    &gt; huge_pte_alloc() might return a pmd that points to a PTE page. =
It happens<BR>
=09    &gt; if the virtual address for hugetlb mmap is recycled from previo=
usly used<BR>
=09    &gt; normal page mmap. free_pgtables() might not scrub the pmd entry=
 on<BR>
=09    &gt; munmap and hugetlb_prefault skips on any pmd presence regardles=
s what type<BR>
=09    &gt; it is.<BR>
=09<BR>
=09    Unless I am missing something, it seems more correct to place the ch=
eck inside<BR>
=09    huge_pte_alloc() to prevent a the same bug wherever a huge pte is al=
located.<BR>
=09    It also allows checking for this condition when lazily faulting huge=
 pages<BR>
=09    later in the series.<BR>
=09<BR>
=09    Signed-off-by: Adam Litke &lt;<a href=3D"mailto:agl@us.ibm.com">agl@=
us.ibm.com</a>&gt; <BR>
=09    Cc: &lt;<a href=3D"mailto:linux-mm@kvack.org">linux-mm@kvack.org</a>=
&gt; <BR>
=09    Signed-off-by: Andrew Morton &lt;<a href=3D"mailto:akpm@osdl.org">ak=
pm@osdl.org</a>&gt; <BR>
=09    Signed-off-by: Linus Torvalds &lt;<a href=3D"mailto:torvalds@osdl.or=
g">torvalds@osdl.org</a>&gt; <BR>
<BR>
Affected files ...<BR>
<BR>
... //sw/components_third_party/linux/git/master/.versions.submit#1694 edit=
<BR>
... //sw/components_third_party/linux/git/master/component/arch/i386/mm/hug=
etlbpage.c#4 edit<BR>
... //sw/components_third_party/linux/git/master/component/mm/hugetlb.c#4 e=
dit<BR>
<BR>
  <a href=3D"http://serv30:8666/315103?ac=3D10" target=3D"_blank">http://se=
rv30:8666/315103?ac=3D10</a> <BR>

    <BR>
    <BR>
     <span style=3D"font-family:Times New Roman; Font-size:12.0pt">   =20
       <hr width=3D"100%">
The information in this email is confidential. It is intended<BR>
solely for the addressee. Access to this email by anyone else<BR>
is unauthorised. If you are not the intended recipient, any<BR>
disclosure, copying, or distribution is prohibited and may be<BR>
unlawful. If you have received this email in error please delete<BR>
it immediately and contact commercial@sepura.com.<BR><BR>
Sepura plc. Registered Office: Radio House, St Andrew=92s Road, Cambridge, =
CB4 1GR, England. Registered in England and Wales. Registration Number 4353=
801
    <hr width=3D"100%">  =20
<BR>
This email message has been scanned for viruses by Mimecast.<BR>
       Mimecast delivers a complete managed email solution from a single we=
b based platform.<BR>      =20
   </span>


    </BODY></HTML>


--MCBoundary=_111111018222006601--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
