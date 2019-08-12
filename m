Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDFCEC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 08:24:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B96802087B
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 08:24:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B96802087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F4816B0005; Mon, 12 Aug 2019 04:24:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A4ED6B0006; Mon, 12 Aug 2019 04:24:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E2996B0008; Mon, 12 Aug 2019 04:24:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0136.hostedemail.com [216.40.44.136])
	by kanga.kvack.org (Postfix) with ESMTP id 3AB276B0005
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 04:24:59 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D8EEC8248AA3
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 08:24:58 +0000 (UTC)
X-FDA: 75813090276.03.help49_2b4818a8bf755
X-HE-Tag: help49_2b4818a8bf755
X-Filterd-Recvd-Size: 2772
Received: from mailgw01.mediatek.com (unknown [210.61.82.183])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 08:24:57 +0000 (UTC)
X-UUID: e2401d4e653c481e87b5cab55e7c4c14-20190812
X-UUID: e2401d4e653c481e87b5cab55e7c4c14-20190812
Received: from mtkcas08.mediatek.inc [(172.21.101.126)] by mailgw01.mediatek.com
	(envelope-from <miles.chen@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0707 with TLS)
	with ESMTP id 2145448533; Mon, 12 Aug 2019 16:24:48 +0800
Received: from mtkcas07.mediatek.inc (172.21.101.84) by
 mtkmbs07n2.mediatek.inc (172.21.101.141) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Mon, 12 Aug 2019 16:24:48 +0800
Received: from [172.21.77.33] (172.21.77.33) by mtkcas07.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Mon, 12 Aug 2019 16:24:48 +0800
Message-ID: <1565598290.5872.6.camel@mtkswgap22>
Subject: Re: [RFC PATCH v2] mm: slub: print kernel addresses in slub debug
 messages
From: Miles Chen <miles.chen@mediatek.com>
To: Matthew Wilcox <willy@infradead.org>
CC: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David
 Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew
 Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, <linux-mediatek@lists.infradead.org>,
	<wsd_upstream@mediatek.com>, "Tobin C . Harding" <me@tobin.cc>, Kees Cook
	<keescook@chromium.org>
Date: Mon, 12 Aug 2019 16:24:50 +0800
In-Reply-To: <20190809142617.GO5482@bombadil.infradead.org>
References: <20190809010837.24166-1-miles.chen@mediatek.com>
	 <20190809024644.GL5482@bombadil.infradead.org>
	 <1565359918.12824.20.camel@mtkswgap22>
	 <20190809142617.GO5482@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-08-09 at 07:26 -0700, Matthew Wilcox wrote:
> On Fri, Aug 09, 2019 at 10:11:58PM +0800, Miles Chen wrote:
> > On Thu, 2019-08-08 at 19:46 -0700, Matthew Wilcox wrote:
> > > On Fri, Aug 09, 2019 at 09:08:37AM +0800, miles.chen@mediatek.com wrote:
> > > > INFO: Slab 0x(____ptrval____) objects=25 used=10 fp=0x(____ptrval____)
> > > 
> > > ... you don't have any randomness on your platform?
> > 
> > We have randomized base on our platforms.
> 
> Look at initialize_ptr_random().  If you have randomness, then you
> get a siphash_1u32() of the address.  With no randomness, you get this
> ___ptrval___ string instead.
> 
You are right. There is no randomness in this platform. (I ran my test
code on Qemu with no randomness)


thanks again


