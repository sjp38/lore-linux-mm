Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09261C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 19:46:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A1F520856
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 19:46:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Rm8Ri2tE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A1F520856
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5BAB6B0006; Wed, 28 Aug 2019 15:46:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0BD16B0008; Wed, 28 Aug 2019 15:46:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D22056B000C; Wed, 28 Aug 2019 15:46:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0211.hostedemail.com [216.40.44.211])
	by kanga.kvack.org (Postfix) with ESMTP id B19E36B0006
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 15:46:22 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 650B22839
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 19:46:22 +0000 (UTC)
X-FDA: 75872868204.12.mind66_54a10f636494f
X-HE-Tag: mind66_54a10f636494f
X-Filterd-Recvd-Size: 6309
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 19:46:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=hgz1R5QUT/3HwdqWiBoXJEjgsTAkIAv2dRGNBsyqnxk=; b=Rm8Ri2tEMBapDNdB3tS8NGKJBM
	z5Rq8Hj5vRSAxcFpyrTIzaG/+MT4NsQnvWV7/mV2hJF6gRa7y6uflXN/pKocPsEW3+1uIDcqhDT/d
	nVn5GK/ST6ZnS4k1deCvzxjlhOzDyvPUBhbmsaCbiqSy4yWGM5TlmlSbxvkYeV7PUGjKfq11w4O6d
	B6K21kFHA5FEY7Y5poC9Rbup6llyf0SFLQyUZGcPNKUtyKUUKmtqXMwj9rmC4ynL+BB6is1FCaG0v
	5RDdSskGb5hOH0jTQ1cq94H/Lpm3HBF4RN3Hl/sqRH3RcAUqISgadxnEhq3e2+jm9c50kgmalm08Y
	v6mF9MJw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i33tQ-0004Z6-3n; Wed, 28 Aug 2019 19:46:08 +0000
Date: Wed, 28 Aug 2019 12:46:08 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Christopher Lameter <cl@linux.com>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	linux-btrfs@vger.kernel.org
Subject: Re: [PATCH v2 2/2] mm, sl[aou]b: guarantee natural alignment for
 kmalloc(power-of-two)
Message-ID: <20190828194607.GB6590@bombadil.infradead.org>
References: <20190826111627.7505-1-vbabka@suse.cz>
 <20190826111627.7505-3-vbabka@suse.cz>
 <0100016cd98bb2c1-a2af7539-706f-47ba-a68e-5f6a91f2f495-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <0100016cd98bb2c1-a2af7539-706f-47ba-a68e-5f6a91f2f495-000000@email.amazonses.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 06:45:07PM +0000, Christopher Lameter wrote:
> > Ideally we should provide to mm users what they need without difficul=
t
> > workarounds or own reimplementations, so let's make the kmalloc() ali=
gnment to
> > size explicitly guaranteed for power-of-two sizes under all configura=
tions.
>=20
> The objection remains that this will create exceptions for the general
> notion that all kmalloc caches are aligned to KMALLOC_MINALIGN which ma=
y

Hmm?  kmalloc caches will be aligned to both KMALLOC_MINALIGN and the
natural alignment of the object.

> be suprising and it limits the optimizations that slab allocators may u=
se
> for optimizing data use. The SLOB allocator was designed in such a way
> that data wastage is limited. The changes here sabotage that goal and s=
how
> that future slab allocators may be similarly constrained with the
> exceptional alignents implemented. Additional debugging features etc et=
c
> must all support the exceptional alignment requirements.

While I sympathise with the poor programmer who has to write the
fourth implementation of the sl*b interface, it's more for the pain of
picking a new letter than the pain of needing to honour the alignment
of allocations.

There are many places in the kernel which assume alignment.  They break
when it's not supplied.  I believe we have a better overall system if
the MM developers provide stronger guarantees than the MM consumers have
to work around only weak guarantees.

> > * SLOB has no implicit alignment so this patch adds it explicitly for
> >   kmalloc(). The potential downside is increased fragmentation. While
> >   pathological allocation scenarios are certainly possible, in my tes=
ting,
> >   after booting a x86_64 kernel+userspace with virtme, around 16MB me=
mory
> >   was consumed by slab pages both before and after the patch, with di=
fference
> >   in the noise.
>=20
> This change to slob will cause a significant additional use of memory. =
The
> advertised advantage of SLOB is that *minimal* memory will be used sinc=
e
> it is targeted for embedded systems. Different types of slab objects of
> varying sizes can be allocated in the same memory page to reduce
> allocation overhead.

Did you not read the part where he said the difference was in the noise?

> The result of this patch is just to use more memory to be safe from
> certain pathologies where one subsystem was relying on an alignment tha=
t
> was not specified. That is why this approach should not be called
> =EF=BF=BDnatural" but "implicit alignment". The one using the slab cach=
e is not
> aware that the slab allocator provides objects aligned in a special way
> (which is in general not needed. There seems to be a single pathologica=
l
> case that needs to be addressed and I thought that was due to some
> brokenness in the hardware?).

It turns out there are lots of places which assume this, including the
pmem driver, the ramdisk driver and a few other similar drivers.

> It is better to ensure that subsystems that require special alignment
> explicitly tell the allocator about this.

But it's not the subsystems which have this limitation which do the
allocation; it's the subsystems who allocate the memory that they then
pass to the subsystems.  So you're forcing communication of these limits
up & down the stack.

> I still think implicit exceptions to alignments are a bad idea. Those n=
eed
> to be explicity specified and that is possible using kmem_cache_create(=
).

I swear we covered this last time the topic came up, but XFS would need
to create special slab caches for each size between 512 and PAGE_SIZE.
Potentially larger, depending on whether the MM developers are willing to
guarantee that kmalloc(PAGE_SIZE * 2, GFP_KERNEL) will return a PAGE_SIZE
aligned block of memory indefinitely.

