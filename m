Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1634D6B02A6
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 00:36:44 -0400 (EDT)
Received: by iwn2 with SMTP id 2so4979438iwn.14
        for <linux-mm@kvack.org>; Sun, 18 Jul 2010 21:36:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4C42B98E.4020208@vflare.org>
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org>
	<1279283870-18549-8-git-send-email-ngupta@vflare.org>
	<4C42B2E4.4040504@cs.helsinki.fi>
	<4C42B98E.4020208@vflare.org>
Date: Mon, 19 Jul 2010 13:36:42 +0900
Message-ID: <AANLkTinjJLaDVenwNcxgN7ycr97XLN_DVi1ckXBZetZm@mail.gmail.com>
Subject: Re: [PATCH 7/8] Use xvmalloc to store compressed chunks
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Nitin,

On Sun, Jul 18, 2010 at 5:21 PM, Nitin Gupta <ngupta@vflare.org> wrote:
> On 07/18/2010 01:23 PM, Pekka Enberg wrote:
>> Nitin Gupta wrote:
>>> @@ -528,17 +581,32 @@ static int zcache_store_page(struct zcache_inode_=
rb *znode,
>>> =A0 =A0 =A0 =A0 =A0goto out;
>>> =A0 =A0 =A0}
>>>
>>> - =A0 =A0dest_data =3D kmap_atomic(zpage, KM_USER0);
>>> + =A0 =A0local_irq_save(flags);
>>
>> Does xv_malloc() required interrupts to be disabled? If so, why doesn't =
the function do it by itself?
>>
>
>
> xvmalloc itself doesn't require disabling interrupts but zcache needs tha=
t since
> otherwise, we can have deadlock between xvmalloc pool lock and mapping->t=
ree_lock
> which zcache_put_page() is called. OTOH, zram does not require this disab=
ling of
> interrupts. So, interrupts are disable separately for zcache case.

cleancache_put_page always is called with spin_lock_irq.
Couldn't we replace spin_lock_irq_save with spin_lock?

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
