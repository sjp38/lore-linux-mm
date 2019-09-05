Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,SUBJ_ALL_CAPS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 771A9C43140
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 18:10:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B60D206BA
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 18:10:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B60D206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C02C66B0003; Thu,  5 Sep 2019 14:10:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB3E06B0005; Thu,  5 Sep 2019 14:10:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA5AB6B0007; Thu,  5 Sep 2019 14:10:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0252.hostedemail.com [216.40.44.252])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1C46B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:10:04 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 220C2181AC9B4
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:10:04 +0000 (UTC)
X-FDA: 75901655928.28.heat00_7e5c2ce7a59
X-HE-Tag: heat00_7e5c2ce7a59
X-Filterd-Recvd-Size: 8190
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:10:03 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B0961315C009;
	Thu,  5 Sep 2019 18:10:01 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 925325D6A3;
	Thu,  5 Sep 2019 18:09:57 +0000 (UTC)
Date: Thu, 5 Sep 2019 14:09:55 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Mircea CIRJALIU - MELIU <mcirjaliu@bitdefender.com>
Cc: Adalbert =?utf-8?B?TGF6xINy?= <alazar@bitdefender.com>,
	Matthew Wilcox <willy@infradead.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?Q?Laur=E9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>,
	Yu C <yu.c.zhang@intel.com>,
	Mihai =?utf-8?B?RG9uyJt1?= <mdontu@bitdefender.com>
Subject: Re: DANGER WILL ROBINSON, DANGER
Message-ID: <20190905180955.GA3251@redhat.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-72-alazar@bitdefender.com>
 <20190809162444.GP5482@bombadil.infradead.org>
 <1565694095.D172a51.28640.@15f23d3a749365d981e968181cce585d2dcb3ffa>
 <20190815191929.GA9253@redhat.com>
 <20190815201630.GA25517@redhat.com>
 <VI1PR02MB398411CA9A56081FF4D1248EBBA40@VI1PR02MB3984.eurprd02.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <VI1PR02MB398411CA9A56081FF4D1248EBBA40@VI1PR02MB3984.eurprd02.prod.outlook.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 05 Sep 2019 18:10:02 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 23, 2019 at 12:39:21PM +0000, Mircea CIRJALIU - MELIU wrote:
> > On Thu, Aug 15, 2019 at 03:19:29PM -0400, Jerome Glisse wrote:
> > > On Tue, Aug 13, 2019 at 02:01:35PM +0300, Adalbert Laz=C4=83r wrote=
:
> > > > On Fri, 9 Aug 2019 09:24:44 -0700, Matthew Wilcox <willy@infradea=
d.org>
> > wrote:
> > > > > On Fri, Aug 09, 2019 at 07:00:26PM +0300, Adalbert Laz=C4=83r w=
rote:
> > > > > > +++ b/include/linux/page-flags.h
> > > > > > @@ -417,8 +417,10 @@ PAGEFLAG(Idle, idle, PF_ANY)
> > > > > >   */
> > > > > >  #define PAGE_MAPPING_ANON	0x1
> > > > > >  #define PAGE_MAPPING_MOVABLE	0x2
> > > > > > +#define PAGE_MAPPING_REMOTE	0x4
> > > > >
> > > > > Uh.  How do you know page->mapping would otherwise have bit 2
> > clear?
> > > > > Who's guaranteeing that?
> > > > >
> > > > > This is an awfully big patch to the memory management code, bur=
ied
> > > > > in the middle of a gigantic series which almost guarantees nobo=
dy
> > > > > would look at it.  I call shenanigans.
> > > > >
> > > > > > @@ -1021,7 +1022,7 @@ void page_move_anon_rmap(struct page
> > *page, struct vm_area_struct *vma)
> > > > > >   * __page_set_anon_rmap - set up new anonymous rmap
> > > > > >   * @page:	Page or Hugepage to add to rmap
> > > > > >   * @vma:	VM area to add page to.
> > > > > > - * @address:	User virtual address of the mapping
> > > > > > + * @address:	User virtual address of the mapping
> > > > >
> > > > > And mixing in fluff changes like this is a real no-no.  Try aga=
in.
> > > > >
> > > >
> > > > No bad intentions, just overzealous.
> > > > I didn't want to hide anything from our patches.
> > > > Once we advance with the introspection patches related to KVM we'=
ll
> > > > be back with the remote mapping patch, split and cleaned.
> > >
> > > They are not bit left in struct page ! Looking at the patch it seem=
s
> > > you want to have your own pin count just for KVM. This is bad, we a=
re
> > > already trying to solve the GUP thing (see all various patchset abo=
ut
> > > GUP posted recently).
> > >
> > > You need to rethink how you want to achieve this. Why not simply a
> > > remote read()/write() into the process memory ie KVMI would call an
> > > ioctl that allow to read or write into a remote process memory like
> > > ptrace() but on steroid ...
> > >
> > > Adding this whole big complex infrastructure without justification =
of
> > > why we need to avoid round trip is just too much really.
> >=20
> > Thinking a bit more about this, you can achieve the same thing withou=
t
> > adding a single line to any mm code. Instead of having mmap with
> > PROT_NONE | MAP_LOCKED you have userspace mmap some kvm device
> > file (i am assuming this is something you already have and can contro=
l the
> > mmap callback).
> >=20
> > So now kernel side you have a vma with a vm_operations_struct under y=
our
> > control this means that everything you want to block mm wise from wit=
hin
> > the inspector process can be block through those call- backs
> > (find_special_page() specificaly for which you have to return NULL al=
l the
> > time).
> >=20
> > To mirror target process memory you can use hmm_mirror, when you
> > populate the inspector process page table you use insert_pfn() (mmap =
of
> > the kvm device file must mark this vma as PFNMAP).
> >=20
> > By following the hmm_mirror API, anytime the target process has a cha=
nge in
> > its page table (ie virtual address -> page) you will get a callback a=
nd all you
> > have to do is clear the page table within the inspector process and f=
lush tlb
> > (use zap_page_range).
> >=20
> > On page fault within the inspector process the fault callback of vm_o=
ps will
> > get call and from there you call hmm_mirror following its API.
> >=20
> > Oh also mark the vma with VM_WIPEONFORK to avoid any issue if the
> > inspector process use fork() (you could support fork but then you wou=
ld
> > need to mark the vma as SHARED and use unmap_mapping_pages instead of
> > zap_page_range).
> >=20
> >=20
> > There everything you want to do with already upstream mm code.
>=20
> I'm the author of remote mapping, so I owe everybody some explanations.
> My requirement was to map pages from one QEMU process to another QEMU=20
> process (our inspector process works in a virtual machine of its own). =
So I had=20
> to implement a KSM-like page sharing between processes, where an anon p=
age
> from the target QEMU's working memory is promoted to a remote page and=20
> mapped in the inspector QEMU's working memory (both anon VMAs).=20
> The extra page flag is for differentiating the page for rmap walking.
>=20
> The mapping requests come at PAGE_SIZE granularity for random addresses=
=20
> within the target/inspector QEMUs, so I couldn't do any linear mapping =
that
> would keep things simpler.=20
>=20
> I have an extra patch that does remote mapping by mirroring an entire V=
MA
> from the target process by way of a device file. This thing creates a s=
eparate=20
> mirror VMA in my inspector process (at the moment a QEMU), but then I=20
> bumped into the KVM hva->gpa mapping, which makes it hard to override=20
> mappings with addresses outside memslot associated VMAs.

Not sure i understand, you are saying that the solution i outline above
does not work ? If so then i think you are wrong, in the above solution
the importing process mmap a device file and the resulting vma is then
populated using insert_pfn() and constantly keep synchronize with the
target process through mirroring which means that you never have to look
at the struct page ... you can mirror any kind of memory from the remote
process.

Am i miss-understanding something here ?

Cheers,
J=C3=A9r=C3=B4me

