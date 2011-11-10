Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7623A6B006E
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 13:22:26 -0500 (EST)
Date: Thu, 10 Nov 2011 18:21:49 +0000
Message-Id: <E1ROZG1-00063C-Px@serv30.sepura.co.uk>
From: p4admin@sepura.com
Reply-To: devtools@sepura.com ((Account for building software - Daniel Sherwood))
Subject: Perforce change 315120
Content-Type: multipart/alternative;
	boundary="MCBoundary=_111111018222207201"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Christoph@sepura.com, Lameter@sepura.com, christoph@lameter.com, linux-mm@kvack.org

--MCBoundary=_111111018222207201
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable

Change 315120 by devtools@devtools_gitimport on 2011/11/10 18:21:26

=09commit a600388d28419305aad3c4c0af52c223cf6fa0af
=09Author: Zachary Amsden <zach@vmware.com>
=09Date:   Sat Sep 3 15:55:04 2005 -0700
=09
=09    [PATCH] x86: ptep_clear optimization
=09
=09    Add a new accessor for PTEs, which passes the full hint from the mmu=
_gather
=09    struct; this allows architectures with hardware pagetables to optimi=
ze away
=09    atomic PTE operations when destroying an address space.  Removing th=
e
=09    locked operation should allow better pipelining of memory access in =
this
=09    loop.  I measured an average savings of 30-35 cycles per zap_pte_ran=
ge on
=09    the first 500 destructions on Pentium-M, but I believe the optimizat=
ion
=09    would win more on older processors which still assert the bus lock o=
n xchg
=09    for an exclusive cacheline.
=09
=09    Update: I made some new measurements, and this saves exactly 26 cycl=
es over
=09    ptep_get_and_clear on Pentium M.  On P4, with a PAE kernel, this sav=
es 180
=09    cycles per ptep_get_and_clear, for a whopping 92160 cycles savings f=
or a
=09    full address space destruction.
=09
=09    pte_clear_full is not yet used, but is provided for future optimizat=
ions
=09    (in particular, when running inside of a hypervisor that queues page=
 table
=09    updates, the full hint allows us to avoid queueing unnecessary page =
table
=09    update for an address space in the process of being destroyed.
=09
=09    This is not a huge win, but it does help a bit, and sets the stage f=
or
=09    further hypervisor optimization of the mm layer on all architectures=
.
=09
=09    Signed-off-by: Zachary Amsden <zach@vmware.com>
=09    Cc: Christoph Lameter <christoph@lameter.com>
=09    Cc: <linux-mm@kvack.org>
=09    Signed-off-by: Andrew Morton <akpm@osdl.org>
=09    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

Affected files ...

... //sw/components_third_party/linux/git/master/.versions.submit#1698 edit
... //sw/components_third_party/linux/git/master/component/include/asm-gene=
ric/pgtable.h#4 edit
... //sw/components_third_party/linux/git/master/component/include/asm-i386=
/pgtable.h#7 edit
... //sw/components_third_party/linux/git/master/component/mm/memory.c#13 e=
dit

  http://serv30:8666/315120?ac=3D10


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
--MCBoundary=_111111018222207201
Content-Type: text/html; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable

<HTML><BODY>
    <BR>
    <BR>
    Change 315120 by <a href=3D"mailto:devtools@devtools_gitimport">devtool=
s@devtools_gitimport</a> on 2011/11/10 18:21:26 <BR>
<BR>
=09commit a600388d28419305aad3c4c0af52c223cf6fa0af<BR>
=09Author: Zachary Amsden &lt;<a href=3D"mailto:zach@vmware.com">zach@vmwar=
e.com</a>&gt; <BR>
=09Date:   Sat Sep 3 15:55:04 2005 -0700<BR>
=09<BR>
=09    [PATCH] x86: ptep_clear optimization<BR>
=09<BR>
=09    Add a new accessor for PTEs, which passes the full hint from the mmu=
_gather<BR>
=09    struct; this allows architectures with hardware pagetables to optimi=
ze away<BR>
=09    atomic PTE operations when destroying an address space.  Removing th=
e<BR>
=09    locked operation should allow better pipelining of memory access in =
this<BR>
=09    loop.  I measured an average savings of 30-35 cycles per zap_pte_ran=
ge on<BR>
=09    the first 500 destructions on Pentium-M, but I believe the optimizat=
ion<BR>
=09    would win more on older processors which still assert the bus lock o=
n xchg<BR>
=09    for an exclusive cacheline.<BR>
=09<BR>
=09    Update: I made some new measurements, and this saves exactly 26 cycl=
es over<BR>
=09    ptep_get_and_clear on Pentium M.  On P4, with a PAE kernel, this sav=
es 180<BR>
=09    cycles per ptep_get_and_clear, for a whopping 92160 cycles savings f=
or a<BR>
=09    full address space destruction.<BR>
=09<BR>
=09    pte_clear_full is not yet used, but is provided for future optimizat=
ions<BR>
=09    (in particular, when running inside of a hypervisor that queues page=
 table<BR>
=09    updates, the full hint allows us to avoid queueing unnecessary page =
table<BR>
=09    update for an address space in the process of being destroyed.<BR>
=09<BR>
=09    This is not a huge win, but it does help a bit, and sets the stage f=
or<BR>
=09    further hypervisor optimization of the mm layer on all architectures=
.<BR>
=09<BR>
=09    Signed-off-by: Zachary Amsden &lt;<a href=3D"mailto:zach@vmware.com"=
>zach@vmware.com</a>&gt; <BR>
=09    Cc: Christoph Lameter &lt;<a href=3D"mailto:christoph@lameter.com">c=
hristoph@lameter.com</a>&gt; <BR>
=09    Cc: &lt;<a href=3D"mailto:linux-mm@kvack.org">linux-mm@kvack.org</a>=
&gt; <BR>
=09    Signed-off-by: Andrew Morton &lt;<a href=3D"mailto:akpm@osdl.org">ak=
pm@osdl.org</a>&gt; <BR>
=09    Signed-off-by: Linus Torvalds &lt;<a href=3D"mailto:torvalds@osdl.or=
g">torvalds@osdl.org</a>&gt; <BR>
<BR>
Affected files ...<BR>
<BR>
... //sw/components_third_party/linux/git/master/.versions.submit#1698 edit=
<BR>
... //sw/components_third_party/linux/git/master/component/include/asm-gene=
ric/pgtable.h#4 edit<BR>
... //sw/components_third_party/linux/git/master/component/include/asm-i386=
/pgtable.h#7 edit<BR>
... //sw/components_third_party/linux/git/master/component/mm/memory.c#13 e=
dit<BR>
<BR>
  <a href=3D"http://serv30:8666/315120?ac=3D10" target=3D"_blank">http://se=
rv30:8666/315120?ac=3D10</a> <BR>

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


--MCBoundary=_111111018222207201--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
