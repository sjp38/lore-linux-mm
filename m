Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEF25C3A5A2
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 14:06:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CC3521848
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 14:06:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="pLeDF2JR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CC3521848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BCB06B049C; Fri, 23 Aug 2019 10:06:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06D9A6B049D; Fri, 23 Aug 2019 10:06:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E77AE6B049E; Fri, 23 Aug 2019 10:06:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0180.hostedemail.com [216.40.44.180])
	by kanga.kvack.org (Postfix) with ESMTP id C73DE6B049C
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 10:06:42 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 73E8F52C7
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 14:06:42 +0000 (UTC)
X-FDA: 75853868244.07.pull23_1d6b3d095b11e
X-HE-Tag: pull23_1d6b3d095b11e
X-Filterd-Recvd-Size: 3740
Received: from merlin.infradead.org (merlin.infradead.org [205.233.59.134])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 14:06:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=YKuQj4mAn7Ly5b7a4x9QRIt1a/TDbvR4K88H+PiPWaY=; b=pLeDF2JRWvn5cV6HVnEDw3VLF
	m6eg1WFTuIkTWXy/lA95iK0Ff+Ac3qqG7mLkMqzJnT5sh0kFAMPkyhTnHF0ObSzu5cOOSYXkv4tyS
	okxtf6Uc8yCdeZ7c236qvdKh/NoFGDK7/Ti7lMgUFd/or3ObdSQstPTL+isWWUyFCgJzKIwdrWHHk
	uLGRqW0XJlsVnbiO99fDPHpYfC+GXdqwSgf/L2sUCn3oi6eZ3yKbdS/Tkg4RD1eqsMG/kHAbOtFYt
	0i3/a/MJg+FHF9xSxttoVoi9RtyiTlKVAaynNJpYkhjPA4JQF/8KRtSwV6XEQw2gbS58lOIvz97TV
	NeA22XXQQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=noisy.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i1ACp-00023P-9v; Fri, 23 Aug 2019 14:06:19 +0000
Received: from hirez.programming.kicks-ass.net (hirez.programming.kicks-ass.net [192.168.1.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by noisy.programming.kicks-ass.net (Postfix) with ESMTPS id 6A117307510;
	Fri, 23 Aug 2019 16:05:43 +0200 (CEST)
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 99EF9202245FF; Fri, 23 Aug 2019 16:06:15 +0200 (CEST)
Date: Fri, 23 Aug 2019 16:06:15 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Jason Gunthorpe <jgg@ziepe.ca>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 3/4] kernel.h: Add non_block_start/end()
Message-ID: <20190823140615.GJ2369@hirez.programming.kicks-ass.net>
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
 <20190820081902.24815-4-daniel.vetter@ffwll.ch>
 <20190820202440.GH11147@phenom.ffwll.local>
 <20190822161428.c9e4479207386d34745ea111@linux-foundation.org>
 <CAKMK7uGw_7uD=wH3bcR9xXSxAcAuYTLOZt3ue4TEvst1D0KzLQ@mail.gmail.com>
 <20190823121234.GB12968@ziepe.ca>
 <CAKMK7uHzSkd2j4MvSMoHhCaSE0BT0zMo9osF4FUBYwNZrVfYDA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKMK7uHzSkd2j4MvSMoHhCaSE0BT0zMo9osF4FUBYwNZrVfYDA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 23, 2019 at 03:42:47PM +0200, Daniel Vetter wrote:
> I'm assuming the lockdep one will land, so not going to resend that.

I was assuming you'd wake the might_lock_nested() along with the i915
user through the i915/drm tree. If want me to take some or all of that,
lemme know.

