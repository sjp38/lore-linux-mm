Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	SUBJ_ALL_CAPS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00CE1C3A59D
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 17:45:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6771205F4
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 17:45:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="kFhvV6e4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6771205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 360446B0003; Fri, 16 Aug 2019 13:45:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 311946B0005; Fri, 16 Aug 2019 13:45:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FFDD6B0007; Fri, 16 Aug 2019 13:45:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0251.hostedemail.com [216.40.44.251])
	by kanga.kvack.org (Postfix) with ESMTP id EECEB6B0003
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 13:45:05 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8E38A181AC9B4
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:45:05 +0000 (UTC)
X-FDA: 75829016970.19.man57_497ee5f88c258
X-HE-Tag: man57_497ee5f88c258
X-Filterd-Recvd-Size: 7693
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:45:04 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id t12so6935148qtp.9
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 10:45:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=VTE5az9jXAZ/GTAJ0HVMKCQLaE9Hs979hVLwdwTkSkU=;
        b=kFhvV6e48icM76XefFjDspT3nrFkYY+PUCIMphaQc+97OrdF/atayHtcWo8acuYnVH
         4NmDvj+PVaiSCRlVraXnRUDODucrzsXCg4PXglsbJKE7UedOiBj+MEjvbluI697qBRJS
         4QOvc71X/lJItm4WlIIU1uPSsMu8j6UvM8PgyxjJc+tgZXUnXB/aW10FoOrMxViRiLxS
         HwAw57i779Cwiq2NW7dqPxVArVkFTSAYYrlL0/UhdCL8aDJElUO/eScnCq0aB1R7hsNu
         2pITTkDzc4k1o5WzGZekQD1MCedf0MAWpbKGHug0By7ey2fRB2DFa1rzsOgBwl/bRxYv
         FssQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=VTE5az9jXAZ/GTAJ0HVMKCQLaE9Hs979hVLwdwTkSkU=;
        b=YWMQCUoI0hCiAv0miA0kAwLlIxpnnIsIyXMqzpSrw2OLeKwZIClfL/M9s0rgV3kWo1
         Tk3k5D0wOa92PiCcDxu36idXN+S7X+Jd4f9oTLs6u0nCi01Y5z10C+GPsAG6Egf4X4au
         uQdpGblwL12awMp34hQUJpvJrE8hCrDpU1FQwYNWBSTQljEg1xM7Bzy8tyaAaP4/hXw8
         xcOCHRUplMxCc195AkWXeiVlXZrrWLr4NL0I/GTkWjmhJTtNCgCNVAJRsJbAOyVNiGlN
         ddoILiLbNrCB2XkLknlK8jIgleK7IDdb+uyq+6JIOQHFsy50usayyYwQCGIXlMMtWpW/
         Nd9Q==
X-Gm-Message-State: APjAAAW6Viz0brz+S/251L3edqkYGiRJ7qXMYkCothQZgMVMXzA5QPX8
	kU7hH+9Ucj2p6kOUJNBmco7H2w==
X-Google-Smtp-Source: APXvYqxTAWW+7pmnnBoU60JZDalqhWkKJSQI6jSTubnTX5pk4HZnFygt0x7/41XtD0FkRWw9YXi5Hg==
X-Received: by 2002:a0c:fd91:: with SMTP id p17mr2691538qvr.170.1565977504254;
        Fri, 16 Aug 2019 10:45:04 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id h26sm3468230qta.58.2019.08.16.10.45.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 16 Aug 2019 10:45:03 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hygHf-00016W-92; Fri, 16 Aug 2019 14:45:03 -0300
Date: Fri, 16 Aug 2019 14:45:03 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Adalbert =?utf-8?B?TGF6xINy?= <alazar@bitdefender.com>,
	Matthew Wilcox <willy@infradead.org>, kvm@vger.kernel.org,
	linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?utf-8?Q?Laur=C3=A9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>,
	Yu C <yu.c.zhang@intel.com>,
	Mihai =?utf-8?B?RG9uyJt1?= <mdontu@bitdefender.com>,
	Mircea =?utf-8?B?Q8OucmphbGl1?= <mcirjaliu@bitdefender.com>
Subject: Re: DANGER WILL ROBINSON, DANGER
Message-ID: <20190816174503.GK5398@ziepe.ca>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-72-alazar@bitdefender.com>
 <20190809162444.GP5482@bombadil.infradead.org>
 <1565694095.D172a51.28640.@15f23d3a749365d981e968181cce585d2dcb3ffa>
 <20190815191929.GA9253@redhat.com>
 <20190815201630.GA25517@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190815201630.GA25517@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 04:16:30PM -0400, Jerome Glisse wrote:
> On Thu, Aug 15, 2019 at 03:19:29PM -0400, Jerome Glisse wrote:
> > On Tue, Aug 13, 2019 at 02:01:35PM +0300, Adalbert Laz=C4=83r wrote:
> > > On Fri, 9 Aug 2019 09:24:44 -0700, Matthew Wilcox <willy@infradead.=
org> wrote:
> > > > On Fri, Aug 09, 2019 at 07:00:26PM +0300, Adalbert Laz=C4=83r wro=
te:
> > > > > +++ b/include/linux/page-flags.h
> > > > > @@ -417,8 +417,10 @@ PAGEFLAG(Idle, idle, PF_ANY)
> > > > >   */
> > > > >  #define PAGE_MAPPING_ANON	0x1
> > > > >  #define PAGE_MAPPING_MOVABLE	0x2
> > > > > +#define PAGE_MAPPING_REMOTE	0x4
> > > >=20
> > > > Uh.  How do you know page->mapping would otherwise have bit 2 cle=
ar?
> > > > Who's guaranteeing that?
> > > >=20
> > > > This is an awfully big patch to the memory management code, burie=
d in
> > > > the middle of a gigantic series which almost guarantees nobody wo=
uld
> > > > look at it.  I call shenanigans.
> > > >=20
> > > > > @@ -1021,7 +1022,7 @@ void page_move_anon_rmap(struct page *pag=
e, struct vm_area_struct *vma)
> > > > >   * __page_set_anon_rmap - set up new anonymous rmap
> > > > >   * @page:	Page or Hugepage to add to rmap
> > > > >   * @vma:	VM area to add page to.
> > > > > - * @address:	User virtual address of the mapping=09
> > > > > + * @address:	User virtual address of the mapping
> > > >=20
> > > > And mixing in fluff changes like this is a real no-no.  Try again=
.
> > > >=20
> > >=20
> > > No bad intentions, just overzealous.
> > > I didn't want to hide anything from our patches.
> > > Once we advance with the introspection patches related to KVM we'll=
 be
> > > back with the remote mapping patch, split and cleaned.
> >=20
> > They are not bit left in struct page ! Looking at the patch it seems
> > you want to have your own pin count just for KVM. This is bad, we are
> > already trying to solve the GUP thing (see all various patchset about
> > GUP posted recently).
> >=20
> > You need to rethink how you want to achieve this. Why not simply a
> > remote read()/write() into the process memory ie KVMI would call
> > an ioctl that allow to read or write into a remote process memory
> > like ptrace() but on steroid ...
> >=20
> > Adding this whole big complex infrastructure without justification
> > of why we need to avoid round trip is just too much really.
>=20
> Thinking a bit more about this, you can achieve the same thing without
> adding a single line to any mm code. Instead of having mmap with
> PROT_NONE | MAP_LOCKED you have userspace mmap some kvm device file
> (i am assuming this is something you already have and can control
> the mmap callback).
>=20
> So now kernel side you have a vma with a vm_operations_struct under
> your control this means that everything you want to block mm wise
> from within the inspector process can be block through those call-
> backs (find_special_page() specificaly for which you have to return
> NULL all the time).

I'm actually aware of a couple of use cases that would like to
mirror the VA of one process into another. One big one in the HPC
world is the out of tree 'xpmem' still in wide use today. xpmem is
basically what Jerome described above.

If you do an approach like Jerome describes it would be nice if was a
general facility and not buried in kvm.

I know past xpmem adventures ran into trouble with locking/etc - ie
getting the mm_struct of the victim seemed a bit hard for some reason,
but maybe that could be done with a FD pass 'ioctl(I AM THE VICITM)' ?

Jason

