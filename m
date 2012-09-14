Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id D3DE76B0253
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 09:15:39 -0400 (EDT)
Subject: Re: [PATCH 0/3] KVM: PPC: Book3S HV: More flexible allocator for linear memory
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Alexander Graf <agraf@suse.de>
In-Reply-To: <20120914124504.GF15028@bloggs.ozlabs.ibm.com>
Date: Fri, 14 Sep 2012 15:15:32 +0200
Content-Transfer-Encoding: quoted-printable
Message-Id: <C8AA7FDF-A559-46CF-8A6E-8D8B8163D38E@suse.de>
References: <20120912003427.GH32642@bloggs.ozlabs.ibm.com> <9650229C-2512-4684-98EC-6E252E47C4A9@suse.de> <20120914081140.GC15028@bloggs.ozlabs.ibm.com> <F7ED8384-5B23-478C-B2B7-927A3A755E98@suse.de> <20120914124504.GF15028@bloggs.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: kvm-ppc@vger.kernel.org, KVM list <kvm@vger.kernel.org>, linux-mm@kvack.org, mina86@mina86.com


On 14.09.2012, at 14:45, Paul Mackerras wrote:

> On Fri, Sep 14, 2012 at 02:13:37PM +0200, Alexander Graf wrote:
>=20
>> So do you think it makes more sense to reimplement a large page =
allocator in KVM, as this patch set does, or improve CMA to get us =
really big chunks of linear memory?
>>=20
>> Let's ask the Linux mm guys too :). Maybe they have an idea.
>=20
> I asked the authors of CMA, and apparently it's not limited to
> MAX_ORDER as I feared.  It has the advantage that the memory can be
> used for other things such as page cache when it's not needed, but not
> for immovable allocations such as kmalloc.  I'm going to try it out.
> It will need a patch to increase the maximum alignment it allows.

Awesome. Thanks a lot. I'd really prefer if we can stick to generic =
Linux solutions rather than invent our own :).


Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
