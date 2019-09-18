Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF618C4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 14:20:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 924642196E
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 14:20:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="j0d7BbTA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 924642196E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17D336B02C1; Wed, 18 Sep 2019 10:20:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12D456B02C2; Wed, 18 Sep 2019 10:20:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 043106B02C3; Wed, 18 Sep 2019 10:20:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0220.hostedemail.com [216.40.44.220])
	by kanga.kvack.org (Postfix) with ESMTP id D7A296B02C1
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 10:20:23 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 72660181AC9B4
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 14:20:23 +0000 (UTC)
X-FDA: 75948251526.01.wood66_3d8ea164d8040
X-HE-Tag: wood66_3d8ea164d8040
X-Filterd-Recvd-Size: 2946
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 14:20:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=DMq3xUbm3Tba1ioJ8DBESEZ5dfTNXfLnh6d+gS2fyMo=; b=j0d7BbTAvNp9ZBwF3w1M7xXOR
	zlRtmrVxGkJ0yMLkv+nxpymU1ev0nBhurZbTO0LEhYTMLQ2/lK3LvD69O+kB3yJGlHuV+VD/XnNSn
	eINo+UfM3D0lNxRNCEappYbYW/AmV03vZskWHxHEbfQpIIVBDwYtmfMcOO9EW5UV/wCo/MQV32YHe
	osVm3YYuYpMCSm8yOpRFUqdAl78gxnnUkfx+9rk0D5155UEAoiwJ9hma3GR33sH7EsdwxM1xB6rbs
	DN5MiK9y7+uzFA9FAL5FyK32bdHPvtFBt22hUfyPe3jIGc9/PDnxjW3abmEhptFO+/Rjq9pL2fwk2
	a3I2ZKVlQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92.2 #3 (Red Hat Linux))
	id 1iAaob-0006gt-J4; Wed, 18 Sep 2019 14:20:17 +0000
Date: Wed, 18 Sep 2019 07:20:17 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Jia He <justin.he@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
	James Morse <james.morse@arm.com>, Marc Zyngier <maz@kernel.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Suzuki Poulose <Suzuki.Poulose@arm.com>,
	Punit Agrawal <punitagrawal@gmail.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Jun Yao <yaojun8558363@gmail.com>,
	Alex Van Brunt <avanbrunt@nvidia.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>, hejianet@gmail.com,
	Kaly Xin <Kaly.Xin@arm.com>
Subject: Re: [PATCH v4 1/3] arm64: cpufeature: introduce helper
 cpu_has_hw_af()
Message-ID: <20190918142017.GC9880@bombadil.infradead.org>
References: <20190918131914.38081-1-justin.he@arm.com>
 <20190918131914.38081-2-justin.he@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190918131914.38081-2-justin.he@arm.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 18, 2019 at 09:19:12PM +0800, Jia He wrote:
> +/* Decouple AF from AFDBM. */
> +bool cpu_has_hw_af(void)
> +{
> +	return (read_cpuid(ID_AA64MMFR1_EL1) & 0xf);
> +}
> +

Do you really want to call read_cpuid() every time?  I would have thought
you'd want to use the static branch mechanism to do the right thing at
boot time.  See Documentation/static-keys.txt.

