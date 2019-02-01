Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73F3CC282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 13:46:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30EF62084C
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 13:46:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="LytRdUfB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30EF62084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0D098E0003; Fri,  1 Feb 2019 08:46:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB9768E0001; Fri,  1 Feb 2019 08:46:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A84DC8E0003; Fri,  1 Feb 2019 08:46:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4ED228E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 08:46:37 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id f202so1819093wme.2
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 05:46:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=i0MCChPfL+Z9b0zZCKNJEZsG1jk8hrvKlUmFO53Cb8M=;
        b=ItBnUOkOXCGe6PhYJrnOP/BKC3m1BCDY9aoJum+mHBrOXPaan6VzfZJpdqoh8JDfKJ
         1itYKbwSwZ012oU71BE/nrzSAZ8hLQTcag8zWwaxTl05whg8WEzXSotbj/TtWPIh8Ffz
         Btr9gUOGjMTIz7x/2PCJVcnFmKk2kvno3RYUf57hpsNPTXi3swZEx53BKznVcSx417+1
         f/3lymQwJsMyZDJVAjoG3+f4Eox6T2QOgx0jY7+w9bDPVkG+jLWoO5pzznfxsU01cPnK
         ckf/q6VU0vuyqcujE8nDQ5zk9y7uR9ChSzGtEnUBwInfJp2onCmKBCYzoK2Tlf/aNhsb
         5RkA==
X-Gm-Message-State: AHQUAuZP5C/AdzcnFRMZZwfpxRTWEIrfyhCUTklzURlVZHUDUf6G9jy6
	ngg6ardL6eC6+HCVO8C3NxfZ4rBxYHmWpO6l/CWb0nBko4Awf79GJNs7R8Uk2kBmAdbTQCq4qTn
	xxT8H+XtX6Rfcm0jQpcAM0t57K8hn5uzYzXxJjx7kx0nyOocky4pStPFEusW+HfctSg==
X-Received: by 2002:a1c:8b44:: with SMTP id n65mr2618673wmd.104.1549028796867;
        Fri, 01 Feb 2019 05:46:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZBpf1BLd086ZbWFoXIyDqnPpKknOGuyPcME/0SO4om8SBE8wcbhdmHNFlQBDFJVKdb70I1
X-Received: by 2002:a1c:8b44:: with SMTP id n65mr2618605wmd.104.1549028795627;
        Fri, 01 Feb 2019 05:46:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549028795; cv=none;
        d=google.com; s=arc-20160816;
        b=i8lHqHdB/gfCG4i4zEvyG0E1/CWtAKpfYwUu8gklUDtRZnhciTzY6Zh4YPQ9Uz5ci3
         KapKz+cu0OtfHeD2vFOvfZp89DjeM6xtO7o+WgRIExtBuGbBmvolJ0QZPDnntVz1iTq0
         eOvDI06d2Ki7dVlePfPFuQN2tkyGHprjVkunswWJJZBtwPd5GdpQJEu0csbpgfoDmTMc
         tOuXs+uMHIODZOACxLDxQR8cuAYxfJij4c8+ZrOgxj+taxRkytKsGIrDOTU3KFM4v2ux
         +Fikc7UsJ9p7rG1LKXM5c2m4vbqLfIbmxkYPTTsegjpJ2YbOFQ6WiGhiKKFlAY9yNcTN
         hg7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=i0MCChPfL+Z9b0zZCKNJEZsG1jk8hrvKlUmFO53Cb8M=;
        b=perlcWvElsO8qfsenz0+ozOn+eebooqzdeUF58KTz+re2M/BHQ+jD4YmSRCX9KielR
         ovDKRhtUf+Gh3u5eaMTqYRDnIP6X1axY2x90cqcAQljsepOpChL0ROPxuiH9PKU6Frh/
         1JR117MXlVfhnFpuxI9rg0x75MzjnuXyCHY2fqDQ+b1abIO4BYoNoh9nxWVRDuMTTX58
         mN0CMM2hXo3DIeJE2jfptSe3rXUG7/WAE9n1j4SCBGCdJKw/D6nRPYRA3K0o/R0E51l/
         k+FD7NvJd4A7aTHNy1wp6h+h3upekFZr1hyPnUZmnj6FvLyvLaVbvH+IWHtAP5mQAhBn
         XBcw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=LytRdUfB;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id r5si5262226wrs.80.2019.02.01.05.46.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 05:46:35 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) client-ip=2a01:4f8:190:11c2::b:1457;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=LytRdUfB;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCC5000206D6264C5583287.dip0.t-ipconnect.de [IPv6:2003:ec:2bcc:5000:206d:6264:c558:3287])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id C3E231EC0586;
	Fri,  1 Feb 2019 14:46:34 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1549028794;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=i0MCChPfL+Z9b0zZCKNJEZsG1jk8hrvKlUmFO53Cb8M=;
	b=LytRdUfBTMfv6GTei5uI11GFJURWbTSFGYDChUBIKWsNnF+7qjJ9XflyACn03NR3jIDlM/
	KhcE+cLJxvSFQjMjbGbkg1GZXFpRFzuOuvHmJez6M27m7t/FcDVtzxdWPY5tjWBVdVYWnU
	Nl/LWyqcYN25Va32y3xeWbb9TfGsMu4=
Date: Fri, 1 Feb 2019 14:46:21 +0100
From: Borislav Petkov <bp@alien8.de>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	Marc Zyngier <marc.zyngier@arm.com>,
	Christoffer Dall <christoffer.dall@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>,
	Tony Luck <tony.luck@intel.com>,
	Dongjiu Geng <gengdongjiu@huawei.com>,
	Xie XiuQi <xiexiuqi@huawei.com>
Subject: Re: [PATCH v8 09/26] ACPI / APEI: Generalise the estatus queue's
 notify code
Message-ID: <20190201134602.GI31854@zn.tnic>
References: <20190129184902.102850-1-james.morse@arm.com>
 <20190129184902.102850-10-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190129184902.102850-10-james.morse@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 06:48:45PM +0000, James Morse wrote:
> +static int ghes_in_nmi_spool_from_list(struct list_head *rcu_list)
> +{
> +	int err, ret = -ENOENT;
> +	struct ghes *ghes;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(ghes, rcu_list, list) {
> +		err = ghes_in_nmi_queue_one_entry(ghes);
> +		if (!err)
> +			ret = 0;

Do I understand this correctly that we want to do "ret = 0" for at least
one record which ghes_in_nmi_queue_one_entry() has succeeded queueing?

For those for which it has returned -ENOENT, estatus has been cleared,
nothing has been queued so we don't have to do anything for that
particular entry...

Btw, you don't really need the err variable:

		if (!ghes_in_nmi_queue_one_entry(ghes))
			ret = 0;

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

