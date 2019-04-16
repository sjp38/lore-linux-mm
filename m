Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FDB9C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 19:12:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0C2D2064A
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 19:12:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="y8z2MuTd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0C2D2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54A7C6B0003; Tue, 16 Apr 2019 15:12:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F9936B0006; Tue, 16 Apr 2019 15:12:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4111C6B0007; Tue, 16 Apr 2019 15:12:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9B96B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 15:12:40 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id x125so10441167oix.17
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 12:12:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=uEembVKRKTdGwQr4qw9SzELlxKxNaEg4sPBRNCMjY+8=;
        b=soQnL/evX27aYaw99CZz1FbWjs3NPjxUQePalorkhEPS/5wlRVaD5IJ8Rh+fkPzzsJ
         aYk1oY17PsPWWULMkfb1tMnTx7JrsHk6J3if/CgtHAbqGNksMeuC0fwOozggzQTy7OqJ
         VeUy66cQ8pgpHoV8sr/4xQPobvwGweu/tIIKBTUT4ceeI+gePhp/GJBTIGO5zlnJeSRV
         lKNVndtyT3AKht2cUA+tCUKlgf9SnxGiGutRy/KpsdSE0io5/1HdnltIuIKGuB8Ld4JI
         VChNG7qjKv9E++SENkYUR97vXLTI9ML8GC3pKV4ffDPu1ndzDZXXG56akJYBsJVj0qd6
         Pj1g==
X-Gm-Message-State: APjAAAVclXBphqCCVEa6sjlwQbZNMxg5nvnzVNnLpM/FRZ48JJUJRN3W
	uuzxCRWCEmPDmfb8yFKEJDaIva4O68jfhMICCHAxCki8cYG4uckrxMZ3HAclMOS2+Fhfyj27PQ7
	HHAqBEbVKhwNxTwhNpCtC/WA6/WXNRVFAKfH7/qMedpgZJnzCtfA/2E+2YWHSDo2PVg==
X-Received: by 2002:a9d:5e90:: with SMTP id f16mr49004288otl.86.1555441959778;
        Tue, 16 Apr 2019 12:12:39 -0700 (PDT)
X-Received: by 2002:a9d:5e90:: with SMTP id f16mr49004231otl.86.1555441958990;
        Tue, 16 Apr 2019 12:12:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555441958; cv=none;
        d=google.com; s=arc-20160816;
        b=XOUgtn071zQPFFN0klzOkkWepB8nJAnEIlSFOIJB6xELb4i76KRVY1st2wNXea3Noq
         47UQD8vngPsL9K4Pcp4TYphsJAAbE6T2QwhV9tFPtV1ZekyCH2QtLZE1aXIehZ0xd+jd
         m9CFpVlaO9Wwb4EBaX8jpUDEGEyBDgZ9i1fXHZpR49IGi5vt/9vGVcS6nhY12Qg+UeZ4
         jm7bSjL8x4mnS0+opMcTd5PQBUjZYhIH9N0FQla+GBzmUHHN54pTCQli9z/2k8rOtoQ5
         s/prDRTJ7ih8OI0lt2mcIJepk54/7UoUMHH/CCOMvwqBWv3VUL9SPLJF4s5iKhNDbcJl
         De1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=uEembVKRKTdGwQr4qw9SzELlxKxNaEg4sPBRNCMjY+8=;
        b=RsT1pxQ0sc7m2DkduCDveJWzTG21y6PA34M2z9OPHs/myO5P2I2Ob3h05oaa1feqXi
         xgQOUJVyQdPt17U06MEwQATAClOPi5+lf1UzkRZLMnqYy8xofFOiNlRWwiiiIdZVyY1H
         zNXpSG2jE+FXjV5X46xrF5BBflz7uTU9SWGGm7Vk+NFIU51f4HEl6aQgKEZDnIPteW5F
         X+Ma1xX0JkXfFoAS9urHBNao7b2YYdNiyYZ4a4u0qkBjoF39LaOAJWdVpFeSb/xjJThR
         J8Xb2WToJOQxZpFHGbXdUruCIN4J1adsn/SVjfNCYT891kPuctLv5plPRbkpchpocc2y
         7ppA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=y8z2MuTd;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p188sor29021113oih.22.2019.04.16.12.12.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 12:12:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=y8z2MuTd;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=uEembVKRKTdGwQr4qw9SzELlxKxNaEg4sPBRNCMjY+8=;
        b=y8z2MuTdmDyGRpnK0GHJTeCgMCZBs+JPXam543xK3GpwUMU/l302sdbIaf9QhP8xgJ
         utDRzubuZDcUbZ/ZPe0KiEp/x5oTJRLyeI7U1UK45ZkyNghvew2DY6boG+gcn0OXIt/w
         3El2Ol7/1vDYSYnRCPPjkx24pIRblnkYnpFd1CnCngIuA9zNlfePBRHjLRTjUB+SRScI
         c/JACH8XKvIDTwNQKyyXj/zYKXOkm41ZtFhRZ2WOLXTV9Xm5MzU+BYskHhMbUCDFyBHQ
         Z9t7GOJ/+gjRU0bLH0gDvzVYbYA3KRFYh3wtHMl+GqR7gu82RKBGJq78Vr2IYnA0GBvy
         Q4SA==
X-Google-Smtp-Source: APXvYqziJmYZ/M3DBhSvWVid6yUnjwAFR1bFewY71nsh8v7l8wl/DMvkNJXtizFc/1v5ROntPHMMIQY9hKt607YbfTk=
X-Received: by 2002:aca:e64f:: with SMTP id d76mr26337452oih.105.1555441958087;
 Tue, 16 Apr 2019 12:12:38 -0700 (PDT)
MIME-Version: 1.0
References: <20190411210834.4105-1-jglisse@redhat.com> <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
 <20190416185922.GA12818@kmo-pixel>
In-Reply-To: <20190416185922.GA12818@kmo-pixel>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 16 Apr 2019 12:12:27 -0700
Message-ID: <CAPcyv4jLrQ6evLAJzsASh=H6Tzx8E1oiF+YR3L2fOpbZYNUWGg@mail.gmail.com>
Subject: Re: [PATCH v1 00/15] Keep track of GUPed pages in fs and block
To: Kent Overstreet <kent.overstreet@gmail.com>
Cc: Boaz Harrosh <boaz@plexistor.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, 
	Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Thumshirn <jthumshirn@suse.de>, 
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>, Steve French <sfrench@samba.org>, 
	linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, 
	Yan Zheng <zyan@redhat.com>, Sage Weil <sage@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, 
	Alex Elder <elder@kernel.org>, ceph-devel@vger.kernel.org, 
	Eric Van Hensbergen <ericvh@gmail.com>, Latchesar Ionkov <lucho@ionkov.net>, Mike Marshall <hubcap@omnibond.com>, 
	Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org, 
	Dominique Martinet <asmadeus@codewreck.org>, v9fs-developer@lists.sourceforge.net, 
	Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, 
	=?UTF-8?Q?Ernesto_A=2E_Fern=C3=A1ndez?= <ernesto.mnd.fernandez@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 11:59 AM Kent Overstreet
<kent.overstreet@gmail.com> wrote:
>
> On Tue, Apr 16, 2019 at 09:35:04PM +0300, Boaz Harrosh wrote:
> > On Thu, Apr 11, 2019 at 05:08:19PM -0400, jglisse@redhat.com wrote:
> > > From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > >
> > > This patchset depends on various small fixes [1] and also on patchset
> > > which introduce put_user_page*() [2] and thus is 5.3 material as thos=
e
> > > pre-requisite will get in 5.2 at best. Nonetheless i am posting it no=
w
> > > so that it can get review and comments on how and what should be done
> > > to test things.
> > >
> > > For various reasons [2] [3] we want to track page reference through G=
UP
> > > differently than "regular" page reference. Thus we need to keep track
> > > of how we got a page within the block and fs layer. To do so this pat=
ch-
> > > set change the bio_bvec struct to store a pfn and flags instead of a
> > > direct pointer to a page. This way we can flag page that are coming f=
rom
> > > GUP.
> > >
> > > This patchset is divided as follow:
> > >     - First part of the patchset is just small cleanup i believe they
> > >       can go in as his assuming people are ok with them.
> >
> >
> > >     - Second part convert bio_vec->bv_page to bio_vec->bv_pfn this is
> > >       done in multi-step, first we replace all direct dereference of
> > >       the field by call to inline helper, then we introduce macro for
> > >       bio_bvec that are initialized on the stack. Finaly we change th=
e
> > >       bv_page field to bv_pfn.
> >
> > Why do we need a bv_pfn. Why not just use the lowest bit of the page-pt=
r
> > as a flag (pointer always aligned to 64 bytes in our case).
> >
> > So yes we need an inline helper for reference of the page but is it not=
 clearer
> > that we assume a page* and not any kind of pfn ?
> > It will not be the first place using low bits of a pointer for flags.
> >
> > That said. Why we need it at all? I mean why not have it as a bio flag.=
 If it exist
> > at all that a user has a GUP and none-GUP pages to IO at the same reque=
st he/she
> > can just submit them as two separate BIOs (chained at the block layer).
> >
> > Many users just submit one page bios and let elevator merge them any wa=
y.
>
> Let's please not add additional flags and weirdness to struct bio - "if t=
his
> flag is set interpret one way, if not interpret another" - or eventually =
bios
> will be as bad as skbuffs. I would much prefer just changing bv_page to b=
v_pfn.

This all reminds of the failed attempt to teach the block layer to
operate without pages:

https://lore.kernel.org/lkml/20150316201640.33102.33761.stgit@dwillia2-desk=
3.amr.corp.intel.com/

>
> Question though - why do we need a flag for whether a page is a GUP page =
or not?
> Couldn't the needed information just be determined by what range the pfn =
is not
> (i.e. whether or not it has a struct page associated with it)?

That amounts to a pfn_valid() check which is a bit heavier than if we
can store a flag in the bv_pfn entry directly.

I'd say create a new PFN_* flag, and make bv_pfn a 'pfn_t' rather than
an 'unsigned long'.

That said, I'm still in favor of Jan's proposal to just make the
bv_page semantics uniform. Otherwise we're complicating this core
infrastructure for some yet to be implemented GPU memory management
capabilities with yet to be determined value. Circle back when that
value is clear, but in the meantime fix the GUP bug.

