Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8C75D6B01AC
	for <linux-mm@kvack.org>; Sun, 21 Mar 2010 05:38:45 -0400 (EDT)
Received: by pxi32 with SMTP id 32so269440pxi.1
        for <linux-mm@kvack.org>; Sun, 21 Mar 2010 02:38:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1002232014200.15526@router.home>
References: <17cb70ee1002231646m508f6483mcb667d4e67d9807f@mail.gmail.com>
	 <alpine.DEB.2.00.1002231744110.3435@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1002232014200.15526@router.home>
Date: Sun, 21 Mar 2010 10:38:45 +0100
Message-ID: <17cb70ee1003210238u72aedb0dr78f7909ee4964d4b@mail.gmail.com>
Subject: Re: way to allocate memory within a range ?
From: Auguste Mome <augustmome@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

OK thanks for your comments, I found that mempool() API can do the job
I need, because
I can live with a fixed size for allocated object, so I plan to
populate the pool by adding all the
"cells" of the given range.
My use case is another module aside Linux that would map the the same
memory area.

August.

On Wed, Feb 24, 2010 at 4:35 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> On Tue, 23 Feb 2010, David Rientjes wrote:
>
>> > Or slab/slub system is not designed for this, I should forget it and
>> > opt for another system?
>> >
>>
>> No slab allocator is going to be designed for that other than SLAB_DMA t=
o
>> allocate from lowmem. =C2=A0If you don't have need for lowmem, why do yo=
u need
>> memory only from a certain range? =C2=A0I can imagine it would have a us=
ecase
>> for memory hotplug to avoid allocating slab that cannot be reclaimed on
>> certain nodes, but ZONE_MOVABLE seems more appropriate to guarantee such
>> migration properties.
>
> Awhile ago I posted a patch to do just that. It was called
> alloc_pages_range() and the intend was to replace the dma zone.
>
> http://lkml.indiana.edu/hypermail/linux/kernel/0609.2/2096.html
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
