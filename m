Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,SUBJ_ALL_CAPS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72BB8C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:16:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37A172171F
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:16:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37A172171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF5A26B0275; Thu, 15 Aug 2019 16:16:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAF4E6B0277; Thu, 15 Aug 2019 16:16:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B94966B027A; Thu, 15 Aug 2019 16:16:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0111.hostedemail.com [216.40.44.111])
	by kanga.kvack.org (Postfix) with ESMTP id 997E76B0275
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:16:38 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 52FDC83EA
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:16:38 +0000 (UTC)
X-FDA: 75825770076.03.tub49_1cc42b5b62f08
X-HE-Tag: tub49_1cc42b5b62f08
X-Filterd-Recvd-Size: 5967
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:16:37 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5257BC057EC6;
	Thu, 15 Aug 2019 20:16:36 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 2ED628CF81;
	Thu, 15 Aug 2019 20:16:32 +0000 (UTC)
Date: Thu, 15 Aug 2019 16:16:30 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Adalbert =?utf-8?B?TGF6xINy?= <alazar@bitdefender.com>
Cc: Matthew Wilcox <willy@infradead.org>, kvm@vger.kernel.org,
	linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
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
	Mihai =?utf-8?B?RG9uyJt1?= <mdontu@bitdefender.com>,
	Mircea =?iso-8859-1?Q?C=EErjaliu?= <mcirjaliu@bitdefender.com>
Subject: Re: DANGER WILL ROBINSON, DANGER
Message-ID: <20190815201630.GA25517@redhat.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-72-alazar@bitdefender.com>
 <20190809162444.GP5482@bombadil.infradead.org>
 <1565694095.D172a51.28640.@15f23d3a749365d981e968181cce585d2dcb3ffa>
 <20190815191929.GA9253@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190815191929.GA9253@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 15 Aug 2019 20:16:36 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 03:19:29PM -0400, Jerome Glisse wrote:
> On Tue, Aug 13, 2019 at 02:01:35PM +0300, Adalbert Laz=C4=83r wrote:
> > On Fri, 9 Aug 2019 09:24:44 -0700, Matthew Wilcox <willy@infradead.or=
g> wrote:
> > > On Fri, Aug 09, 2019 at 07:00:26PM +0300, Adalbert Laz=C4=83r wrote=
:
> > > > +++ b/include/linux/page-flags.h
> > > > @@ -417,8 +417,10 @@ PAGEFLAG(Idle, idle, PF_ANY)
> > > >   */
> > > >  #define PAGE_MAPPING_ANON	0x1
> > > >  #define PAGE_MAPPING_MOVABLE	0x2
> > > > +#define PAGE_MAPPING_REMOTE	0x4
> > >=20
> > > Uh.  How do you know page->mapping would otherwise have bit 2 clear=
?
> > > Who's guaranteeing that?
> > >=20
> > > This is an awfully big patch to the memory management code, buried =
in
> > > the middle of a gigantic series which almost guarantees nobody woul=
d
> > > look at it.  I call shenanigans.
> > >=20
> > > > @@ -1021,7 +1022,7 @@ void page_move_anon_rmap(struct page *page,=
 struct vm_area_struct *vma)
> > > >   * __page_set_anon_rmap - set up new anonymous rmap
> > > >   * @page:	Page or Hugepage to add to rmap
> > > >   * @vma:	VM area to add page to.
> > > > - * @address:	User virtual address of the mapping=09
> > > > + * @address:	User virtual address of the mapping
> > >=20
> > > And mixing in fluff changes like this is a real no-no.  Try again.
> > >=20
> >=20
> > No bad intentions, just overzealous.
> > I didn't want to hide anything from our patches.
> > Once we advance with the introspection patches related to KVM we'll b=
e
> > back with the remote mapping patch, split and cleaned.
>=20
> They are not bit left in struct page ! Looking at the patch it seems
> you want to have your own pin count just for KVM. This is bad, we are
> already trying to solve the GUP thing (see all various patchset about
> GUP posted recently).
>=20
> You need to rethink how you want to achieve this. Why not simply a
> remote read()/write() into the process memory ie KVMI would call
> an ioctl that allow to read or write into a remote process memory
> like ptrace() but on steroid ...
>=20
> Adding this whole big complex infrastructure without justification
> of why we need to avoid round trip is just too much really.

Thinking a bit more about this, you can achieve the same thing without
adding a single line to any mm code. Instead of having mmap with
PROT_NONE | MAP_LOCKED you have userspace mmap some kvm device file
(i am assuming this is something you already have and can control
the mmap callback).

So now kernel side you have a vma with a vm_operations_struct under
your control this means that everything you want to block mm wise
from within the inspector process can be block through those call-
backs (find_special_page() specificaly for which you have to return
NULL all the time).

To mirror target process memory you can use hmm_mirror, when you
populate the inspector process page table you use insert_pfn()
(mmap of the kvm device file must mark this vma as PFNMAP).

By following the hmm_mirror API, anytime the target process has
a change in its page table (ie virtual address -> page) you will
get a callback and all you have to do is clear the page table
within the inspector process and flush tlb (use zap_page_range).

On page fault within the inspector process the fault callback of
vm_ops will get call and from there you call hmm_mirror following
its API.

Oh also mark the vma with VM_WIPEONFORK to avoid any issue if the
inspector process use fork() (you could support fork but then you
would need to mark the vma as SHARED and use unmap_mapping_pages
instead of zap_page_range).


There everything you want to do with already upstream mm code.

Cheers,
J=C3=A9r=C3=B4me

