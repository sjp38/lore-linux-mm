Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DC7E76B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 06:23:34 -0500 (EST)
Received: by vcbfo11 with SMTP id fo11so6744695vcb.14
        for <linux-mm@kvack.org>; Tue, 15 Nov 2011 03:23:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1321346525-10187-1-git-send-email-amwang@redhat.com>
References: <1321346525-10187-1-git-send-email-amwang@redhat.com>
Date: Tue, 15 Nov 2011 13:23:31 +0200
Message-ID: <CAOJsxLEXbWbEhqX2YfzcQhyLJrY0H2ifCJCvGkoFHZsYAZEMPA@mail.gmail.com>
Subject: Re: [Patch] tmpfs: add fallocate support
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

Hello,

On Tue, Nov 15, 2011 at 10:42 AM, Amerigo Wang <amwang@redhat.com> wrote:
> This patch adds fallocate support to tmpfs. I tested this patch
> with the following test case,
>
> =A0 =A0 =A0 =A0% sudo mount -t tmpfs -o size=3D100 tmpfs /mnt
> =A0 =A0 =A0 =A0% touch /mnt/foobar
> =A0 =A0 =A0 =A0% echo hi > /mnt/foobar
> =A0 =A0 =A0 =A0% fallocate -o 3 -l 5000 /mnt/foobar
> =A0 =A0 =A0 =A0fallocate: /mnt/foobar: fallocate failed: No space left on=
 device
> =A0 =A0 =A0 =A0% fallocate -o 3 -l 3000 /mnt/foobar
> =A0 =A0 =A0 =A0% ls -l /mnt/foobar
> =A0 =A0 =A0 =A0-rw-rw-r-- 1 wangcong wangcong 3003 Nov 15 16:10 /mnt/foob=
ar
> =A0 =A0 =A0 =A0% dd if=3D/dev/zero of=3D/mnt/foobar seek=3D3 bs=3D1 count=
=3D3000
> =A0 =A0 =A0 =A03000+0 records in
> =A0 =A0 =A0 =A03000+0 records out
> =A0 =A0 =A0 =A03000 bytes (3.0 kB) copied, 0.0153224 s, 196 kB/s
> =A0 =A0 =A0 =A0% hexdump -C /mnt/foobar
> =A0 =A0 =A0 =A000000000 =A068 69 0a 00 00 00 00 00 =A000 00 00 00 00 00 0=
0 00 =A0|hi..............|
> =A0 =A0 =A0 =A000000010 =A000 00 00 00 00 00 00 00 =A000 00 00 00 00 00 0=
0 00 =A0|................|
> =A0 =A0 =A0 =A0*
> =A0 =A0 =A0 =A000000bb0 =A000 00 00 00 00 00 00 00 =A000 00 00 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 |...........|
> =A0 =A0 =A0 =A000000bbb
> =A0 =A0 =A0 =A0% cat /mnt/foobar
> =A0 =A0 =A0 =A0hi
>
> Signed-off-by: WANG Cong <amwang@redhat.com>

What's the use case for this?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
