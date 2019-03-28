Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C40BFC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:41:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7EFB021773
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:41:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="JDZi8m6A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7EFB021773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1647E6B0007; Thu, 28 Mar 2019 11:41:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EFE76B000C; Thu, 28 Mar 2019 11:41:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0019B6B0285; Thu, 28 Mar 2019 11:41:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D26A16B0007
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:41:43 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id a188so4000469qkf.0
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:41:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=VSIK0NlB9kqC2VbxVE8Lqm6fkbIpXVRmd/x9heQilLI=;
        b=rQOv1D+NAdJbM1dcMi4hQwdYiQ7I7E4O+fPVcjY8IcDCS/9IHyuQ2esEqalpR/Jbt5
         nhgyuVknjXYEj8rtYy/3BIl9eUVRD1V1Hq7+5L3P5Edq94apjVm4tXH/9tkMizSX1wKg
         f07PaVNrploxj0nKG3W4ENjAaR5GHOeK/m6bb4ga5YX+aL48vr8eKaqEaUy0iWypykja
         AQJ9RS67PHuFMpxx9s+IdTAvNvcHnAJsFKPxP8/EQ3srNRPWxK5qPSXsEOp6deFWrSCY
         ONEt+AYXPw93fiT/yV077/ZskUss0aDoSeFZr7VW3/yAp1522+Ta9NOgR16T/Q8dDPjX
         yL0w==
X-Gm-Message-State: APjAAAVFVuFbYHd5cik55qSBUYTFP+r7AnfSaCp/wCNC3G7D7hDBCunH
	rXPYuG3/lr9emh1UzVsgJSRsQB/DXlZQIbYOcvGEbEwU/dNF8C5cKQ2UwF3c1EUiw6evo97WfNW
	n03gWyfrJ8Yjz6Nys6a8OrfydLqZbaJPVgyZFCWCLEWmh1sENwn+w+BkSCHSnD8rkww==
X-Received: by 2002:a0c:b501:: with SMTP id d1mr36899111qve.115.1553787703610;
        Thu, 28 Mar 2019 08:41:43 -0700 (PDT)
X-Received: by 2002:a0c:b501:: with SMTP id d1mr36899062qve.115.1553787702982;
        Thu, 28 Mar 2019 08:41:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553787702; cv=none;
        d=google.com; s=arc-20160816;
        b=qPXj/D2Nu9GGrVnPORYmWTFrSVrTZSJWqwyDY//4oRKWH/mX2ZZQBcBvT75jiqyBMd
         MKiInfs+HJyCXLICH/lk4IBvGQLkqVxAJdj+qsxW2mVF8KcKZ2zNmi//eCh3GeAloDqu
         SIuf7BEzcJqDaFBjdWy5jXxgYsQjFVAdYEmOxamYKdEW2pPskRwCxX0vw1ocavcB42We
         0ZuI/3kmEB7YSxREMyuWi/44Fr86rdJoZefB6nX/7V7sz56WtWu9n0pIKRJrpAQ40nGF
         Xd0+eKLelOSWl87iJ4zXP8v8UpuuZYAi9jy5tWkKUf3TI7jB6HfIkbVEa6gs1GH08y+c
         71Pw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=VSIK0NlB9kqC2VbxVE8Lqm6fkbIpXVRmd/x9heQilLI=;
        b=USlKHvEovofC+jKZKXGvpdLOVnClyiBxEoVKFqEPqNrkB3IG9Y66rNWrlFt8YrfnLJ
         LWx96qcTSghHyWj9orZge+UcHqeTYZcagmmnaX0fA9+Q+RtRBtt9Lg4Ag+0G4e0GlPXv
         PJUsOlsxmX0fGdp86x+KKwk6kXuQmchFtQOVqHAdA6QdyEe6Q/Alq+wKj2NYltQApX7S
         6sNCF9Sxl0iUr1nZEnoatXQXdsT++d2+s+gYYe5FM+hEB4HYaB9hcslPwJHdLWIkIry8
         jhZK87iAvtFGPbc9V1mtVySpr6Wi4NQR50P6O5U+Mt/AXk0x5dTgYphXcp+/XCWwpIh9
         qhNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=JDZi8m6A;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v35sor1288856qvc.41.2019.03.28.08.41.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Mar 2019 08:41:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=JDZi8m6A;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=VSIK0NlB9kqC2VbxVE8Lqm6fkbIpXVRmd/x9heQilLI=;
        b=JDZi8m6ACT0foATFYmQ6ovzh0iDKHypwkpqBZs9kyJL7ichy99ptXM6U/fKrgcZYzL
         wmjsZlHhckKBj8vWlcbNFaAGAVE9/t7SwmiFiATM1po1utOEgf0S4x9oLDZDTt+fmpFq
         +3r0Caq6JFDqDhTqe61s9CTKH/azj0vIanSTdCO8lb477DU+xkb9m2il8hhej59lVdQ8
         uE3gMzsNK25/EqDNFkhttnrONv1vt+G7dNQvnItgoO2Py6tymhTJL7AlcqYPLDsBnVVH
         nUndYHgqz/ajLVfBx7sC/FM7t4LSUlqSvERdbkqgKjhFShrEbC20DDumx3UBXziLbZbr
         rMLQ==
X-Google-Smtp-Source: APXvYqwOKXrnwuWYvmxRUfZxLNHbF5XUH/2O1kIju5c+oTYyHsaPHoHFiusJXvtbeVTZjrYnxW37Kw==
X-Received: by 2002:a0c:d6c9:: with SMTP id l9mr36061464qvi.58.1553787702607;
        Thu, 28 Mar 2019 08:41:42 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id u3sm4236697qtk.97.2019.03.28.08.41.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 08:41:41 -0700 (PDT)
Message-ID: <1553787700.26196.28.camel@lca.pw>
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
From: Qian Cai <cai@lca.pw>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org,
 cl@linux.com,  willy@infradead.org, penberg@kernel.org,
 rientjes@google.com,  iamjoonsoo.kim@lge.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Date: Thu, 28 Mar 2019 11:41:40 -0400
In-Reply-To: <20190328150555.GD10283@arrakis.emea.arm.com>
References: <20190327005948.24263-1-cai@lca.pw>
	 <20190327084432.GA11927@dhcp22.suse.cz>
	 <20190327172955.GB17247@arrakis.emea.arm.com>
	 <49f77efc-8375-8fc8-aa89-9814bfbfe5bc@lca.pw>
	 <20190328150555.GD10283@arrakis.emea.arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-03-28 at 15:05 +0000, Catalin Marinas wrote:
> > It takes 2 runs of LTP oom01 tests to disable kmemleak.
> 
> What configuration are you using (number of CPUs, RAM)? I tried this on
> an arm64 guest under kvm with 4 CPUs and 512MB of RAM, together with
> fault injection on kmemleak_object cache and running oom01 several times
> without any failures.

Apparently, the CPUs are so fast and the disk is so slow (swapping). It ends up
taking a long time for OOM to kick in.

# lscpu
Architecture:        x86_64
CPU op-mode(s):      32-bit, 64-bit
Byte Order:          Little Endian
CPU(s):              48
On-line CPU(s) list: 0-47
Thread(s) per core:  2
Core(s) per socket:  12
Socket(s):           2
NUMA node(s):        2
Vendor ID:           GenuineIntel
CPU family:          6
Model:               85
Model name:          Intel(R) Xeon(R) Gold 6126T CPU @ 2.60GHz
Stepping:            4
CPU MHz:             3300.002
BogoMIPS:            5200.00
Virtualization:      VT-x
L1d cache:           32K
L1i cache:           32K
L2 cache:            1024K
L3 cache:            19712K
NUMA node0 CPU(s):   0-11,24-35
NUMA node1 CPU(s):   12-23,36-47

# free -m
              total        used        free      shared  buff/cache   available
Mem:         166206       31737      134063          33         406      133584
Swap:          4095           0        4095

# lspci | grep -i sata
00:11.5 SATA controller: Intel Corporation C620 Series Chipset Family SSATA
Controller [AHCI mode] (rev 08)
00:17.0 SATA controller: Intel Corporation C620 Series Chipset Family SATA
Controller [AHCI mode] (rev 08)

