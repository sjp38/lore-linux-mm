Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DA5D76B0069
	for <linux-mm@kvack.org>; Sat, 19 Nov 2011 09:15:13 -0500 (EST)
Received: by ghrr17 with SMTP id r17so1960473ghr.14
        for <linux-mm@kvack.org>; Sat, 19 Nov 2011 06:15:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111119100326.GA27967@infradead.org>
References: <1321612791-4764-1-git-send-email-amwang@redhat.com> <20111119100326.GA27967@infradead.org>
From: Kay Sievers <kay.sievers@vrfy.org>
Date: Sat, 19 Nov 2011 15:14:48 +0100
Message-ID: <CAPXgP10q8Fba3vr0zf-XBBaRPwjP7MyJ=-QRL45_8WC-vtotOg@mail.gmail.com>
Subject: Re: [V2 PATCH] tmpfs: add fallocate support
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Sat, Nov 19, 2011 at 11:03, Christoph Hellwig <hch@infradead.org> wrote:
> On Fri, Nov 18, 2011 at 06:39:50PM +0800, Cong Wang wrote:
>> It seems that systemd needs tmpfs to support fallocate,
>> see http://lkml.org/lkml/2011/10/20/275. This patch adds
>> fallocate support to tmpfs.
>
> What for exactly? =C2=A0Please explain why preallocating on tmpfs would
> make any sense.

To be able to safely use mmap(), regarding SIGBUS, on files on the
/dev/shm filesystem. The glibc fallback loop for -ENOSYS on fallocate
is just ugly.

Kay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
