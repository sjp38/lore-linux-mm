Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CBD4C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 18:58:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A8EA218FD
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 18:58:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Uq2En9aN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A8EA218FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1B856B0006; Thu, 21 Mar 2019 14:58:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC87D6B0007; Thu, 21 Mar 2019 14:58:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDED56B0008; Thu, 21 Mar 2019 14:58:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C4AA86B0006
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 14:58:16 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id b188so24959991qkg.15
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 11:58:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=CG4CAud2+aTXCfCWTJhAZytJ3xP0aOfC34x5T8Od304=;
        b=HLd5XgGJrnYWkDA1GJIJCsZOeO3k35uemd2hHazsvwv38H06ewz8NFXi1UznqdkYtz
         chgovQXwX55TC4fUygaw2CPehj4v+5d+XXkIY7wnK3GF73240Buw515t4Z4UvQizNgD0
         uXWzzddDC0Ve9WpXKm3XlX5nDpTQ3lJrV6Fn8E1zD+ZVugyVl8e8xCcxg5uWFRzqTWA4
         1PejaRj3YRFABImA9lR7Qqau52/BYaATCr3eIreKdmRthrinRrBDQo9WTKDONveCUvkY
         OfV45Fz+s8gItPvs3WJSYrjPmS6vs47Y5qzUvXwnjc0LLd6p4sjdv37vTdOCnEby/O8s
         h8hA==
X-Gm-Message-State: APjAAAUaeZyehuWwxbrC39MOX69fIEcrxcgoaTZgwBlOSMdNKWxDLpeg
	5wmPjMg/VRSFTczhpbLGFxs3wG/QTppvlZVUQKd1xh8AOzMmf3gv7P0ICnKrSJM3E2WBgEz+oKy
	kXdeerXcmCD0wCO3N6MI85PBf7cSw8O0uxLNm8M3xh99wTZNHzOmVQH9IrUbuFhppkQ==
X-Received: by 2002:a37:8505:: with SMTP id h5mr4248504qkd.66.1553194696518;
        Thu, 21 Mar 2019 11:58:16 -0700 (PDT)
X-Received: by 2002:a37:8505:: with SMTP id h5mr4248467qkd.66.1553194695772;
        Thu, 21 Mar 2019 11:58:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553194695; cv=none;
        d=google.com; s=arc-20160816;
        b=tyqPxdKaN6l8yYQYx04F4MzdFlVzSPg4qMdE8HnqKGPWSJf9DKkegMZUMSK+7vKx3C
         zJCMKyKbDzhr5T0L7af3dX4Ge/WT4Kgc28QHb5JZg9JtXptNrqKjmiJFvTAJeSEQIZUX
         AtWod5FEH969pj2b4O/tLGUY2oNy+0OrpGr5GufcAErSpawl1wFDqW6n2+lVmbgnXMM2
         Zt13uMcJlehmgbKvsMHg0O56Ry66BT9GFcuuJ1ls7QjX23Z/xvl0q/Ybx0qXCrjzfFyf
         3agza8kCQImTU5YcrCEMHOUXkXKbFug+a5TykVYtktFU82JeN7G8RMybi2BoE2RMRuQb
         zPNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=CG4CAud2+aTXCfCWTJhAZytJ3xP0aOfC34x5T8Od304=;
        b=opkzNvNtZnPqK+f8BbyKqEwJK2BoBZCTLw58Z7d75sb94YxtTqBDd3Iudl+uVQChYK
         XZj/l+1T2qTttM4gBOaEMfDHjyduy+CQ9fP8zWLFqc1XIp9Z8Ks+LzR7TePzsdG0M4bB
         UkdY4CNCFu1v4RzuisjbeBGyyguQ0/XrFksxobsP9MyXcywn+c0MGgK4rsGm6W+c8DMZ
         3uBMd0BYGpI9ruKI7FkpNIkGNKoHaKIqiSZEixsKugQCi/Px4F/nMYaOg6ykFOpWIue9
         wJTdudHyqASxU6J3MSyQ87GnkC+AROXLnXQikz0fsPUOl5U9U1A/PLWeesEsxBaLHkF6
         ugQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Uq2En9aN;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v41sor6865980qvf.29.2019.03.21.11.58.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Mar 2019 11:58:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Uq2En9aN;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=CG4CAud2+aTXCfCWTJhAZytJ3xP0aOfC34x5T8Od304=;
        b=Uq2En9aNlKpOt5B6e9Ap87o1WMK/OCiAYbI2+xbqLPrDVLh+JhkJlg3zM5WdJeFOEi
         ABZy80ig59bE2VYfDw76UUN0NO6Y26q3dJwFTFAy70oLaYHFIQC+o6RKhWHxQ5b13mcS
         Sm2jIkL6BqPjHQJHaQeQeAT25qxXs/UesBfXq29nhY+HM4a6cyU4Mb3ATFZC0gZ35Fbp
         wFGI76RYY08AGuFgmiBWNDRZbcn4hGW5KfoFr05YtY0B/DiQhyU5Aj6HhVBubM567bIO
         +9MDU5OBiECu5cKzfS1Vz+AfQIGHSFyvT4WZeChlpdXAFiq9tzbnCUmv6M64xeytLIpG
         GHOw==
X-Google-Smtp-Source: APXvYqyjKgDQyyn3igIG/sOWBHH4PO2Wo1DUeqegL6zLBYMRMHB34H42LG5ITZQm0caACfNBtbZhvw==
X-Received: by 2002:ad4:430c:: with SMTP id c12mr4508757qvs.109.1553194695549;
        Thu, 21 Mar 2019 11:58:15 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id c41sm4220482qtc.75.2019.03.21.11.58.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 11:58:15 -0700 (PDT)
Message-ID: <1553194694.26196.18.camel@lca.pw>
Subject: Re: Fw: [Bug 202919] New: Bad page map in process syz-executor.5 
 pte:9100000081 pmd:47c67067
From: Qian Cai <cai@lca.pw>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>
Date: Thu, 21 Mar 2019 14:58:14 -0400
In-Reply-To: <20190320170151.2ed757a48e892ebc05922389@linux-foundation.org>
References: <20190320170151.2ed757a48e892ebc05922389@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000073, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-03-20 at 17:01 -0700, Andrew Morton wrote:
> kcov_mmap()/kcov_fault_in_area() appear to have produced a pte which
> confused _vm_normal_page().  Could someone please take a look?

Tough without a reproducer.

