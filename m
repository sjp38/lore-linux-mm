Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD6DEC10F07
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 01:22:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57E512086D
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 01:22:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57E512086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE0EE8E0053; Wed, 20 Feb 2019 20:22:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8F928E0002; Wed, 20 Feb 2019 20:22:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 957778E0053; Wed, 20 Feb 2019 20:22:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6888E8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 20:22:52 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id i66so4100614qke.21
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:22:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=xMqOPzBoApQvxosqcRE2NLvJ4nK6olAuOVWHYAVPIUI=;
        b=OPnC/iJF/k/r/DbvoD6spUbwWaKmepS9AALZ0PBbNA3oCpsTV4+VM/Ql8DvkvxbSey
         OL5GdexBf2r3cO4vOEyhrowuPrT/1POs2Nfozr/XTZucpr5KOy4M/8kzMlciYzXFkSV0
         0qjsnoMwcOH2RlXZH4cNJF9a7ZrJX1JGZkSx44rPP/3o6GCWu5vHLcjQH4GPCP4JLQTn
         NFnr+5oIa/JosDrlcLlhYP9IWIV3O4cfIDyC8++KmyszjsxoHe944E/y7aTgNCDHRVZ2
         JckLJk6qjYvmO30N2e7l/PQO3BWax+58UDm7ZXlXOaeKndPBBWMPrYg1/bgcTqbXX5/5
         V3Gg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAua/mwgGtfxIui41VTcIAFsLCPgV8PaK30VAcjduq74EdsdDI1gz
	OF1aDaCp5/hgTpq95tZjHt9doVlk+a4swlWrMPobq1NL1zR5+UOImezTo5E5Mvyw07YgyqIVtrl
	PUFyhTt+iZpodCPrucX2ZOajPd7f9gG+ZkYxZ7KvD6JRctBn2uiv1DJgjnx0CKfpGPA==
X-Received: by 2002:a0c:d165:: with SMTP id c34mr27873164qvh.64.1550712172123;
        Wed, 20 Feb 2019 17:22:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibuk8Qw1+TRPBUes5/NVqjpzFohaSYSFLbw+AmUvQzWSc/aEM16FOveA5bZ0V8hLfyVe80U
X-Received: by 2002:a0c:d165:: with SMTP id c34mr27873138qvh.64.1550712171436;
        Wed, 20 Feb 2019 17:22:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550712171; cv=none;
        d=google.com; s=arc-20160816;
        b=db6NiY+JBh1JGN5I+mA8WKDhs+JLl8Zd88owdNb6iNqoMKVgmXLzHL5LeuOQKrjAgf
         KzxYlx44fPLgm9C3d1Xmndgm/VMh7AFwEW+5SFQcIN+cMAJPxYuCDQD+NPgKZCJomHse
         RUGhdaX6B5l6l7yjcXS9c0lt16102RDsACwPubKHhSuF4kqfTsMdAxPKywxMQ5s+WmAq
         bjKMHr9Q8vbrxKKvzGjjJY6Ah244rQAH/twF6g71SPzgpaWHeLLEj1rPQXFPbVx+ymGP
         a5ZKDN4OikS4qm9KwcxJAemLUMF4d9SPWupmOX0WK6KTjx0DY6NnjSBlA2oMUrHhz3JK
         BIgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=xMqOPzBoApQvxosqcRE2NLvJ4nK6olAuOVWHYAVPIUI=;
        b=erOqe5ExSLzmwnV5k39iIFaGMKANE36cOlBhSuovj2dVC1uUgPbFQteoMJgoar9fiW
         FuRLBp4AAxCHh3CXnOZxdocTQf5wUhfuIJU68PJA3EzoRsPDQgUIWb9KiEzNEbM5DNP5
         3m9YvWGPPt0AwlVaX2lrobtkEGKADFHOlvl3zkUton2SLTKLjA+7D3K3iSyXmKX9aZ1s
         /zHcELBgAlEvAz3wKzDZINW6yYZBlIj2iMr07ixv8sySr7sRW/km1SZBLF2Gf1JxkUW6
         usurpmTScGxLkaytVEfrHBdU9ZoovIiwO60dpYfF9j5rpvZxgdqFH+qCMv4RILOVoDL2
         5uyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r1si6446469qte.11.2019.02.20.17.22.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 17:22:51 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8002A81DE9;
	Thu, 21 Feb 2019 01:22:50 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-120-249.rdu2.redhat.com [10.10.120.249])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3889360BF2;
	Thu, 21 Feb 2019 01:22:46 +0000 (UTC)
From: jglisse@redhat.com
To: Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	kvm@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v2 0/1]  Restore change_pte optimization
Date: Wed, 20 Feb 2019 20:22:26 -0500
Message-Id: <20190221012227.13236-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 21 Feb 2019 01:22:50 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

This patch is on top of my patchset to add context information to
mmu notifier [1] you can find a branch with everything [2]. It has
been tested with qemu/KVM building kernel within the guest and also
running a benchmark which the result are given below.

The change_pte() callback is impaired by the range invalidation call-
back within KVM as the range invalidation callback as those do fully
invalidate the secondary mmu. This means that there is a window between
the range_start callback and the change_pte callback where the secondary
mmu for the address is empty. Guest can fault on that address during
that window.

That window can last for some times if the kernel code which is
doing the invalidation is interrupted or if they are other mmu
listener for the process that might sleep within their range_start
callback.

With this patch KVM will ignore the range_start and range_end call-
back and will rely solely on the change_pte callback to update the
secondary mmu. This means that the secondary mmu never have an empty
entry for the address between range_start and range_end and hence
the guest will not have a chance to fault.

This optimization is not valid for all the mmu notifier cases and
thanks to the patchset that add context informations to the mmu
notifier [1] we can now identify within KVM when it is safe to rely
on this optimization.

Roughly it is safe when:
    - going from read only to read and write (same or different pfn)
    - going from read and write to read only same pfn
    - going from read only to read only different pfn

Longer explaination in [1] and [3].

Running ksm02 from ltp gives the following results:

before  mean  {real: 675.460632, user: 857.771423, sys: 215.929657, npages: 4773.066895}
before  stdev {real:  37.035435, user:   4.395942, sys:   3.976172, npages:  675.352783}
after   mean  {real: 672.515503, user: 855.817322, sys: 200.902710, npages: 4899.000000}
after   stdev {real:  37.340954, user:   4.051633, sys:   3.894153, npages:  742.413452}

Roughly 7%-8% less time spent in the kernel. So we are saving few
cycles (this is with KSM enabled on the host and ksm sleep set to
0). Dunno how this translate to real workload.


Note that with the context information further optimization are now
possible within KVM. For instance you can find out if a range is
updated to read only (ie no pfn change just protection change) and
update the secondary mmu accordingly.

You can also identify munmap()/mremap() syscall and only free up the
resources you have allocated for the range (like freeing up secondary
page table for the range or data structure) when it is an munmap or
a mremap. Today my understanding is that kvm_unmap_hva_range() will
free up resources always assuming it is an munmap of some sort. So
for mundane invalidation (like migration, reclaim, mprotect, fork,
...) KVM is freeing up potential mega bytes of structure that it will
have to re-allocate shortly there after (see [4] for WIP example).

Cheers,
Jérôme

[1] https://lkml.org/lkml/2019/2/19/752
[2] https://cgit.freedesktop.org/~glisse/linux/log/?h=mmu-notifier-v05
[3] https://lkml.org/lkml/2019/2/19/754
[4] https://cgit.freedesktop.org/~glisse/linux/log/?h=wip-kvm-mmu-notifier-opti

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Xu <peterx@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>

Jérôme Glisse (1):
  kvm/mmu_notifier: re-enable the change_pte() optimization.

 virt/kvm/kvm_main.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

-- 
2.17.2

