Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 406EFC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 07:49:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E215F217D9
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 07:49:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="dp0W2MNX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E215F217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B7D78E0003; Tue, 12 Mar 2019 03:49:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 567468E0002; Tue, 12 Mar 2019 03:49:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42E3A8E0003; Tue, 12 Mar 2019 03:49:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 019018E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 03:49:57 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id t6so1766026pgp.10
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 00:49:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/olhjbpJtT1r+7uavB4KWlJpqCZECUEc8ErNDYVV/Hk=;
        b=WhmMVX8iICiEvQUT1jlIR8ou8iweh2SklhchE5+UvpCJnNfGwGMum3SLoV2uHMzW5n
         fFXiyCFn22Tuy/lRVqHm/sa9YreuDmVgsBOP/N2i+02Rwt1MpNp0jVYfdBtcjl4k0mdX
         iQQhp9CQEN9sCLtQNyRDHRv0y6lRgnpYXr6+dWtoD0UD+AMEuM5wVW6e5rYY6KG3o8+3
         jKEMksQjx11giEcPOglToyjRvZedn8ndm9lPhANPud49ELIC4lR5bIQeQcDnIZo3rTo2
         7fJfoe6xVmqbyfeVALFME7W2bP99YjjjAEYk20IShbPFTy+KrXnrJ68ahiw1wnFEOG/f
         /F+g==
X-Gm-Message-State: APjAAAXzKpW3C5fd7LpMxymTfUr4EFKSMkzZ5pNZTV7c0t9Lb4Ns7Eg0
	21ERyeCAIn0tsp+2geCeKkuC1xDmVqNk1sud+aoGwOV+wJkh50VjHQsD02BFF1smNmlu10K+wFf
	rERhGzqICvJaZQOyJ1KpNvBMtFbfbkUWRSJ9W63Lzmev+460truHBSWZYL9db1rr6nSrgC77Fc+
	pgdyhRoHMOFzBoLw14Ajg+o3PLna2Apgod2w+Ui7Kfc2CA3YVosvNQrWj7i2+CrIK+Lk/PwI7SE
	wqCijxEHjKowOM+YyyEyuti+E/bdKklPcLjMmWYEIOuXsYMtnp9Nk1Bx2tkqaTgwL1sXT/ZuSvk
	dHgcosC8/j8OhF7bhA1lSq1T8RqnJfLLDwJNUPdHtx5YOpiph8cV9t/ZFXT99VH7xy9chOuw9Uy
	N
X-Received: by 2002:a63:dc4a:: with SMTP id f10mr3640185pgj.231.1552376996527;
        Tue, 12 Mar 2019 00:49:56 -0700 (PDT)
X-Received: by 2002:a63:dc4a:: with SMTP id f10mr3640124pgj.231.1552376995468;
        Tue, 12 Mar 2019 00:49:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552376995; cv=none;
        d=google.com; s=arc-20160816;
        b=GtmGRHYEzyCeNgHi5NqUDtCmh/XhiGFX2L8lzH3rDaVUttsVA2WOTthfWwffvY7Zj1
         5gevkBoyUbU5VjsdaU0WQV2ko443UeiB2ouzOa0hbR7VkE+IzRkDH6Ns4mNZFP4GWbXQ
         6fZvuCECS8eLp9lxz+YNFd5ilX/7Gu1wv9vD+b3dtlf4awXlUlHaWrtwGj5hoC1bG608
         e/o1uE1vP/iZehIW4euV9Dl22mPqqyg/W4M8xQs3rYVx1eHehRGyJHf7dG3OqxmHgao4
         4a5QdW54MX62VCMiiDL5E7HV4/oC2A6On90fKGyZVYiKD5+W18A6gin0g9oxtWri69Bz
         yy7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/olhjbpJtT1r+7uavB4KWlJpqCZECUEc8ErNDYVV/Hk=;
        b=dxTQcVtOMCgKq13WuNPqoKF51di1NDgLHm9bmYORonleiV0nh54MIfg0VkqUlKxFAT
         pnEKZT05FxewLqwzo1N3v6TxMM0LP964yrJWkPnskGw7hs9N7ESVdVgKNrvaKGQaJzHS
         hb7HIo3XHZCLlHSZ6nkfrUQ19wyO2r5D1ai3b0UQegHgw68E/voU7V/nB1cursVuSOVV
         6SLdKh+JpxzOuSSrgW50EUbNy1czfvG74Un7v22fuz4G6yq+7eCjj9O0kehXhBQa+dnA
         TajLiVqCWdEzgJtI8TqrEsU142hEroqesbZnZebLY/vP8xbFARqx1eIfrHqRC7mZa1Fh
         Ao2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=dp0W2MNX;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor12577467pfy.19.2019.03.12.00.49.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 00:49:55 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=dp0W2MNX;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=/olhjbpJtT1r+7uavB4KWlJpqCZECUEc8ErNDYVV/Hk=;
        b=dp0W2MNXHHwMurb7064PydUXyMqSIuX9WHN8wbk1FpKFfs4OSrPwv7gmXApzlzCY2d
         GbbBJMVpiYY2uZEAAZkZHZlQEcn6et3K8/ApQZ+AJo72JyN+d/lPasNL5as3MpAt+37N
         J1q2apNjiRCSEBFvuFoVBn9oMKRzzx1ccQ/3yoBjkjweP2R8E9kNu4A3BZwXtmDNPYUc
         BFvryNedtwL8eFbTaB9tqxqIprA7NJBu6Fa+m5yuAFOBcbnfMPeiRxIp8HL4Pb2jMb8/
         pyegpYg2Sae3wkHR/n1VnhwN5fk7MQGU3ivU1LKCIPnZ1EUZaFByAGTW3vnECAXEyRyW
         f9SQ==
X-Google-Smtp-Source: APXvYqxhoObJjZuttW1IPJrOnClfmIL5opPUfwHN9lGtlRAK/7XJitiZM5dBu2mlrfC7DZuBgNTIUQ==
X-Received: by 2002:aa7:8d42:: with SMTP id s2mr37450966pfe.116.1552376994892;
        Tue, 12 Mar 2019 00:49:54 -0700 (PDT)
Received: from kshutemo-mobl1.localdomain (fmdmzpr04-ext.fm.intel.com. [192.55.54.39])
        by smtp.gmail.com with ESMTPSA id x1sm13580445pge.73.2019.03.12.00.49.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 00:49:54 -0700 (PDT)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id B21DA3011CA; Tue, 12 Mar 2019 10:49:51 +0300 (+03)
Date: Tue, 12 Mar 2019 10:49:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Peter Xu <peterx@redhat.com>
Cc: linux-kernel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Maxime Coquelin <maxime.coquelin@redhat.com>, kvm@vger.kernel.org,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
	Marty McFadden <mcfadden8@llnl.gov>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
	linux-fsdevel@vger.kernel.org,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-api@vger.kernel.org
Subject: Re: [PATCH 0/3] userfaultfd: allow to forbid unprivileged users
Message-ID: <20190312074951.i2md3npcjcceywqj@kshutemo-mobl1>
References: <20190311093701.15734-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311093701.15734-1-peterx@redhat.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 05:36:58PM +0800, Peter Xu wrote:
> Hi,
> 
> (The idea comes from Andrea, and following discussions with Mike and
>  other people)
> 
> This patchset introduces a new sysctl flag to allow the admin to
> forbid users from using userfaultfd:
> 
>   $ cat /proc/sys/vm/unprivileged_userfaultfd
>   [disabled] enabled kvm

CC linux-api@

This is unusual way to return current value for sysctl. Does it work fine
with sysctl tool?

Have you considered to place the switch into /sys/kernel/mm instead?
I doubt it's the last tunable for userfaultfd. Maybe we should have an
directory for it under /sys/kernel/mm?

>   - When set to "disabled", all unprivileged users are forbidden to
>     use userfaultfd syscalls.
> 
>   - When set to "enabled", all users are allowed to use userfaultfd
>     syscalls.
> 
>   - When set to "kvm", all unprivileged users are forbidden to use the
>     userfaultfd syscalls, except the user who has permission to open
>     /dev/kvm.
> 
> This new flag can add one more layer of security to reduce the attack
> surface of the kernel by abusing userfaultfd.  Here we grant the
> thread userfaultfd permission by checking against CAP_SYS_PTRACE
> capability.  By default, the value is "disabled" which is the most
> strict policy.  Distributions can have their own perferred value.
> 
> The "kvm" entry is a bit special here only to make sure that existing
> users like QEMU/KVM won't break by this newly introduced flag.  What
> we need to do is simply set the "unprivileged_userfaultfd" flag to
> "kvm" here to automatically grant userfaultfd permission for processes
> like QEMU/KVM without extra code to tweak these flags in the admin
> code.
> 
> Patch 1:  The interface patch to introduce the flag
> 
> Patch 2:  The KVM related changes to detect opening of /dev/kvm
> 
> Patch 3:  Apply the flag to userfaultfd syscalls
> 
> All comments would be greatly welcomed.  Thanks,
> 
> Peter Xu (3):
>   userfaultfd/sysctl: introduce unprivileged_userfaultfd
>   kvm/mm: introduce MMF_USERFAULTFD_ALLOW flag
>   userfaultfd: apply unprivileged_userfaultfd check
> 
>  fs/userfaultfd.c               | 121 +++++++++++++++++++++++++++++++++
>  include/linux/sched/coredump.h |   1 +
>  include/linux/userfaultfd_k.h  |   5 ++
>  init/Kconfig                   |  11 +++
>  kernel/sysctl.c                |  11 +++
>  virt/kvm/kvm_main.c            |   7 ++
>  6 files changed, 156 insertions(+)
> 
> -- 
> 2.17.1
> 

-- 
 Kirill A. Shutemov

