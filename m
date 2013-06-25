Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 32A446B0032
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 02:50:14 -0400 (EDT)
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 25 Jun 2013 07:44:50 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 9C67917D805F
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 07:51:37 +0100 (BST)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5P6nxFF49217738
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 06:49:59 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r5P6o98c001409
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 00:50:09 -0600
Date: Tue, 25 Jun 2013 08:50:06 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [Suggestion] arch: s390: mm: the warnings with allmodconfig and
 "EXTRA_CFLAGS=-W"
Message-ID: <20130625085006.01a7f368@mschwide>
In-Reply-To: <51C8F861.9010101@asianux.com>
References: <51C8F685.6000209@asianux.com>
	<51C8F861.9010101@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, cornelia.huck@de.ibm.com, mtosatti@redhat.com, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-mm@kvack.org

On Tue, 25 Jun 2013 09:54:41 +0800
Chen Gang <gang.chen@asianux.com> wrote:

> Hello Maintainers:
>=20
> When allmodconfig for " IBM zSeries model z800 and z900"
>=20
> It will report the related warnings ("EXTRA_CFLAGS=3D-W"):
>   mm/slub.c:1875:1: warning: =E2=80=98deactivate_slab=E2=80=99 uses dynam=
ic stack allocation [enabled by default]
>   mm/slub.c:1941:1: warning: =E2=80=98unfreeze_partials.isra.32=E2=80=99 =
uses dynamic stack allocation [enabled by default]
>   mm/slub.c:2575:1: warning: =E2=80=98__slab_free=E2=80=99 uses dynamic s=
tack allocation [enabled by default]
>   mm/slub.c:1582:1: warning: =E2=80=98get_partial_node.isra.34=E2=80=99 u=
ses dynamic stack allocation [enabled by default]
>   mm/slub.c:2311:1: warning: =E2=80=98__slab_alloc.constprop.42=E2=80=99 =
uses dynamic stack allocation [enabled by default]
>=20
> Is it OK ?

Yes, these warnings should be ok. They are enabled by CONFIG_WARN_DYNAMIC_S=
TACK,
the purpose is to find all functions with dynamic stack allocations. The ch=
eck
if the allocations are truly ok needs to be done manually as the compiler
can not find out the maximum allocation size automatically.

--=20
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
