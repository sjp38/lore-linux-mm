Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	SUBJ_ALL_CAPS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BDA3C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 11:01:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA3E92067D
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 11:01:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA3E92067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8136D6B0005; Tue, 13 Aug 2019 07:01:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C3276B0006; Tue, 13 Aug 2019 07:01:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68BCD6B0007; Tue, 13 Aug 2019 07:01:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0158.hostedemail.com [216.40.44.158])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6B96B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 07:01:12 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id DBE10181AC9AE
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:01:11 +0000 (UTC)
X-FDA: 75817112742.04.dress14_a645035c9d3f
X-HE-Tag: dress14_a645035c9d3f
X-Filterd-Recvd-Size: 3170
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com [91.199.104.161])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:01:11 +0000 (UTC)
Received: from smtp.bitdefender.com (smtp01.buh.bitdefender.com [10.17.80.75])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 0684E30644BA;
	Tue, 13 Aug 2019 14:01:09 +0300 (EEST)
Received: from localhost (unknown [195.210.4.22])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id DD06730BFDC3;
	Tue, 13 Aug 2019 14:01:08 +0300 (EEST)
From: Adalbert =?iso-8859-2?b?TGF643I=?= <alazar@bitdefender.com>
Subject: Re: DANGER WILL ROBINSON, DANGER
To: Matthew Wilcox <willy@infradead.org>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org,
	virtualization@lists.linux-foundation.org, Paolo Bonzini
	<pbonzini@redhat.com>, Radim =?iso-8859-2?b?S3LobeH4?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tamas K Lengyel
	<tamas@tklengyel.com>, Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?q?Laur=E9n?= <samuel.lauren@iki.fi>, Patrick Colp
	<patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>, Weijiang Yang
	<weijiang.yang@intel.com>, Yu C <yu.c.zhang@intel.com>,
	Mihai =?UTF-8?b?RG9uyJt1?= <mdontu@bitdefender.com>,
	Mircea =?iso-8859-1?q?C=EErjaliu?= <mcirjaliu@bitdefender.com>
In-Reply-To: <20190809162444.GP5482@bombadil.infradead.org>
References: <20190809160047.8319-1-alazar@bitdefender.com>
	<20190809160047.8319-72-alazar@bitdefender.com>
	<20190809162444.GP5482@bombadil.infradead.org>
Date: Tue, 13 Aug 2019 14:01:35 +0300
Message-ID: <1565694095.D172a51.28640.@15f23d3a749365d981e968181cce585d2dcb3ffa>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000831, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 9 Aug 2019 09:24:44 -0700, Matthew Wilcox <willy@infradead.org> w=
rote:
> On Fri, Aug 09, 2019 at 07:00:26PM +0300, Adalbert Laz=C4=83r wrote:
> > +++ b/include/linux/page-flags.h
> > @@ -417,8 +417,10 @@ PAGEFLAG(Idle, idle, PF_ANY)
> >   */
> >  #define PAGE_MAPPING_ANON	0x1
> >  #define PAGE_MAPPING_MOVABLE	0x2
> > +#define PAGE_MAPPING_REMOTE	0x4
>=20
> Uh.  How do you know page->mapping would otherwise have bit 2 clear?
> Who's guaranteeing that?
>=20
> This is an awfully big patch to the memory management code, buried in
> the middle of a gigantic series which almost guarantees nobody would
> look at it.  I call shenanigans.
>=20
> > @@ -1021,7 +1022,7 @@ void page_move_anon_rmap(struct page *page, str=
uct vm_area_struct *vma)
> >   * __page_set_anon_rmap - set up new anonymous rmap
> >   * @page:	Page or Hugepage to add to rmap
> >   * @vma:	VM area to add page to.
> > - * @address:	User virtual address of the mapping=09
> > + * @address:	User virtual address of the mapping
>=20
> And mixing in fluff changes like this is a real no-no.  Try again.
>=20

No bad intentions, just overzealous.
I didn't want to hide anything from our patches.
Once we advance with the introspection patches related to KVM we'll be
back with the remote mapping patch, split and cleaned.

Thanks

