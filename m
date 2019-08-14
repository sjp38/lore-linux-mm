Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 729EDC32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 22:19:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 308B3216F4
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 22:19:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="S/1z63Ov"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 308B3216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D27D36B0003; Wed, 14 Aug 2019 18:19:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD9F16B0005; Wed, 14 Aug 2019 18:19:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C162F6B0007; Wed, 14 Aug 2019 18:19:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0152.hostedemail.com [216.40.44.152])
	by kanga.kvack.org (Postfix) with ESMTP id A4CB06B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 18:19:21 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 22EBA180AD7C1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 22:19:21 +0000 (UTC)
X-FDA: 75822450522.23.jar85_1716fd261d224
X-HE-Tag: jar85_1716fd261d224
X-Filterd-Recvd-Size: 5185
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 22:19:18 +0000 (UTC)
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4107D20665;
	Wed, 14 Aug 2019 22:18:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565821086;
	bh=k8sF9ByxTFJt+xPpPS1ClUhI3arOUct3oMxaqPHO3MI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=S/1z63Ov8CQ7Ns/DVtHuelIHzOPS4/tww77AgTZI+v2U7sLvnbEEPlv9WPhG4y32H
	 Ky5oGomVEEFvzPSSqxC0WdbhxRINJl5SXaHNr/fe/MyCpOGumxN+7Nu+yIVU/PM4I1
	 D0rTreqznnzPWBSf5XSM5YiCaXthUF0BkjISpeJc=
Date: Wed, 14 Aug 2019 15:18:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Cc: bjorn.topel@intel.com, linux-mm@kvack.org, xdp-newbies@vger.kernel.org,
 netdev@vger.kernel.org, bpf@vger.kernel.org, linux-kernel@vger.kernel.org,
 ast@kernel.org, magnus.karlsson@intel.com
Subject: Re: [PATCH v2 bpf-next] mm: mmap: increase sockets maximum memory
 size pgoff for 32bits
Message-Id: <20190814151805.bbff7b08f3a4119750b3e9fd@linux-foundation.org>
In-Reply-To: <20190814150934.GD4142@khorivan>
References: <20190812113429.2488-1-ivan.khoronzhuk@linaro.org>
	<20190812124326.32146-1-ivan.khoronzhuk@linaro.org>
	<20190812141924.32136e040904d0c5a819dcb1@linux-foundation.org>
	<20190814150934.GD4142@khorivan>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Aug 2019 18:09:36 +0300 Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org> wrote:

> On Mon, Aug 12, 2019 at 02:19:24PM -0700, Andrew Morton wrote:
> 
> Hi, Andrew
> 
> >On Mon, 12 Aug 2019 15:43:26 +0300 Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org> wrote:
> >
> >> The AF_XDP sockets umem mapping interface uses XDP_UMEM_PGOFF_FILL_RING
> >> and XDP_UMEM_PGOFF_COMPLETION_RING offsets. The offsets seems like are
> >> established already and are part of configuration interface.
> >>
> >> But for 32-bit systems, while AF_XDP socket configuration, the values
> >> are to large to pass maximum allowed file size verification.
> >> The offsets can be tuned ofc, but instead of changing existent
> >> interface - extend max allowed file size for sockets.
> >
> >
> >What are the implications of this?  That all code in the kernel which
> >handles mapped sockets needs to be audited (and tested) for correctly
> >handling mappings larger than 4G on 32-bit machines?  Has that been
> 
> That's to allow only offset to be passed, mapping length is less than 4Gb.
> I have verified all list of mmap for sockets and all of them contain dummy
> cb sock_no_mmap() except the following:
> 
> xsk_mmap()
> tcp_mmap()
> packet_mmap()
> 
> xsk_mmap() - it's what this fix is needed for.
> tcp_mmap() - doesn't have obvious issues with pgoff - no any references on it.
> packet_mmap() - return -EINVAL if it's even set.

Great, thanks.

> 
> >done?  Are we confident that we aren't introducing user-visible buggy
> >behaviour into unsuspecting legacy code?
> >
> >Also...  what are the user-visible runtime effects of this change?
> >Please send along a paragraph which explains this, for the changelog.
> >Does this patch fix some user-visible problem?  If so, should be code
> >be backported into -stable kernels?
> It should go to linux-next, no one has been using it till this patch
> with 32 bits as w/o this fix af_xdp sockets can't be used at all.
> It unblocks af_xdp socket usage for 32bit systems.
> 
> 
> That's example of potential next commit message:
> Subject: mm: mmap: increase sockets maximum memory size pgoff for 32bits
> 
> The AF_XDP sockets umem mapping interface uses XDP_UMEM_PGOFF_FILL_RING
> and XDP_UMEM_PGOFF_COMPLETION_RING offsets.  These offsets are established
> already and are part of the configuration interface.
> 
> But for 32-bit systems, using AF_XDP socket configuration, these values
> are too large to pass the maximum allowed file size verification.  The
> offsets can be tuned off, but instead of changing the existing interface,
> let's extend the max allowed file size for sockets.
> 
> No one has been using it till this patch with 32 bits as w/o this fix
> af_xdp sockets can't be used at all, so it unblocks af_xdp socket usage
> for 32bit systems.
> 
> All list of mmap cbs for sockets were verified on side effects and
> all of them contain dummy cb - sock_no_mmap() at this moment, except the
> following:
> 
> xsk_mmap() - it's what this fix is needed for.
> tcp_mmap() - doesn't have obvious issues with pgoff - no any references on it.
> packet_mmap() - return -EINVAL if it's even set.
>
> ...
>
> Is it ok to be replicated in PATCH v2 or this explanation is enough here
> to use v1?

I have replaced the changlog in my tree with the above, thanks.


