Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 275706B02B1
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 08:53:46 -0400 (EDT)
Received: by gwb1 with SMTP id 1so3742338gwb.14
        for <linux-mm@kvack.org>; Tue, 13 Jul 2010 05:53:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100713101650.2835.15245.sendpatchset@danny.redhat>
References: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Date: Tue, 13 Jul 2010 20:53:43 +0800
Message-ID: <AANLkTil9hGHoomM9LlhURipKO7_sTON09JHP3zDwOLgI@mail.gmail.com>
Subject: Re: [PATCH -mmotm 00/30] [RFC] swap over nfs -v21
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Xiaotian Feng <dfeng@redhat.com>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org, riel@redhat.com, cl@linux-foundation.org, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, lwang@redhat.com, penberg@cs.helsinki.fi, akpm@linux-foundation.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Tue, Jul 13, 2010 at 6:16 PM, Xiaotian Feng <dfeng@redhat.com> wrote:
> Hi,
>
> Here's the latest version of swap over NFS series since -v20 last October=
. We decide to push
> this feature as it is useful for NAS or virt environment.
>
> The patches are against the mmotm-2010-07-01. We can split the patchset i=
nto following parts:
>
> Patch 1 - 12: provides a generic reserve framework. This framework
> could also be used to get rid of some of the __GFP_NOFAIL users.
>
> Patch 13 - 15: Provide some generic network infrastructure needed later o=
n.
>
> Patch 16 - 21: reserve a little pool to act as a receive buffer, this all=
ows us to
> inspect packets before tossing them.
>
> Patch 22 - 23: Generic vm infrastructure to handle swapping to a filesyst=
em instead of a block
> device.
>
> Patch 24 - 27: convert NFS to make use of the new network and vm infrastr=
ucture to
> provide swap over NFS.
>
> Patch 28 - 30: minor bug fixing with latest -mmotm.
>
> [some history]
> v19: http://lwn.net/Articles/301915/
> v20: http://lwn.net/Articles/355350/
>
> Changes since v20:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0- rebased to mmotm-2010-07-01
> =C2=A0 =C2=A0 =C2=A0 =C2=A0- dropped the null pointer deref patch for the=
 root cause is wrong SWP_FILE enum
> =C2=A0 =C2=A0 =C2=A0 =C2=A0- some minor build fixes
> =C2=A0 =C2=A0 =C2=A0 =C2=A0- fix a null pointer deref with mmotm-2010-07-=
01
> =C2=A0 =C2=A0 =C2=A0 =C2=A0- fix a bug when swap with multi files on the =
same nfs server

Please use the "From:" line correctly, as stated in
Documentation/SubmittingPatches:

The "from" line must be the very first line in the message body,
and has the form:

        From: Original Author <author@example.com>

The "from" line specifies who will be credited as the author of the
patch in the permanent changelog.  If the "from" line is missing,
then the "From:" line from the email header will be used to determine
the patch author in the changelog.


I think you are using git format-patch to generate those patches, please su=
pply
--author=3D<author> to git commit when you commit them to your local
tree. (or git am
if the patches you received already had the correct From: line.)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
