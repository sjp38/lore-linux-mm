Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2A4916B0070
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 13:22:26 -0500 (EST)
Received: from [193.150.134.105] (helo=serv30.sepura.co.uk)
	by mta01 with esmtp (Exim 4.02)
	id 1ROZGV-00002R-00
	for linux-mm@kvack.org; Thu, 10 Nov 2011 18:22:19 +0000
Received: from p4admin by serv30.sepura.co.uk with local (Exim 4.71)
	(envelope-from <p4admin@sepura.com>)
	id 1ROZG1-000612-CP
	for linux-mm@kvack.org; Thu, 10 Nov 2011 18:21:49 +0000
Date: Thu, 10 Nov 2011 18:21:49 +0000
Message-Id: <E1ROZG1-000612-CP@serv30.sepura.co.uk>
From: p4admin@sepura.com
Reply-To: devtools@sepura.com ((Account for building software - Daniel Sherwood))
Subject: Perforce change 315105
Content-Type: multipart/alternative;
	boundary="MCBoundary=_111111018222205401"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: linux-mm@kvack.org

--MCBoundary=_111111018222205401
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable

Change 315105 by devtools@devtools_gitimport on 2011/11/10 18:21:17

=09commit 02b0ccef903e85673ead74ddb7c431f2f7ce183d
=09Author: Adam Litke <agl@us.ibm.com>
=09Date:   Sat Sep 3 15:55:01 2005 -0700
=09
=09    [PATCH] hugetlb: check p?d_present in huge_pte_offset()
=09
=09    For demand faulting, we cannot assume that the page tables will be
=09    populated.  Do what the rest of the architectures do and test p?d_pr=
esent()
=09    while walking down the page table.
=09
=09    Signed-off-by: Adam Litke <agl@us.ibm.com>
=09    Cc: <linux-mm@kvack.org>
=09    Signed-off-by: Andrew Morton <akpm@osdl.org>
=09    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

Affected files ...

... //sw/components_third_party/linux/git/master/.versions.submit#1695 edit
... //sw/components_third_party/linux/git/master/component/arch/i386/mm/hug=
etlbpage.c#5 edit

  http://serv30:8666/315105?ac=3D10


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
--MCBoundary=_111111018222205401
Content-Type: text/html; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable

<HTML><BODY>
    <BR>
    <BR>
    Change 315105 by <a href=3D"mailto:devtools@devtools_gitimport">devtool=
s@devtools_gitimport</a> on 2011/11/10 18:21:17 <BR>
<BR>
=09commit 02b0ccef903e85673ead74ddb7c431f2f7ce183d<BR>
=09Author: Adam Litke &lt;<a href=3D"mailto:agl@us.ibm.com">agl@us.ibm.com<=
/a>&gt; <BR>
=09Date:   Sat Sep 3 15:55:01 2005 -0700<BR>
=09<BR>
=09    [PATCH] hugetlb: check p?d_present in huge_pte_offset()<BR>
=09<BR>
=09    For demand faulting, we cannot assume that the page tables will be<B=
R>
=09    populated.  Do what the rest of the architectures do and test p?d_pr=
esent()<BR>
=09    while walking down the page table.<BR>
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
... //sw/components_third_party/linux/git/master/.versions.submit#1695 edit=
<BR>
... //sw/components_third_party/linux/git/master/component/arch/i386/mm/hug=
etlbpage.c#5 edit<BR>
<BR>
  <a href=3D"http://serv30:8666/315105?ac=3D10" target=3D"_blank">http://se=
rv30:8666/315105?ac=3D10</a> <BR>

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


--MCBoundary=_111111018222205401--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
