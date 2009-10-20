Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 597896B004F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 03:10:51 -0400 (EDT)
Message-ID: <COL115-W535064AC2F576372C1BB1B9FC00@phx.gbl>
From: Bo Liu <bo-liu@hotmail.com>
Subject: [PATCH] try_to_unuse : remove redundant swap_count()
Date: Tue, 20 Oct 2009 15:09:20 +0800
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hugh.dickins@tiscali.co.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


=20
While comparing with swcount=2Cit's no need to
call swap_count(). Just as int set_start_mm =3D=20
(*swap_map>=3D swcount) is ok.
=20
Signed-off-by: Bo Liu <bo-liu@hotmail.com>
---
=20
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 63ce10f..2456fc6 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1152=2C7 +1152=2C7 @@ static int try_to_unuse(unsigned int type)
      retval =3D unuse_mm(mm=2C entry=2C page)=3B
     if (set_start_mm &&
-        swap_count(*swap_map) < swcount) {
+         ((*swap_map) < swcount)) {
      mmput(new_start_mm)=3B
      atomic_inc(&mm->mm_users)=3B
      new_start_mm =3D mm=3B
=20
--=20
1.6.0.6 		 	   		 =20
_________________________________________________________________
Windows Live Hotmail: Your friends can get your Facebook updates=2C right f=
rom Hotmail=AE.
http://www.microsoft.com/middleeast/windows/windowslive/see-it-in-action/so=
cial-network-basics.aspx?ocid=3DPID23461::T:WLMTAGL:ON:WL:en-xm:SI_SB_4:092=
009=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
