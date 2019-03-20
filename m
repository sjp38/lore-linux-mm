Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E876CC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 15:27:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B022A2183E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 15:27:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B022A2183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AC256B027D; Wed, 20 Mar 2019 11:27:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45BB86B027E; Wed, 20 Mar 2019 11:27:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34D006B027F; Wed, 20 Mar 2019 11:27:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id ECA636B027D
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:27:23 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n12so1072347edo.5
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 08:27:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=MYvS8pRbla5316/OiMfUzQdkBVY1RnrbS+JhvCqqByo=;
        b=PfpyUdgRAX+c+EFReFLZTKFQ3E4mkrrEG5Ey0U9bnNjHpSiLyISyz3XXvGrHC/5n4P
         eceyacSBcvsjHHREAjfYOOqEux/+rQ+UIfyOg0IJJ3snM8lbl5lMGh5qScU0qhaV44DA
         FcycFiztqVKGEsTwSyHInCRlwrqc9XKrfW27I7xmLTqKwucBA9AFTfVAp4do3XdGHB/O
         0E0b3VOEp/XfyrtgmTk55+ZItJMUyLuyz/HAxVDy0UhAa6WRl7Z8vGmzTBO23DZ95SQa
         m2dwzOTDzJwUSEH0LUNWXv7YeQKc/AT3KQm0RrC6EJjXrRitp8NuVj/Axi6Q1GsvkcDD
         rtTg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWlHaWAP1QbleXbvQPzW5MACiS7cjdcYdI9NsMquXWoPjEVB55z
	TAXOZPSSX89aPJvD9JOJj3gN/J7KKLK0yLtm3PX9BedQXoSS/O4rbvADAcZeQ6i6xTOFWA5yIO5
	JuR6QONt4LAEqX4uxL7dwBAVwngqRpVCcF8MAiN5OksHwgq/xVceaRaKpDe6Mtpv8fQ==
X-Received: by 2002:aa7:dd0e:: with SMTP id i14mr4698532edv.172.1553095643386;
        Wed, 20 Mar 2019 08:27:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMMU+MbEVKLQhtsggEuIY/NF1i0R0MGCkxDUVEcpSj2BiDzDTxItbwaFIXb7K/VxLiV8Ku
X-Received: by 2002:aa7:dd0e:: with SMTP id i14mr4698482edv.172.1553095642440;
        Wed, 20 Mar 2019 08:27:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553095642; cv=none;
        d=google.com; s=arc-20160816;
        b=VURS293HVeyhrXx0TEY1BD57PqWpgYxFXJsr6euW1G00a5SO2N9nr2mMfcx06hXO0B
         bQoTlIpaFepmXqHwzo/sOc7vvyRdtFUlVa1m/NK72gnK4ae26NChZs6yPqbk3Z+K48xV
         eWfkzu3WjcJXPiukFS9XwotjLUHb0yuAMuutTIHMSEc8EV0QcVIkTjesv0Nf7unnldAb
         dvgU/yh8kZHTc+qzHCQknVXkFt0dtHVRpRF+IDnqYV2h1vsDGGO/hRbdwjL/kghRz+zb
         NYiFJhrfkjYE+PZUpbFgQFK/clDYUIjgHLa9XVTMExOa+5wXOMLZPD6OT+a0URwQNG5F
         WM5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=MYvS8pRbla5316/OiMfUzQdkBVY1RnrbS+JhvCqqByo=;
        b=qQxCGHvx4wfYKIfq0rv9Jj5+tL25G9I48N11iMFJESVJ1GiRiLl3z04c1adt8eQHuR
         9m+QQiFjINZjXNtDbEz2Sakvzh8skRDQxqoACDqr+0TSBPnvrsKL0Bj/8nn51lgA1r2g
         SdGIzj3Z7x7a1VvadW5vqVKkhEWk3QkA/SfqgzuYxtzrftWybaDCbm/n2K1n/dFCXfBX
         HclTwWOI8TIebugCOPVmHykCt6HvxIKZpMhz6NJf75elc3BKJfZv1WMQjADBE4Z4zw+o
         1YTGAuScLkvHIaVuW4+Ji/ZRTVdXsX3erGlmaAWhp/vyfHyoHHC9Dfa9Kp7hHR5Qo0CE
         mHpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id 96si889127edr.430.2019.03.20.08.27.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 08:27:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Wed, 20 Mar 2019 16:27:21 +0100
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Wed, 20 Mar 2019 15:27:04 +0000
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	david@redhat.com,
	mike.kravetz@oracle.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Oscar Salvador <osalvador@suse.com>
Subject: [PATCH resend 0/2] Unlock 1GB-hugetlb on x86_64 
Date: Wed, 20 Mar 2019 16:26:56 +0100
Message-Id: <20190320152658.10855-1-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000199, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Oscar Salvador <osalvador@suse.com>

RFC -> V1:
	- Split up the patch
	- Added Michal's Acked-by
	- Rebased and added David's Reviewed-by

The RFC version of this patch was discussed here [1], and it did not find any
objection.
I decided to split up the former patch because one of the changes enables
offlining operation for 1GB-hugetlb pages, while the other change is a mere
cleanup.

Patch1 contains all the information regarding 1GB-hugetlb pages change.

[1] https://lore.kernel.org/linux-mm/20190221094212.16906-1-osalvador@suse.de/

Oscar Salvador (2):
  mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
  mm,memory_hotplug: Drop redundant hugepage_migration_supported check

 mm/memory_hotplug.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

-- 
2.13.7

