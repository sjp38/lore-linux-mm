Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C3B536B0095
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 16:11:28 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so2324369vbb.14
        for <linux-mm@kvack.org>; Wed, 23 Nov 2011 13:11:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHGf_=rOYkEGHakyHpihopMg2VtVfDV7XvC_QGs_kj6HgDmBRA@mail.gmail.com>
References: <1322038412-29013-1-git-send-email-amwang@redhat.com>
	<CAHGf_=rOYkEGHakyHpihopMg2VtVfDV7XvC_QGs_kj6HgDmBRA@mail.gmail.com>
Date: Wed, 23 Nov 2011 23:11:26 +0200
Message-ID: <CAOJsxLH2foaRHYoPgRufu_J8B-YEvQ8aJNuQqHOPNj9YFvAubw@mail.gmail.com>
Subject: Re: [V3 PATCH 1/2] tmpfs: add fallocate support
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Christoph Hellwig <hch@lst.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, linux-mm@kvack.org

On Wed, Nov 23, 2011 at 9:59 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> +
>> + =A0 =A0 =A0 goto unlock;
>> +
>> +undo:
>> + =A0 =A0 =A0 while (index > start) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 shmem_truncate_page(inode, index);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 index--;
>
> Hmmm...
> seems too aggressive truncate if the file has pages before starting fallo=
cate.
> but I have no idea to make better undo. ;)

Why do we need to undo anyway?

                                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
