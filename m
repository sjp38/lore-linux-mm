Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05670C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:43:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7AFE2171F
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:43:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7AFE2171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 645446B0003; Mon, 20 May 2019 21:43:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F65C6B0005; Mon, 20 May 2019 21:43:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E4B26B0006; Mon, 20 May 2019 21:43:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 167276B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 21:43:43 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p14so28153987edc.4
        for <linux-mm@kvack.org>; Mon, 20 May 2019 18:43:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DddwT0x8zMq9ZypXaz8ht9er9UPkaa5SLfsnPfZzPmE=;
        b=qotBOjF/oBR2diKdoaY6Vt2NkiegZIV5tlfWjmcnhxIEYJBrKzbFs2w0MQLSvAAzYW
         1/t930WAHxffg/VpjKEdvbOo6zd6F07MHibvh/mHCMTWBsniSyduOTAkAFdnF9uYGF+H
         gHAriGhYq4Kt+spdMVkYQ1AXO4sg3HrQaWQfxLlkF26U0icA5Qgc4mAb8hFN40PtX5HL
         1s24oIuQu5XwSFKUVBJGea3Lz7U5vZyEuRL2CIZzT8EYhzCDDlfR2C9giSvZtCWZoHRd
         +4i3D48WPJG73Ty1or5mO7K3YonKozAMIjGUuWETicH/uF+Kj7fYUPIxLwoc5Q+e0SvO
         kM+Q==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAVqB2PlHjpT7J3SbOTyGxMVN7BaxCQaIxs32hm3odrRwst2296K
	vwRBqa5y9dafm0TCHdvY9pIWgUvaukI1BBjBqoF6pfjTTrlzJD454C/K9ufsb71Hx43XMflBzXV
	4tuGTJ1pzEHLouD/34PNHJAjiR2CnJqx+NpSDQqABn5O1MXx0nwtvsGAjGgc4zgw=
X-Received: by 2002:aa7:db0c:: with SMTP id t12mr80430545eds.170.1558403022689;
        Mon, 20 May 2019 18:43:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxryboEZs6xg2kVIWgB9C4uZMeWqgPhjaV2nDTOnf9/Eb/Rm18LbXFSB81Gfp76iNloxzOd
X-Received: by 2002:aa7:db0c:: with SMTP id t12mr80430503eds.170.1558403021993;
        Mon, 20 May 2019 18:43:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558403021; cv=none;
        d=google.com; s=arc-20160816;
        b=q9gUosap94/iiOAK+KhuELMb1YU9qBQKuCugORXRcgL2dPkpuHtY+5Wn7pED+opNhO
         1a7jUx/QkfbWN5IdzfVbe/9fzRWXaJNl3j3EZqByOZ6ZtCbE5u1biOtuSSxvje0Gd9Hn
         Log8KfdZ2N8NyLFKDNay9OhNHfucvyWJ3ZZ0LRy11MctS/+0McWRs3DAnm/fYB9gkc8q
         bBZaarUCpgsfPQsivrk1MYw/MPkJ3gmaAxUXNqOYki0hk3lz9/mq6Z20sTO0WbVo9kOh
         FTKhnmyOvDJ6rNv6IGB5NNAvcc7yh63zcL4jXMFWAwNQZqDL2Osx5DYZ7AAfm7q1TTUK
         ZjoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=DddwT0x8zMq9ZypXaz8ht9er9UPkaa5SLfsnPfZzPmE=;
        b=Fm3SOP7A0I7ZVG2m3qWMa1Kkov/RLDIBD5GqFtLZMEOEGrmK41zP62r8iVKYfUzsdQ
         keqwTDWzr06A8qCk8GWN3lk4e/VSTBXWk2MbvzkfeKieSHfWmY+64qESxYb+7+SPHDx/
         i8ENsI4hVGR2p4wZgXb/2dc4MuBQE94GrURsRXOj1uG2y1CuSv4ntbuxNwW+JM3gIIFj
         fjbRljT9ki9oa4ai+8fw3fAXEJgMRTHVbzID0CMsQB9VDY6EimHzGIGSsrHG0tkEZR7U
         ew+wDdCcLxPp32YcKS0BkopEcg7UN9dYQ0Ov316IUGtWHZINK1cItJXH1GAgy+XbUmL1
         GvVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id r21si9448742ejn.154.2019.05.20.18.43.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 18:43:41 -0700 (PDT)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::3d8])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id AC23214249739;
	Mon, 20 May 2019 18:43:38 -0700 (PDT)
Date: Mon, 20 May 2019 18:43:36 -0700 (PDT)
Message-Id: <20190520.184336.743103388474716249.davem@davemloft.net>
To: rick.p.edgecombe@intel.com
Cc: linux-kernel@vger.kernel.org, peterz@infradead.org, linux-mm@kvack.org,
 mroos@linux.ee, mingo@redhat.com, namit@vmware.com, luto@kernel.org,
 bp@alien8.de, netdev@vger.kernel.org, dave.hansen@intel.com,
 sparclinux@vger.kernel.org
Subject: Re: [PATCH v2] vmalloc: Fix issues with flush flag
From: David Miller <davem@davemloft.net>
In-Reply-To: <a43f9224e6b245ade4b587a018c8a21815091f0f.camel@intel.com>
References: <3e7e674c1fe094cd8dbe0c8933db18be1a37d76d.camel@intel.com>
	<20190520.203320.621504228022195532.davem@davemloft.net>
	<a43f9224e6b245ade4b587a018c8a21815091f0f.camel@intel.com>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Mon, 20 May 2019 18:43:39 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Date: Tue, 21 May 2019 01:20:33 +0000

> Should it handle executing an unmapped page gracefully? Because this
> change is causing that to happen much earlier. If something was relying
> on a cached translation to execute something it could find the mapping
> disappear.

Does this work by not mapping any kernel mappings at the beginning,
and then filling in the BPF mappings in response to faults?

