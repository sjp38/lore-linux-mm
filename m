Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f51.google.com (mail-oa0-f51.google.com [209.85.219.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3250C6B005C
	for <linux-mm@kvack.org>; Mon, 12 May 2014 21:35:18 -0400 (EDT)
Received: by mail-oa0-f51.google.com with SMTP id n16so9270531oag.10
        for <linux-mm@kvack.org>; Mon, 12 May 2014 18:35:18 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id l1si14237095obh.80.2014.05.12.18.35.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 12 May 2014 18:35:17 -0700 (PDT)
Message-ID: <1399944913.2648.56.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v2] ipc,shm: document new limits in the uapi header
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 12 May 2014 18:35:13 -0700
In-Reply-To: <CAKgNAkhKubCUiTK36vT98vPbrfLd=xBBxeyPfUfzsqS-uHWAbA@mail.gmail.com>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
	 <CAKgNAkjuU68hgyMOVGBVoBTOhhGdBytQh6H0ExiLoXfujKyP_w@mail.gmail.com>
	 <1399406800.13799.20.camel@buesod1.americas.hpqcorp.net>
	 <CAKgNAkjOKP7P9veOpnokNkVXSszVZt5asFsNp7rm7AXJdjcLLA@mail.gmail.com>
	 <1399414081.30629.2.camel@buesod1.americas.hpqcorp.net>
	 <5369C43D.1000206@gmail.com>
	 <1399486965.4567.9.camel@buesod1.americas.hpqcorp.net>
	 <1399490251.4567.24.camel@buesod1.americas.hpqcorp.net>
	 <CAKgNAkgZ+7=EB4jkCdvq5EK1ce03rq9j+rEss9N1XnUQytBcGg@mail.gmail.com>
	 <1399841186.8629.6.camel@buesod1.americas.hpqcorp.net>
	 <CAKgNAkhKubCUiTK36vT98vPbrfLd=xBBxeyPfUfzsqS-uHWAbA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, aswin@hp.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 2014-05-12 at 09:44 +0200, Michael Kerrisk (man-pages) wrote:
> Hi Davidlohr,
> 
> On Sun, May 11, 2014 at 10:46 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> > On Fri, 2014-05-09 at 10:44 +0200, Michael Kerrisk (man-pages) wrote:
> >> On Wed, May 7, 2014 at 9:17 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> >> > This is useful in the future and allows users to
> >> > better understand the reasoning behind the changes.
> >> >
> >> > Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> >> > ---
> >> >  include/uapi/linux/shm.h | 15 +++++++++------
> >> >  1 file changed, 9 insertions(+), 6 deletions(-)
> >> >
> >> > diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
> >> > index 74e786d..3400b6e 100644
> >> > --- a/include/uapi/linux/shm.h
> >> > +++ b/include/uapi/linux/shm.h
> >> > @@ -8,17 +8,20 @@
> >> >  #endif
> >> >
> >> >  /*
> >> > - * SHMMAX, SHMMNI and SHMALL are upper limits are defaults which can
> >> > - * be modified by sysctl.
> >> > + * SHMMNI, SHMMAX and SHMALL are the default upper limits which can be
> >> > + * modified by sysctl. Both SHMMAX and SHMALL have their default values
> >> > + * to the maximum limit which is as large as it can be without helping
> >> > + * userspace overflow the values. There is really nothing the kernel
> >> > + * can do to avoid this any further. It is therefore not advised to
> >> > + * make them any larger. These limits are suitable for both 32 and
> >> > + * 64-bit systems.
> >>
> >> I somehow find that text still rather impenetrable. What about this:
> >>
> >> SHMMNI, SHMMAX and SHMALL are default upper limits which can be
> >> modified by sysctl. The SHMMAX and SHMALL values have been chosen to
> >> be as large possible without facilitating scenarios where userspace
> >> causes overflows when adjusting the limits via operations of the form
> >> "retrieve current limit; add X; update limit". It is therefore not
> >> advised to make SHMMAX and SHMALL any larger. These limits are
> >> suitable for both 32 and 64-bit systems.
> >
> > I don't really have much preference, imho both read pretty much the
> > same, specially considering this is still code after all. If you guys
> > really prefer updating it, let me know and I'll send a v3. But perhaps
> > your text is a bit more suitable in the svipc manpage?
> 
> The problem is that part of your text is still broken grammatically In
> particular, the piece "Both SHMMAX and SHMALL have their default
> values to the maximum limit" at the very least lacks a word. That's
> what prompted me to propose the alternative, rather than just say
> "this is wrong"--and I thought that I might as well make a more
> thoroughgoing attempt at helping improve the text.
> 
> I agree that text something like this should land in the man page at
> some point, but as long as we're going to the trouble to improve the
> comments in the code, let's make them as good and helpful as we can.

Fair enough, and I trust your grammar corrections over mine ;) Thanks
for taking a closer look. I've added your text below.

8<------------------------------------------
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH v3] ipc,shm: document new limits in the uapi header

This is useful in the future and allows users to
better understand the reasoning behind the changes.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 include/uapi/linux/shm.h | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
index 74e786d..1fbf24e 100644
--- a/include/uapi/linux/shm.h
+++ b/include/uapi/linux/shm.h
@@ -8,17 +8,20 @@
 #endif
 
 /*
- * SHMMAX, SHMMNI and SHMALL are upper limits are defaults which can
- * be modified by sysctl.
+ * SHMMNI, SHMMAX and SHMALL are default upper limits which can be
+ * modified by sysctl. The SHMMAX and SHMALL values have been chosen to
+ * be as large possible without facilitating scenarios where userspace
+ * causes overflows when adjusting the limits via operations of the form
+ * "retrieve current limit; add X; update limit". It is therefore not
+ * advised to make SHMMAX and SHMALL any larger. These limits are
+ * suitable for both 32 and 64-bit systems.
  */
-
 #define SHMMIN 1			 /* min shared seg size (bytes) */
 #define SHMMNI 4096			 /* max num of segs system wide */
-#define SHMMAX (ULONG_MAX - (1L<<24))	 /* max shared seg size (bytes) */
-#define SHMALL (ULONG_MAX - (1L<<24))	 /* max shm system wide (pages) */
+#define SHMMAX (ULONG_MAX - (1UL << 24)) /* max shared seg size (bytes) */
+#define SHMALL (ULONG_MAX - (1UL << 24)) /* max shm system wide (pages) */
 #define SHMSEG SHMMNI			 /* max shared segs per process */
 
-
 /* Obsolete, used only for backwards compatibility and libc5 compiles */
 struct shmid_ds {
 	struct ipc_perm		shm_perm;	/* operation perms */
-- 
1.8.1.4




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
