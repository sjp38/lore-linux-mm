Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80DE4C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:15:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 259242082E
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:15:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EVivxx3z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 259242082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 949248E004E; Mon,  4 Feb 2019 13:15:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FAB58E001C; Mon,  4 Feb 2019 13:15:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E7708E004E; Mon,  4 Feb 2019 13:15:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3AD1E8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 13:15:37 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o9so405077pgv.19
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 10:15:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=YbgwgPfTgR6RtE7F+vI0MmFOmUqaJ06bNhtl9pXn92s=;
        b=CfhqWOnMA7cfBsCc2sHy6FRnyV19VddhFvOXMJs4V+KybcSKG5iOnOCm064I+EzcB5
         DTLBd4dsOsJoxqNO/jtmB6x275SIWcPeeBxi/2fSomlLuU5vqXNmt4HUwsHELeDhovlq
         BuYSoTxkD1fVLb8dlXzxaLhFGKlsc7PkjWojTeeT7aYniIwY3SqV8hCll5qoN8xGH0IQ
         vw0X3SvNnXIToHm15ruZ7TsPylFpoUngc4TcMNO/okTxG2jHKyoWcVqHBt1yJcRM09AK
         N61xWMEBzEalI/sPy3peSDTeYpzpgG4N5YJw4Zbu7P4ITYU3J3rFyRMv5N40AJOuJ4ii
         A/Kg==
X-Gm-Message-State: AHQUAubE9QSDXPkqToygeG8HujlbgC4sP5cNMfZQh4L5ck7HWxQszUGu
	EI7G+2KvvFFHCEyaU86myahAypl4sc49PF9Jt87c+82TtvAa7wwpUIH8ebgWDvVlsGAFBO/azeE
	MpOXRP7cEfub870l2eSS+cipSOLRNygZjZhSvf2KINiBTVkDQQRjr89AZWs7oiIX+dZPmrj9Glb
	sknHdemvay7IGLzZINeWET6KuUrBYViLNwJn7OjlMNQPOl7go0xZ9X3P8p+yqKCKjK4KxyLqpeE
	BMZwJceFyYVcV4fJiJVIKelH+oPHsisZgpiBb3ZQdfvLYGpibIecFn4D3cNqPTsk49Il80RvSMM
	1IKp50caD2L6kYCeYJKZSgRXV14ysQqU35bVoHsysZPpuKxgFdErka+Jk6uAZIL1RJ2FlyqrZgy
	0
X-Received: by 2002:a62:4641:: with SMTP id t62mr634284pfa.141.1549304136834;
        Mon, 04 Feb 2019 10:15:36 -0800 (PST)
X-Received: by 2002:a62:4641:: with SMTP id t62mr634209pfa.141.1549304135916;
        Mon, 04 Feb 2019 10:15:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549304135; cv=none;
        d=google.com; s=arc-20160816;
        b=UIh9Hbxf7s2mLAAp5VekONQ/HrYVolSq0QYO5VOSZlFhHKOaw2aT0Ope4ojsCAszX1
         egZQ6PUl+0rpxxOCuAlYS54u6B4/I1qYvqs9JT1rB4eyoJoX5/3c6AEpIh53mZN1ZUSc
         jm8vBTpNQo6oXolxjCeteZSKY1WRD8//BLeuDWbQvlPZEiRn6Mq6Yw+jWAG1b/+nize4
         7xjZ8nKGgWp80lCvvOPdQZ+btcDTiM0wWSnootn6wlkHKDoevsw+lZY8tfj4SEADOU2z
         6Jpn7bu0oo2UjA+e2h4Ojm+YRtiEM9YHpPTDmdCXAc+EZP2H5zetR5prQhDgiPFMsrL+
         2jQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=YbgwgPfTgR6RtE7F+vI0MmFOmUqaJ06bNhtl9pXn92s=;
        b=zo5nu1Q/SU2AzbU3V6JhqdHBF9kpYkmp/GnDlXkpRNmM/Zfrjzb7pbKO+NPCr+C/kU
         oMtvMqfan8a2pTid7bHLo0w6RYltJgAZbhz2Ra7V4kj0kxiw92hs9/pKGw21FWE4Y8DI
         DlmSjINPeKRBMc5AJJ/PWn5uObh5iwIlJ5+2ohjed2fhLPhhF/ul7h8xe8V5Bc5crrHU
         yIzDWqJPd73uFYWWuP/vcJkMmOyGaEXJ74Uahqopc6N68wIP9I7+F8Y6kjNVa6FZ0w1M
         BuirtcuahAOlv9gbBGJvzC9jlu3ZzDJdhN1zFlHRKQkXa5ogYkeBbHOSx10pEhA+IIn4
         Fdrg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EVivxx3z;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d27sor1379385pgm.9.2019.02.04.10.15.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 10:15:35 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EVivxx3z;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=YbgwgPfTgR6RtE7F+vI0MmFOmUqaJ06bNhtl9pXn92s=;
        b=EVivxx3zf3BECuE6OKnATN/wV4n+PQUGCg+NbojhIFckrkIugDtHvtRXly/Ho6uEGF
         quuKkvi+6vb8VkGYDjrNwqxTLE4X8wD4UIxTWltdzDOiGCZYQ/0j9HChN5tXdGQt8llQ
         wlvqR7bI42IxMNEhqP1j1Wojt3fBgK+4skyNEXbvJZ1YW3lTauav4irVYoNez68sim9z
         dmiLUVGkthOoZBrYjvzitJYoIVCGoC4f0iwzLQAnVjgakyQ/iIGuuFMXtbh2AkgXREj7
         Gn6Bv3Yq7k1i7IaPEgpG84u4CItcQMzeHX4JEn4aPeh/IcYVWR54IOd4BEnLl9ZSH89A
         Jveg==
X-Google-Smtp-Source: AHgI3IYdUC2KYnsIvatwFAItCTG9QdAywv9GyQbmcX0uwgxjOHlfiVJgi/57nTVo6HelLpv6X8ouSg==
X-Received: by 2002:a63:2406:: with SMTP id k6mr565655pgk.229.1549304135284;
        Mon, 04 Feb 2019 10:15:35 -0800 (PST)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id v12sm853005pgg.41.2019.02.04.10.15.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 10:15:34 -0800 (PST)
Subject: [RFC PATCH 0/4] kvm: Report unused guest pages to host
From: Alexander Duyck <alexander.duyck@gmail.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com, x86@kernel.org,
 mingo@redhat.com, bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com,
 tglx@linutronix.de, akpm@linux-foundation.org
Date: Mon, 04 Feb 2019 10:15:33 -0800
Message-ID: <20190204181118.12095.38300.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch set provides a mechanism by which guests can notify the host of
pages that are not currently in use. Using this data a KVM host can more
easily balance memory workloads between guests and improve overall system
performance by avoiding unnecessary writing of unused pages to swap.

In order to support this I have added a new hypercall to provided unused
page hints and made use of mechanisms currently used by PowerPC and s390
architectures to provide those hints. To reduce the overhead of this call
I am only using it per huge page instead of of doing a notification per 4K
page. By doing this we can avoid the expense of fragmenting higher order
pages, and reduce overall cost for the hypercall as it will only be
performed once per huge page.

Because we are limiting this to huge pages it was necessary to add a
secondary location where we make the call as the buddy allocator can merge
smaller pages into a higher order huge page.

This approach is not usable in all cases. Specifically, when KVM direct
device assignment is used, the memory for a guest is permanently assigned
to physical pages in order to support DMA from the assigned device. In
this case we cannot give the pages back, so the hypercall is disabled by
the host.

Another situation that can lead to issues is if the page were accessed
immediately after free. For example, if page poisoning is enabled the
guest will populate the page *after* freeing it. In this case it does not
make sense to provide a hint about the page being freed so we do not
perform the hypercalls from the guest if this functionality is enabled.

My testing up till now has consisted of setting up 4 8GB VMs on a system
with 32GB of memory and 4GB of swap. To stress the memory on the system I
would run "memhog 8G" sequentially on each of the guests and observe how
long it took to complete the run. The observed behavior is that on the
systems with these patches applied in both the guest and on the host I was
able to complete the test with a time of 5 to 7 seconds per guest. On a
system without these patches the time ranged from 7 to 49 seconds per
guest. I am assuming the variability is due to time being spent writing
pages out to disk in order to free up space for the guest.

---

Alexander Duyck (4):
      madvise: Expose ability to set dontneed from kernel
      kvm: Add host side support for free memory hints
      kvm: Add guest side support for free memory hints
      mm: Add merge page notifier


 Documentation/virtual/kvm/cpuid.txt      |    4 ++
 Documentation/virtual/kvm/hypercalls.txt |   14 ++++++++
 arch/x86/include/asm/page.h              |   25 +++++++++++++++
 arch/x86/include/uapi/asm/kvm_para.h     |    3 ++
 arch/x86/kernel/kvm.c                    |   51 ++++++++++++++++++++++++++++++
 arch/x86/kvm/cpuid.c                     |    6 +++-
 arch/x86/kvm/x86.c                       |   35 +++++++++++++++++++++
 include/linux/gfp.h                      |    4 ++
 include/linux/mm.h                       |    2 +
 include/uapi/linux/kvm_para.h            |    1 +
 mm/madvise.c                             |   13 +++++++-
 mm/page_alloc.c                          |    2 +
 12 files changed, 158 insertions(+), 2 deletions(-)

--

