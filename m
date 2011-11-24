Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4166B0099
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 21:47:03 -0500 (EST)
Received: by ggnq1 with SMTP id q1so2763322ggn.14
        for <linux-mm@kvack.org>; Wed, 23 Nov 2011 18:47:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111124105245.b252c65f.kamezawa.hiroyu@jp.fujitsu.com>
References: <1322038412-29013-1-git-send-email-amwang@redhat.com> <20111124105245.b252c65f.kamezawa.hiroyu@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 23 Nov 2011 21:46:39 -0500
Message-ID: <CAHGf_=oD0Coc=k5kAAQoP=GqK+nc0jd3qq3TmLZaitSjH-ZPmQ@mail.gmail.com>
Subject: Re: [V3 PATCH 1/2] tmpfs: add fallocate support
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Christoph Hellwig <hch@lst.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, linux-mm@kvack.org

>> + =A0 =A0 while (index < end) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D shmem_getpage(inode, index, &page, SGP=
_WRITE, NULL);
>
> If the 'page' for index exists before this call, this will return the pag=
e without
> allocaton.
>
> Then, the page may not be zero-cleared. I think the page should be zero-c=
leared.

No. fallocate shouldn't destroy existing data. It only ensure
subsequent file access don't make ENOSPC error.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
