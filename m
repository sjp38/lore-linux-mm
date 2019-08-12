Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D4E7C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:41:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54D8A206C1
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:41:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54D8A206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 056FD6B0003; Mon, 12 Aug 2019 17:41:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 007906B0005; Mon, 12 Aug 2019 17:41:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5F8D6B0006; Mon, 12 Aug 2019 17:41:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0213.hostedemail.com [216.40.44.213])
	by kanga.kvack.org (Postfix) with ESMTP id C40D86B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 17:41:16 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 79E4752C1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:41:16 +0000 (UTC)
X-FDA: 75815096952.27.kitty43_afe42e84fa1f
X-HE-Tag: kitty43_afe42e84fa1f
X-Filterd-Recvd-Size: 2876
Received: from mga18.intel.com (mga18.intel.com [134.134.136.126])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:41:15 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Aug 2019 14:40:49 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,379,1559545200"; 
   d="scan'208";a="200279228"
Received: from sjchrist-coffee.jf.intel.com (HELO linux.intel.com) ([10.54.74.41])
  by fmsmga004.fm.intel.com with ESMTP; 12 Aug 2019 14:40:48 -0700
Date: Mon, 12 Aug 2019 14:40:41 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
To: Adalbert =?utf-8?B?TGF6xINy?= <alazar@bitdefender.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org,
	virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?Q?Laur=E9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>, Zhang@vger.kernel.org,
	Yu C <yu.c.zhang@intel.com>,
	Mihai =?utf-8?B?RG9uyJt1?= <mdontu@bitdefender.com>
Subject: Re: [RFC PATCH v6 00/92] VM introspection
Message-ID: <20190812214041.GA4996@linux.intel.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190809160047.8319-1-alazar@bitdefender.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000220, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 06:59:15PM +0300, Adalbert Laz=C4=83r wrote:
>  55 files changed, 13485 insertions(+), 225 deletions(-)

The size of this series is overwhelming, to say the least.  The remote
pages concept and SPP patches on their own would be hefty series to revie=
w.

It would be very helpful to reviewers to reorder the patches and only sen=
d
the bits that are absolutely mandatory for initial support.  For example,
AFAICT the SPP support and remote pages concept are largely performance
related and not functionally required.

Note, this wouldn't prevent you from carrying the series in its entirety
in your own branches.

Possible reordering:

  - Bug fixes (if any patches qualify as such)
  - Emulator changes
  - KVM preparatory patches
  - Basic instrospection functionality

------>8-------- cut the series here

  - Optional introspection functionality (if there is any)
  - SPP and introspection integration
  - Remote pages and introspection integration

