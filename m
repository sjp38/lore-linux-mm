Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 910FDC3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:52:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B3862064A
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:52:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B3862064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF2256B0003; Fri, 16 Aug 2019 08:52:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC91C6B0005; Fri, 16 Aug 2019 08:52:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C04BB6B0007; Fri, 16 Aug 2019 08:52:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0168.hostedemail.com [216.40.44.168])
	by kanga.kvack.org (Postfix) with ESMTP id A00C16B0003
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:52:11 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 508E012798
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:52:11 +0000 (UTC)
X-FDA: 75828278862.14.fish30_87787bb51521d
X-HE-Tag: fish30_87787bb51521d
X-Filterd-Recvd-Size: 2297
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:52:10 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7D724B011;
	Fri, 16 Aug 2019 12:52:09 +0000 (UTC)
Date: Fri, 16 Aug 2019 14:52:07 +0200
From: Joerg Roedel <jroedel@suse.de>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Petr Vandrovec <petr@vandrovec.name>,
	Matthew Wilcox <willy@infradead.org>, Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	Christian Koenig <christian.koenig@amd.com>,
	Huang Rui <ray.huang@amd.com>, David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org
Subject: Re: [Bug 204407] New: Bad page state in process Xorg
Message-ID: <20190816125207.GA23865@suse.de>
References: <bug-204407-27@https.bugzilla.kernel.org/>
 <20190802132306.e945f4420bc2dcddd8d34f75@linux-foundation.org>
 <20190802203344.GD5597@bombadil.infradead.org>
 <1564780650.11067.50.camel@lca.pw>
 <20190802225939.GE5597@bombadil.infradead.org>
 <CA+i2_Dc-VrOUk8EVThwAE5HZ1-zFqONuW8Gojv+16UPsAqoM1Q@mail.gmail.com>
 <45258da8-2ce7-68c2-1ba0-84f6c0e634b1@suse.cz>
 <0287aace-fec1-d2d1-370f-657e80477717@vandrovec.name>
 <6a45a9b1-81ad-72c4-8f06-5d2cd87278ef@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <6a45a9b1-81ad-72c4-8f06-5d2cd87278ef@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 02:47:53PM +0200, Vlastimil Babka wrote:
> On 8/15/19 9:13 PM, Petr Vandrovec wrote:
> > [=A0=A0 18.110985] DMAR: [DMA Write] Request device [07:00.1] fault a=
ddr=20
> > fffe0000=A0[fault=A0reason=A002]=A0Present=A0bit=A0in=A0context=A0ent=
ry=A0is=A0clear
>=20
> Worth reporting as well, not nice regression.

Is that a regression between 5.3-rc3 and 5.3-rc4 or is it already broken
since -rc1? The 5.3-rc5 kernel will contains some VT-d fixes that are
worth a try here too. If you can test latest linus/master branch that
would be great, otherwise -rc5 is fine too.


Regards,

	Joerg

