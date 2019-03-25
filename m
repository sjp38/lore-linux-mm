Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51416C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 21:19:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 111B220848
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 21:19:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="U7HL23u9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 111B220848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 854BE6B0003; Mon, 25 Mar 2019 17:19:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82B516B0006; Mon, 25 Mar 2019 17:19:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 740636B0007; Mon, 25 Mar 2019 17:19:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3369F6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 17:19:10 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id t1so693945plo.20
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 14:19:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Y6REvdwADrTnSp3Nk0MLy07mXpgoxmYoS4K9h0P+n9M=;
        b=R3NqVfWWHaW5YyczTSLkV5Xq5CFmFtWETHNayeJcSrCU5T/ShwjJHcdj5HqQvgouRd
         dqGXFwCLV8R65zh0zeq4rbuGZAOLhto9rfXAQVJMPQrA+Hw7TJwAkWuW5sfIcyT4Z3l1
         kt6CXm/RKjfDXSX+3rl58IbrIFeGa79PdK+JSqIFY9SQx0kum7jbJM+mcHdVON/I4cUB
         CdYt02nctTHncvX8XHLyVkt132IZlwdmjfwln4p7thNUTqpAHFp/SJ6AXzdqg9TcNmdi
         vsrdAhsYWApfuVLUF70gW+21qsR5f+6JH8sjiHVKEBBGoghexSAQSFYv/MJOT1UFx9fb
         OlMg==
X-Gm-Message-State: APjAAAV6kZDp2vTB7ZAdmJ4EN6tgjAeLzTqB036mrlzCq//vmCANzGkH
	iX/U+tvOON48rujpV2kUdveoo7CgOjqYdD1kifLOFUEQlY+cjCv0FGo1Cj/FxQ1S5PiTmmy0cOo
	i9CMM301SLHO8KDt/P6asWV9xk4KyzEDt7qBa5D7M/xNoELKl968yZgMIkCuS8Tb5mA==
X-Received: by 2002:a65:518b:: with SMTP id h11mr25544624pgq.41.1553548749811;
        Mon, 25 Mar 2019 14:19:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtTQFaOGMU++h7L++9T/+KnXx+5UMT5wdA3zhQH434BiF7FuZXybLcXMrjrZquEHTN3kiw
X-Received: by 2002:a65:518b:: with SMTP id h11mr25544566pgq.41.1553548749016;
        Mon, 25 Mar 2019 14:19:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553548749; cv=none;
        d=google.com; s=arc-20160816;
        b=0R2CGvU/U9pG1OhsX/my32eKAQ5lRHJZc+kDzB72qJeFBvLEoHMCGuUCC9G9Sz9RzX
         idLlYjIw6I6PB9B2/zJI1SEK1rNdffHOo8JOEZE6ojKDCpxzhterkfAjnMv/kxldd2hY
         X0mQkcwpUIE5Uve9RNc9+QKzQrm8HN1cNV3WYwJK9pncml7xmzjOO0m5E7qHwolTBLlu
         wLPF3fGWi+sz6zrHti1WU1YZ6mNQM/2E3l/KwRwjlPr1aiMOLKY8AhKPtKZCGgTXT031
         kLv0SfMfkumJcOrnOBfFPpcZ5vsA6r8cQ9OMCN/x0pnJM5NRYFZee/p2Ym0mz0A/ZVVE
         KjPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Y6REvdwADrTnSp3Nk0MLy07mXpgoxmYoS4K9h0P+n9M=;
        b=VxsuyWpkUitEdD1GkAIcE7SHc56zjw4IhkG5sVnPAvF8EeVHyQi2s3pvKDTbK1QNRD
         Y9hk+HK9rBU59HK8xRWK5Wx5saX53TlJo11ct039diWLHAu4+SiqUOxcaRPzbcRYQaqZ
         FCy+eaE3fWjBNKve8wWk2uFynamPL0MY6EpX5eFXuOqEZIUCuMCMa1eOb5/vvk9X9qIS
         smIRrnU9WswWUYjuISo0PWTL8p0k9uTug7/D/Tpc+Cl0vR0zhLLtNoNqkvFlKpvrnAXt
         7LNTfmBhf5J4O704krNXvOC64pxkuGNOrKKpFz0AsqlC/9z4/B/M2E+T+1cGAc+ur8rX
         hGWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=U7HL23u9;
       spf=pass (google.com: domain of helgaas@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=helgaas@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 59si15597548plp.100.2019.03.25.14.19.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 14:19:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of helgaas@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=U7HL23u9;
       spf=pass (google.com: domain of helgaas@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=helgaas@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [69.71.4.100])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 45A8B2082F;
	Mon, 25 Mar 2019 21:19:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553548748;
	bh=6xFEjARh8mWEVuC4JxlsVeHPi9aB0xZUvNWpmt4JaE4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=U7HL23u9CbZZaNtYog7ZKs9rsXRYRPGQ9horOTfdo0J1+Qm5fCV9ZxpqzbEanSCUs
	 A2n/jnd4afVjLPlgVNSV2SvdBwmnXUDAu8y1fdKl+dXtHStid/kQ/Gydel7i3ZZVKy
	 5UySrtfRmJ7930+cnSKVM3QTG5mPAT59xoBoL8PQ=
Date: Mon, 25 Mar 2019 16:19:06 -0500
From: Bjorn Helgaas <helgaas@kernel.org>
To: Sakari Ailus <sakari.ailus@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	linux-arm-kernel@lists.infradead.org, sparclinux@vger.kernel.org,
	linux-um@lists.infradead.org, xen-devel@lists.xenproject.org,
	linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org,
	drbd-dev@lists.linbit.com, linux-block@vger.kernel.org,
	linux-mmc@vger.kernel.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-btrfs@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-mm@kvack.org, ceph-devel@vger.kernel.org,
	netdev@vger.kernel.org
Subject: Re: [PATCH v2 1/1] treewide: Switch printk users from %pf and %pF to
 %ps and %pS, respectively
Message-ID: <20190325211906.GA24180@google.com>
References: <20190325193229.23390-1-sakari.ailus@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190325193229.23390-1-sakari.ailus@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 09:32:28PM +0200, Sakari Ailus wrote:
> %pF and %pf are functionally equivalent to %pS and %ps conversion
> specifiers. The former are deprecated, therefore switch the current users
> to use the preferred variant.
> 
> The changes have been produced by the following command:
> 
> 	git grep -l '%p[fF]' | grep -v '^\(tools\|Documentation\)/' | \
> 	while read i; do perl -i -pe 's/%pf/%ps/g; s/%pF/%pS/g;' $i; done
> 
> And verifying the result.
> 
> Signed-off-by: Sakari Ailus <sakari.ailus@linux.intel.com>
> Acked-by: David Sterba <dsterba@suse.com> (for btrfs)
> Acked-by: Mike Rapoport <rppt@linux.ibm.com> (for mm/memblock.c)
> Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

Acked-by: Bjorn Helgaas <bhelgaas@google.com> (for drivers/pci)

Thanks a lot for cleaning this up.  This has been annoying for a long time.

