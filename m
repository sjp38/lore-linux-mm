Return-Path: <SRS0=9gyo=QA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4584C282C3
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 21:57:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92D1F218D2
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 21:57:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="R4gv/Kq8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92D1F218D2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A1408E0084; Thu, 24 Jan 2019 16:57:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 150428E0082; Thu, 24 Jan 2019 16:57:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0402D8E0084; Thu, 24 Jan 2019 16:57:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF6F88E0082
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 16:57:11 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id n201so1759143ybg.9
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 13:57:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language:dkim-signature;
        bh=naFzZHExRS53DU+o6GCwc37LudjoqgRPZlmh7umATB0=;
        b=VgocXOVCUdmYUUsX13OGHYcyRw8HxLutfurLE7tgUg5N2K2Vk4UUVGfYZsY1to8oYV
         +Qiudc7pgyvqwbHVUvlFBYwXOfUx/QQL0e+cezrrEE2D05WHswov0o+qFtrPOLeQZJw1
         943fiRVXg6GJEgxxI65X24KqTe32miTYAf1ZkroSuz0D1yIDpOKViTZraF8xWjsLIDmX
         bZ7PV62Nyh7LSrmkBJIectAImAJhqQD6CGH30gc4mRwfzyxLWxC5moCHSYaKBwwhW+QQ
         U+tB6mNreP5ri3eBJIQ4bhGm5YtzeBvdvitakNt2yT91XCbMnpN3aSmJgtTcBfYMtuCb
         HnBA==
X-Gm-Message-State: AJcUukemxKdrmmg6hRYbNEvv+MWaZeBgMHH9z+zh4PwVvNeSOrBzpCd1
	Ph2MuVe/WTUaADMZZX06lM1oXLnRELzIqR3gSGPheasKvS+Cl0U6RkuI93HuqVFxxWBVv8fHPlB
	cUhgYdYTnxhchajkNSpPu3ZHWI0I8VT5tkmCnw+V/IoSyenqmGwHvu1IWuGvMrM8S/A==
X-Received: by 2002:a25:9a81:: with SMTP id s1mr8208366ybo.358.1548367031545;
        Thu, 24 Jan 2019 13:57:11 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5wUbUK+qNaaOtwpFnpIYupp6cBFNGmFEzGY4KD97B+TVO49ET55eOejhHdmLj1a8mkFfCx
X-Received: by 2002:a25:9a81:: with SMTP id s1mr8208318ybo.358.1548367030358;
        Thu, 24 Jan 2019 13:57:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548367030; cv=none;
        d=google.com; s=arc-20160816;
        b=pvF3lC3cRzcfYXKeEnrvSCYnqjnVj+hZponkFj+Nl6RUeZvjQGkIH6ROh9AqTbPsQa
         h9TiKJAFT/fZDspxdZmKNFriDuodPRCNOXqtjYL0Y3nCXEsOYNoviiUlvZ04SLOEIIYR
         aQ2RulEww9ko6lHl+XQmTkhbK2jXDboCpHUe8iOBtlCB1pw8gztaGwr4gk1f51OCdpaf
         J8Nf6FTeJKJARg/fFDvF1Kyfol2rKJubLmE8gkhJfrdz80QhouqKHQmoDI99x5BKhACU
         90lZVIKbhsBst5zhY5JoE/affqbfeV15AOM4BTfOhwndyIWU9r32v97UNFiJMYicJfdd
         wrrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-language:content-transfer-encoding
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=naFzZHExRS53DU+o6GCwc37LudjoqgRPZlmh7umATB0=;
        b=Z4+dPkeBggiYFEAbKPIHnUytenwoO1uqGP4/mCOVbxIHf4MvyFngLVPu52NkjOozaH
         8KlLBY3HdWUeu2QTmvPgOiutREK39aIdsFLirwT8MvbsWR8pP6//GaJq3qOAEgcbpOjc
         o8VHOSohDuRzP+oyA3lf0o6bjUwL1NB/P+LCHw1Tj/Qk5IE71ljjUMJuks4vN8BPdiyh
         hsXMBS/Kax7Vlm2mI0tHiZLKzemjcAmZFF13OhEGUSO9CaVlfXb2YepXX7+09XjNq0D3
         0TmLF5ezWC8VGPV7yy1ezD3Xtv21zJKCwIrXW0PC0RD70odvCsZpNoQIIxodvQC9jAB+
         NRIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="R4gv/Kq8";
       spf=pass (google.com: domain of prpatel@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=prpatel@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 127si13291498ybq.85.2019.01.24.13.57.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 13:57:10 -0800 (PST)
Received-SPF: pass (google.com: domain of prpatel@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="R4gv/Kq8";
       spf=pass (google.com: domain of prpatel@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=prpatel@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c4a34a30001>; Thu, 24 Jan 2019 13:56:51 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 24 Jan 2019 13:57:09 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 24 Jan 2019 13:57:09 -0800
Received: from [10.24.242.22] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Thu, 24 Jan
 2019 21:57:05 +0000
Subject: Re: [PATCH] selinux: avc: mark avc node as not a leak
To: Catalin Marinas <catalin.marinas@arm.com>
CC: <paul@paul-moore.com>, <sds@tycho.nsa.gov>, <eparis@parisplace.org>,
	<linux-kernel@vger.kernel.org>, <selinux@vger.kernel.org>,
	<linux-tegra@vger.kernel.org>, <talho@nvidia.com>, <swarren@nvidia.com>,
	<linux-mm@kvack.org>, <snikam@nvidia.com>, <vdumpa@nvidia.com>
References: <1547023162-6381-1-git-send-email-prpatel@nvidia.com>
 <20190109113126.nzpmb7xx4xqtn37w@mbp>
From: Prateek Patel <prpatel@nvidia.com>
Message-ID: <75b75170-9316-9f7a-13a6-5f2b92b35bb2@nvidia.com>
Date: Fri, 25 Jan 2019 03:26:54 +0530
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190109113126.nzpmb7xx4xqtn37w@mbp>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="UTF-8"; format="flowed"
Content-Transfer-Encoding: quoted-printable
Content-Language: en-GB
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1548367011; bh=naFzZHExRS53DU+o6GCwc37LudjoqgRPZlmh7umATB0=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Transfer-Encoding:
	 Content-Language;
	b=R4gv/Kq8AThjTn+PBmNgX+U8dQa8APWv0UvDO+vJtLVyTmMMq0E+LVHFgeFlAXamb
	 zkcgxBEAdBNj9mns/tooYz6dUpNdyQuzB6tS2MGbgE5TBZlzjTtrpNCGvpfsAo0oRb
	 +HBcLRpCVdy7cdO+sTM6uFygZXAT/yUgbWFFKEBBDdAoLHyJ1c6zZeAWFnByooTXLd
	 QigZNy9igY9oZ1USBWq6Xpvv/jY7O49rLkQWN8V1t1n6vqUMxr89Jjk8PIaEtoopof
	 EmVKwuY9VfomNsHqIL4gVSHgkoZHLKM07hDJYyM1hEwDxE8W962yAedyx/7seLlnHM
	 uBeyNfdm9e3xg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190124215654.m9zY7hN4Y3yxQSZQyI9m7QQOhptrx7oGhAPoRrAbtBg@z>


On 1/9/2019 5:01 PM, Catalin Marinas wrote:
> Hi Prateek,
>
> On Wed, Jan 09, 2019 at 02:09:22PM +0530, Prateek Patel wrote:
>> From: Sri Krishna chowdary <schowdary@nvidia.com>
>>
>> kmemleak detects allocated objects as leaks if not accessed for
>> default scan time. The memory allocated using avc_alloc_node
>> is freed using rcu mechanism when nodes are reclaimed or on
>> avc_flush. So, there is no real leak here and kmemleak_scan
>> detects it as a leak which is false positive. Hence, mark it as
>> kmemleak_not_leak.
> In theory, kmemleak should detect the node->rhead in the lists used by
> call_rcu() and not report it as a leak. Which RCU options do you have
> enabled (just to check whether kmemleak tracks the RCU internal lists)?
>
> Also, does this leak eventually disappear without your patch? Does
>
>    echo dump=3D0xffffffc0dd1a0e60 > /sys/kernel/debug/kmemleak
>
> still display this object?
>
> Thanks.
Hi Catalin,
It was intermittently showing leak and didn't repro on multiple runs. To=20
repo, I decreased the
minimum object age for reporting, I found triggering the second scan=20
just after first is not showing
any leak. Also, without my patch, on echo dump, obj is not displaying.
Is increasing minimum object age for reporting a good idea to handle=20
such type of issues to
avoid false-positives?

Following is the log:

t186_int:/ # echo scan > /sys/kernel/debug/kmemleak
t186_int:/ # cat /sys/kernel/debug/kmemleak

unreferenced object 0xffffffc1e06424c8 (size 72):
 =C2=A0 comm "netd", pid 4891, jiffies 4294906431 (age 23.120s)
 =C2=A0 hex dump (first 32 bytes):
 =C2=A0=C2=A0=C2=A0 97 01 00 00 1b 00 00 00 0b 00 00 00 57 06 04 00 .......=
.....W...
 =C2=A0=C2=A0=C2=A0 00 00 00 00 ff ff ff ff 01 00 00 00 00 00 00 00 .......=
.........
 =C2=A0 backtrace:
 =C2=A0=C2=A0=C2=A0 [<ffffff8008275214>] kmem_cache_alloc+0x1ac/0x2c0
 =C2=A0=C2=A0=C2=A0 [<ffffff80084dcf90>] avc_alloc_node+0x28/0x240
 =C2=A0=C2=A0=C2=A0 [<ffffff80084dd404>] avc_compute_av+0xa4/0x1d0
 =C2=A0=C2=A0=C2=A0 [<ffffff80084de1b8>] avc_has_perm+0xf8/0x1b8
 =C2=A0=C2=A0=C2=A0 [<ffffff80084e37f8>] file_has_perm+0xb8/0xe8
 =C2=A0=C2=A0=C2=A0 [<ffffff80084e3d64>] match_file+0x44/0x98
 =C2=A0=C2=A0=C2=A0 [<ffffff80082cc9d4>] iterate_fd+0x84/0xd0
 =C2=A0=C2=A0=C2=A0 [<ffffff80084e2b3c>] selinux_bprm_committing_creds+0xec=
/0x230
 =C2=A0=C2=A0=C2=A0 [<ffffff80084d842c>] security_bprm_committing_creds+0x4=
4/0x60
 =C2=A0=C2=A0=C2=A0 [<ffffff80082ad020>] install_exec_creds+0x20/0x70
 =C2=A0=C2=A0=C2=A0 [<ffffff800831b9a4>] load_elf_binary+0x31c/0xd10
 =C2=A0=C2=A0=C2=A0 [<ffffff80082ae530>] search_binary_handler+0x98/0x288
 =C2=A0=C2=A0=C2=A0 [<ffffff80082af078>] do_execveat_common.isra.14+0x550/0=
x6d0
 =C2=A0=C2=A0=C2=A0 [<ffffff80082af4ac>] SyS_execve+0x4c/0x60
 =C2=A0=C2=A0=C2=A0 [<ffffff80080839c0>] el0_svc_naked+0x34/0x38
 =C2=A0=C2=A0=C2=A0 [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffffffc1ab3c61b0 (size 72):
 =C2=A0 comm "crash_dump64", pid 5058, jiffies 4294907834 (age 17.508s)
 =C2=A0 hex dump (first 32 bytes):
 =C2=A0=C2=A0=C2=A0 2f 02 00 00 6b 00 00 00 07 00 00 00 53 04 04 00 /...k..=
.....S...
 =C2=A0=C2=A0=C2=A0 00 00 00 00 ff ff fd ff 01 00 00 00 00 00 00 00 .......=
.........
 =C2=A0 backtrace:
 =C2=A0=C2=A0=C2=A0 [<ffffff8008275214>] kmem_cache_alloc+0x1ac/0x2c0
 =C2=A0=C2=A0=C2=A0 [<ffffff80084dcf90>] avc_alloc_node+0x28/0x240
 =C2=A0=C2=A0=C2=A0 [<ffffff80084dd404>] avc_compute_av+0xa4/0x1d0
 =C2=A0=C2=A0=C2=A0 [<ffffff80084de084>] avc_has_perm_noaudit+0xe4/0x120
 =C2=A0=C2=A0=C2=A0 [<ffffff80084e1264>] selinux_inode_permission+0xc4/0x1c=
8
 =C2=A0=C2=A0=C2=A0 [<ffffff80084d8fe8>] security_inode_permission+0x60/0x8=
8
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b2cf4>] __inode_permission2+0x54/0x120
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b2e30>] inode_permission2+0x38/0x80
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b4b58>] may_open+0x70/0x128
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b6fd4>] do_last+0x234/0xee8
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b7d30>] path_openat+0xa8/0x310
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b9390>] do_filp_open+0x88/0x108
 =C2=A0=C2=A0=C2=A0 [<ffffff80082a1fec>] do_sys_open+0x1a4/0x290
 =C2=A0=C2=A0=C2=A0 [<ffffff80082a215c>] SyS_openat+0x3c/0x50
 =C2=A0=C2=A0=C2=A0 [<ffffff80080839c0>] el0_svc_naked+0x34/0x38
 =C2=A0=C2=A0=C2=A0 [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffffffc1d3bcf678 (size 72):
 =C2=A0 comm "mediaserver", pid 5156, jiffies 4294909577 (age 10.536s)
 =C2=A0 hex dump (first 32 bytes):
 =C2=A0=C2=A0=C2=A0 0b 02 00 00 e2 01 00 00 07 00 00 00 53 04 04 00 .......=
.....S...
 =C2=A0=C2=A0=C2=A0 00 00 00 00 f7 ff ff ff 01 00 00 00 00 00 00 00 .......=
.........
 =C2=A0 backtrace:
 =C2=A0=C2=A0=C2=A0 [<ffffff8008275214>] kmem_cache_alloc+0x1ac/0x2c0
 =C2=A0=C2=A0=C2=A0 [<ffffff80084dcf90>] avc_alloc_node+0x28/0x240
 =C2=A0=C2=A0=C2=A0 [<ffffff80084dd404>] avc_compute_av+0xa4/0x1d0
 =C2=A0=C2=A0=C2=A0 [<ffffff80084de084>] avc_has_perm_noaudit+0xe4/0x120
 =C2=A0=C2=A0=C2=A0 [<ffffff80084e1264>] selinux_inode_permission+0xc4/0x1c=
8
 =C2=A0=C2=A0=C2=A0 [<ffffff80084d8fe8>] security_inode_permission+0x60/0x8=
8
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b2cf4>] __inode_permission2+0x54/0x120
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b2e30>] inode_permission2+0x38/0x80
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b4b58>] may_open+0x70/0x128
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b6fd4>] do_last+0x234/0xee8
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b7d30>] path_openat+0xa8/0x310
 =C2=A0=C2=A0=C2=A0 [<ffffff80082b9390>] do_filp_open+0x88/0x108
 =C2=A0=C2=A0=C2=A0 [<ffffff80082a1fec>] do_sys_open+0x1a4/0x290
 =C2=A0=C2=A0=C2=A0 [<ffffff80082a21f4>] compat_SyS_openat+0x3c/0x50
 =C2=A0=C2=A0=C2=A0 [<ffffff80080839c0>] el0_svc_naked+0x34/0x38
 =C2=A0=C2=A0=C2=A0 [<ffffffffffffffff>] 0xffffffffffffffff
t186_int:/ # echo dump=3D0xffffffc1d3bcf678 > /sys/kernel/debug/kmemleak
kmemleak: Unknown object at 0xffffffc1d3bcf678

Thanks,

