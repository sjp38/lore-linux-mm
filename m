Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 265F86B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 09:40:45 -0500 (EST)
Received: by pzk34 with SMTP id 34so3431972pzk.11
        for <linux-mm@kvack.org>; Mon, 02 Nov 2009 06:40:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091102141917.GJ2116@gamma.logic.tuwien.ac.at>
References: <20091030063216.GA30712@gamma.logic.tuwien.ac.at>
	 <20091102005218.8352.A69D9226@jp.fujitsu.com>
	 <20091102135640.93de7c2a.minchan.kim@barrios-desktop>
	 <28c262360911012300h4535118ewd65238c746b91a52@mail.gmail.com>
	 <20091102155543.E60E.A69D9226@jp.fujitsu.com>
	 <20091102140216.02567ff8.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091102141917.GJ2116@gamma.logic.tuwien.ac.at>
Date: Mon, 2 Nov 2009 23:40:43 +0900
Message-ID: <28c262360911020640k3f9dfcdct2cac6cc1d193144d@mail.gmail.com>
Subject: Re: OOM killer, page fault
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Norbert Preining <preining@logic.at>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi.

On Mon, Nov 2, 2009 at 11:19 PM, Norbert Preining <preining@logic.at> wrote=
:
> Hi all,
>
> wow, many messages ... At the end I lost track of which patch I should tr=
y?
>
> BTW, that happened only once, and whatever I do I cannot reproduce that.
>
> I will anyway include any patch you send me and hope that it happens agai=
n.

Pz forget my previous patch.
Could you test following patch?

diff --git a/mm/memory.c b/mm/memory.c
index 7e91b5f..47e4b15 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2713,7 +2713,11 @@ static int __do_fault(struct mm_struct *mm,
struct vm_area_struct *vma,
       vmf.page =3D NULL;

       ret =3D vma->vm_ops->fault(vma, &vmf);
-       if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
+       if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
+               printk(KERN_DEBUG "vma->vm_ops->fault : 0x%lx\n",
vma->vm_ops->fault);
+               WARN_ON(1);
+
+       }
               return ret;

       if (unlikely(PageHWPoison(vmf.page))) {


> Thanks
>
> Norbert
>
> -------------------------------------------------------------------------=
------
> Dr. Norbert Preining =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0Associate Professor
> JAIST Japan Advanced Institute of Science and Technology =A0 preining@jai=
st.ac.jp
> Vienna University of Technology =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 preining@logic.at
> Debian Developer (Debian TeX Task Force) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0preining@debian.org
> gpg DSA: 0x09C5B094 =A0 =A0 =A0fp: 14DF 2E6C 0307 BE6D AD76 =A0A9C0 D2BF =
4AA3 09C5 B094
> -------------------------------------------------------------------------=
------
> BAUMBER
> A fitted elasticated bottom sheet which turns your mattress
> bananashaped.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0--- Douglas Adams, The Mea=
ning of Liff
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
