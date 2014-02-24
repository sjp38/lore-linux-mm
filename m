Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id AAB6A6B0112
	for <linux-mm@kvack.org>; Mon, 24 Feb 2014 13:02:17 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id t59so5596349yho.24
        for <linux-mm@kvack.org>; Mon, 24 Feb 2014 10:02:17 -0800 (PST)
Received: from fujitsu25.fnanic.fujitsu.com (fujitsu25.fnanic.fujitsu.com. [192.240.6.15])
        by mx.google.com with ESMTPS id a26si7142654yhd.76.2014.02.24.10.02.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Feb 2014 10:02:16 -0800 (PST)
From: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Date: Mon, 24 Feb 2014 09:57:35 -0800
Subject: RE: [PATCH] mm: remove BUG_ON() from mlock_vma_page()
Message-ID: <6B2BA408B38BA1478B473C31C3D2074E2F6DBA97C6@SV-EXCHANGE1.Corp.FC.LOCAL>
References: <1387327369-18806-1-git-send-email-bob.liu@oracle.com>
 <20140131123352.a3da2a1dee32d79ad1f6af9f@linux-foundation.org>
 <530A4CBE.5090305@oracle.com>
In-Reply-To: <530A4CBE.5090305@oracle.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "walken@google.com" <walken@google.com>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "riel@redhat.com" <riel@redhat.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "stable@kernel.org" <stable@kernel.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, Bob Liu <bob.liu@oracle.com>



> -----Original Message-----
> From: Sasha Levin [mailto:sasha.levin@oracle.com]
> Sent: Sunday, February 23, 2014 2:32 PM
> To: Andrew Morton; Bob Liu
> Cc: linux-mm@kvack.org; walken@google.com; Motohiro Kosaki JP;
> riel@redhat.com; vbabka@suse.cz; stable@kernel.org;
> gregkh@linuxfoundation.org; Bob Liu
> Subject: Re: [PATCH] mm: remove BUG_ON() from mlock_vma_page()
>=20
> On 01/31/2014 03:33 PM, Andrew Morton wrote:
> > On Wed, 18 Dec 2013 08:42:49 +0800 Bob Liu<lliubbo@gmail.com>  wrote:
> >
> >> >This BUG_ON() was triggered when called from try_to_unmap_cluster()
> >> >which didn't lock the page.
> >> >And it's safe to mlock_vma_page() without PageLocked, so this patch
> >> >fix this issue by removing that BUG_ON() simply.
> >> >
> > This patch doesn't appear to be going anywhere, so I will drop it.
> > Please let's check to see whether the bug still exists and if so,
> > start another round of bugfixing.
>=20
> This bug still happens on the latest -next kernel.

Yeah, I recognized it. I'm preparing new patch. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
