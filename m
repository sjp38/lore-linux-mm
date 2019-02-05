Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2E55C282D7
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 18:43:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 585862184B
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 18:43:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 585862184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB5518E0099; Tue,  5 Feb 2019 13:43:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3D0F8E0093; Tue,  5 Feb 2019 13:43:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DDFE8E0099; Tue,  5 Feb 2019 13:43:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 505768E0093
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 13:43:22 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id b7so2787484pge.17
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 10:43:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=78vgH0Hb4lruM2A3RwAT/o98Nnbku8cm1SBl5TXkVDg=;
        b=CgS5i4QbhYmOeRjXHIeBfnCK5GkokM0l3r7MneM+/NERhVqyAJnPYL4VFaMxyANsc8
         jiKBovFhWNhl5bEdzBFD37Sc/tDOsTNKPIefVrNbwMXQd49IvUzDWWr0hnMUJNj7LO4E
         HVQcyKC9ps7Q6xfCblHcIX16AktV3QDLGr+zWAjA8OrPg2a3566/czKSPCZBl0jjZlNe
         IrlGIAm0rTCfcmdbshKGG9RX02f5P2HhKR7ntpQ3graD79rXgeea3Bvxx2bYSyQ8sl+p
         kviBNNanDlBPoqz2PiAAUQbQOzm2ofk9IE2+FvnrslIeWobHSs2KDwnPA/p/rhTVO8gU
         Nh1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZu/J8wgnveoaFXDHsAhJOQWWa1RcN+DMJe5uj7JaV6lU1Rcruh
	ykQCKu2r597OYVKPijF9NxrACYfvVT9diO0d/y+S0HQCUccznMekgSwBQgW9mnASRvix+4jybwp
	8et4nNpbs+4wWCV8MSaw5UDlT6SsK8oB0qCtoo80r44Av0sujTpIU3yUd0nFGZJy1mw==
X-Received: by 2002:a63:fd0a:: with SMTP id d10mr1071703pgh.164.1549392201868;
        Tue, 05 Feb 2019 10:43:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZqI+lkcjgya37OAEXTcAiqZip8EADVziwYrM63OzdQ9TUtKsfCnuIHxsa8NewjOqGmh9Jl
X-Received: by 2002:a63:fd0a:: with SMTP id d10mr1071635pgh.164.1549392200936;
        Tue, 05 Feb 2019 10:43:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549392200; cv=none;
        d=google.com; s=arc-20160816;
        b=PjmF0nNImg75+2FtO2DZT8U1o9sNVlZI/TRXk7o5EJbAd0A7U+BLpyTMwCrbIFsEga
         yUgoODuU9dgu9qu9QyodDEEIxcKx0Yc/rTNbhx3IpRdOiStBOJ8NkXWl8LNTxAzN520p
         gSAbCRxI9QiwspOJxJxFjMYHjRFGQVvz6FB2ebeetZG7CNrOCxsBM1nkRUS7HfcE/bv9
         krl6GYRbKEPLCdkyb1Q8TDt7jAb0Mov3T65YJnjYHVPuQ1Wpv+hxjyOvQepdAF581BEY
         3tvWzBaDN9O8tz04VlaNiJEX+pJpLCcPGKGwmE6CQGP66DyO4vT2BW/omo0DNs9Z/bCg
         H4BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=78vgH0Hb4lruM2A3RwAT/o98Nnbku8cm1SBl5TXkVDg=;
        b=UZtxuNt6ndrp0gElQGiRNFvlOPSfYWavfjZHRClIb0DmyyOcETdxPtRRdCGAJuQ5Bq
         5tl3xZatp+Z4hlujjdc2qvyfWD5AIy6YjzSO3+1+s3CSK3c4EusD6chkm7EreWjd1EMg
         1js2bN+Qc0wyah4vvS5elBRKZ3dr8nuE8WPH0fV1TGPr96eDf9jHP/HzoxvjCtwlJWmM
         XnndMRU2/U35cKQGNOXSvJ9FGLYF/9bMTYkX736s2cVi3ZFV9Yj9FD27z1/gOLl50Ail
         KJveB4yJaNMXKk6JrtWxMpDSsBVEFiqIzm6C62rDUWVhNNRw0H8t5CaUV9AjMSkOxg+N
         Xn/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id w62si3916469pfk.73.2019.02.05.10.43.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 10:43:20 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Feb 2019 10:43:20 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,336,1544515200"; 
   d="scan'208";a="136125414"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga001.jf.intel.com with ESMTP; 05 Feb 2019 10:43:20 -0800
Message-ID: <274c9e23cb0bf947d8dd033bd8a7c14252ba9b85.camel@linux.intel.com>
Subject: Re: [RFC PATCH 0/4] kvm: Report unused guest pages to host
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>, Alexander Duyck
 <alexander.duyck@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,  kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, x86@kernel.org, mingo@redhat.com, bp@alien8.de, 
 hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de,
 akpm@linux-foundation.org,  Luiz Capitulino <lcapitulino@redhat.com>, David
 Hildenbrand <david@redhat.com>, Pankaj Gupta <pagupta@redhat.com>
Date: Tue, 05 Feb 2019 10:43:20 -0800
In-Reply-To: <697d3769-9320-a632-749e-56de9474bdf0@redhat.com>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
	 <697d3769-9320-a632-749e-56de9474bdf0@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-02-05 at 12:25 -0500, Nitesh Narayan Lal wrote:
> On 2/4/19 1:15 PM, Alexander Duyck wrote:
> > This patch set provides a mechanism by which guests can notify the host of
> > pages that are not currently in use. Using this data a KVM host can more
> > easily balance memory workloads between guests and improve overall system
> > performance by avoiding unnecessary writing of unused pages to swap.
> > 
> > In order to support this I have added a new hypercall to provided unused
> > page hints and made use of mechanisms currently used by PowerPC and s390
> > architectures to provide those hints. To reduce the overhead of this call
> > I am only using it per huge page instead of of doing a notification per 4K
> > page. By doing this we can avoid the expense of fragmenting higher order
> > pages, and reduce overall cost for the hypercall as it will only be
> > performed once per huge page.
> > 
> > Because we are limiting this to huge pages it was necessary to add a
> > secondary location where we make the call as the buddy allocator can merge
> > smaller pages into a higher order huge page.
> > 
> > This approach is not usable in all cases. Specifically, when KVM direct
> > device assignment is used, the memory for a guest is permanently assigned
> > to physical pages in order to support DMA from the assigned device. In
> > this case we cannot give the pages back, so the hypercall is disabled by
> > the host.
> > 
> > Another situation that can lead to issues is if the page were accessed
> > immediately after free. For example, if page poisoning is enabled the
> > guest will populate the page *after* freeing it. In this case it does not
> > make sense to provide a hint about the page being freed so we do not
> > perform the hypercalls from the guest if this functionality is enabled.
> > 
> > My testing up till now has consisted of setting up 4 8GB VMs on a system
> > with 32GB of memory and 4GB of swap. To stress the memory on the system I
> > would run "memhog 8G" sequentially on each of the guests and observe how
> > long it took to complete the run. The observed behavior is that on the
> > systems with these patches applied in both the guest and on the host I was
> > able to complete the test with a time of 5 to 7 seconds per guest. On a
> > system without these patches the time ranged from 7 to 49 seconds per
> > guest. I am assuming the variability is due to time being spent writing
> > pages out to disk in order to free up space for the guest.
> 
> Hi Alexander,
> 
> Can you share the host memory usage before and after your run. (In both
> the cases with your patch-set and without your patch-set)

Here are some snippets from the /proc/meminfo for the system both
before and after the test.

W/O patch
-- Before --
MemTotal:       32881396 kB
MemFree:        21363724 kB
MemAvailable:   25891228 kB
Buffers:            2276 kB
Cached:          4760280 kB
SwapCached:            0 kB
Active:          7166952 kB
Inactive:        1474980 kB
Active(anon):    3893308 kB
Inactive(anon):     8776 kB
Active(file):    3273644 kB
Inactive(file):  1466204 kB
Unevictable:       16756 kB
Mlocked:           16756 kB
SwapTotal:       4194300 kB
SwapFree:        4194300 kB
Dirty:             29812 kB
Writeback:             0 kB
AnonPages:       3896540 kB
Mapped:            75568 kB
Shmem:             10044 kB

-- After --
MemTotal:       32881396 kB
MemFree:          194668 kB
MemAvailable:      51356 kB
Buffers:              24 kB
Cached:           129036 kB
SwapCached:       224396 kB
Active:         27223304 kB
Inactive:        2589736 kB
Active(anon):   27220360 kB
Inactive(anon):  2481592 kB
Active(file):       2944 kB
Inactive(file):   108144 kB
Unevictable:       16756 kB
Mlocked:           16756 kB
SwapTotal:       4194300 kB
SwapFree:          35616 kB
Dirty:                 0 kB
Writeback:             0 kB
AnonPages:      29476628 kB
Mapped:            22820 kB
Shmem:              5516 kB

W/ patch
-- Before --
MemTotal:       32881396 kB
MemFree:        26618880 kB
MemAvailable:   27056004 kB
Buffers:            2276 kB
Cached:           781496 kB
SwapCached:            0 kB
Active:          3309056 kB
Inactive:         393796 kB
Active(anon):    2932728 kB
Inactive(anon):     8776 kB
Active(file):     376328 kB
Inactive(file):   385020 kB
Unevictable:       16756 kB
Mlocked:           16756 kB
SwapTotal:       4194300 kB
SwapFree:        4194300 kB
Dirty:                96 kB
Writeback:             0 kB
AnonPages:       2935964 kB
Mapped:            75428 kB
Shmem:             10048 kB

-- After --
MemTotal:       32881396 kB
MemFree:        22677904 kB
MemAvailable:   26543092 kB
Buffers:            2276 kB
Cached:          4205908 kB
SwapCached:            0 kB
Active:          3863016 kB
Inactive:        3768596 kB
Active(anon):    3437368 kB
Inactive(anon):     8772 kB
Active(file):     425648 kB
Inactive(file):  3759824 kB
Unevictable:       16756 kB
Mlocked:           16756 kB
SwapTotal:       4194300 kB
SwapFree:        4194300 kB
Dirty:           1336180 kB
Writeback:             0 kB
AnonPages:       3440528 kB
Mapped:            74992 kB
Shmem:             10044 kB

