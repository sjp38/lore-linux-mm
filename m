Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB776C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:55:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FAE12084D
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:55:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Zf/du4Xd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FAE12084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBB1A6B026B; Thu, 13 Jun 2019 06:55:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E45886B026C; Thu, 13 Jun 2019 06:55:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE6566B0270; Thu, 13 Jun 2019 06:55:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id A94B36B026B
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 06:55:04 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id s83so14587733iod.13
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 03:55:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=wgp7cj5gIWhGNVKXNvU3r2tQN8cWgiUhKrlM8F56c+g=;
        b=st/Tnwuj2zuvPBsl/AI9Zrq+NCKxylZKDPtKu0wfzD9t/vQWYK3wvaON8uOgmnTLyk
         enQZ02qexrb4zrmh1XEaBFEzlc4SDJWhsQPMT/p76BAJKkUaB9rYvl9aGFoVynNfvp4h
         2Rj2cHavrAbiEYDDOyBxS+zOffEXUI2b6shOOtq4YnqnT23AoTALbAqCC4HPU9nwLyvi
         OhydE8L1Mpb6CkeIeE1QfV2M0qiAO+41DD6YHlKMWPhEOlkE04l37cky79tNbyJwTosv
         mZWkUL+kJCJlLCxITF1ZhmMn2qDLk9hD6kZH0lqe9uY3tAlPs19UEFPHzSEYWCtk53XS
         5qUQ==
X-Gm-Message-State: APjAAAWjHDzM3x/GWoNnCA2gPz3pwQcDoF99pehXJOFGJ4kywcd/y/QD
	xuSciQL7RbctEWDb9ZTP3xOUXbjVV50f9DhNfXOwAPmrY3Nxw0RVJ/HjOCIy11Rhu0eEh8hAYtV
	BuYhz4J8uLmnOMSrM3WAT5CsM1QliGJBi6ghw1+d7ASOXbXVh5jRYzBHQR8dFssAEvQ==
X-Received: by 2002:a5e:c302:: with SMTP id a2mr9623057iok.62.1560423304375;
        Thu, 13 Jun 2019 03:55:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyxheK/WoxLZkQljJo0NFOkNRohxdUYtg83uplYr4BRkPlzna46zdmch10vFscIIeQrQ15r
X-Received: by 2002:a5e:c302:: with SMTP id a2mr9622971iok.62.1560423302879;
        Thu, 13 Jun 2019 03:55:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560423302; cv=none;
        d=google.com; s=arc-20160816;
        b=r9zrA2G7tyUE7L2E0QMUW5xoBaibDn2BqBNbJDefWHAZQuKXgWcTYJQSkykSWcCulJ
         70UlhS7P6Z9xA1wzPZsyZMX9/2AvpSguOlhNsXzC9//34UU7WRbID5jmqdoBrbwnBLln
         +/aX0i88AM1XJK7BhnurEz2agykNtBK2HesKQEI8RTF6wz6O3JVMcmkLWbdFiFkT2XFA
         ouZxwaikQbyN9itjPRJQQHWq8EwSAF4vcKcQO8WE4ISpiuHbq3b3FnT0k4qX20JdqfrF
         u4rwQn5C5y3aKwxe67slkM2a0+a7hsRSBvO8aJpyKM58zPoDgnPPCOVJug7KJLSrOV/g
         riUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=wgp7cj5gIWhGNVKXNvU3r2tQN8cWgiUhKrlM8F56c+g=;
        b=t0JtzSTbGZ5B79mLC/j0tpRO1Um65TGBOcXSJfgawtqKIrC0GaOyHmbwqCOYVBM0Jk
         qZ1PtzGlje5OIaP90eZp6ujOt4s0529L6M04DCpiqqdm5mdYV4gWPoIssEvSLNE+J8tg
         QuAIVq8+ye8vigeTXNKiPIKLacf6wBYOYQy5lhPCKprWR/QSDj61/4aqAT/ci6bGnL6y
         M7RYyumdgVxB7Jjtlu8ia9BCNlsG+F4T503xCLsFIcy9f3X/o0K0IN0XGN+RK3o7gxKW
         W+HXweabdRTDA6P1aE89uaEjCoGj/t12Qj5+P2obUQYqc6KN2clya7L0BArdZ9qxHgkr
         aqJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="Zf/du4Xd";
       spf=pass (google.com: domain of liran.alon@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=liran.alon@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id o6si2200433jan.49.2019.06.13.03.55.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 03:55:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of liran.alon@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="Zf/du4Xd";
       spf=pass (google.com: domain of liran.alon@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=liran.alon@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5DAnOoB071082;
	Thu, 13 Jun 2019 10:54:59 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=wgp7cj5gIWhGNVKXNvU3r2tQN8cWgiUhKrlM8F56c+g=;
 b=Zf/du4Xdcj4gMvx8OhplpKEfYVBLca2/955+Ow9J7w7ql/yYy+w7xZL8YUNzcyB2mvEK
 7pDp4e9JVNj16ftv9sNC1+v+RRS5y2uGhXKU7cyUyMULXuVwIBPUFsq9Y9L5vqZF5SCm
 x6WS7uorSc7OpBdGEfDcTifKJKIYNkLQXE69y2Ic0ilg5X2/28VKDvPJH6e1DqmRjFwL
 dl4E6pn6m0n6cQ6PhamH/Ocao65dEVuH/VcchqJUDjJyrRvbtmErBOzQs7QtIpx5zTf/
 cmkGRaoFrSbmrlEvXpmyzWThl0y8+EIgb6HjpBiCMzTkOYX3uNVRGGEimLeW9iDcecMw kA== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2120.oracle.com with ESMTP id 2t04ynrnpv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 13 Jun 2019 10:54:59 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5DAss25021565;
	Thu, 13 Jun 2019 10:54:59 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2t1jpjg18a-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 13 Jun 2019 10:54:58 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5DAsu5Y024439;
	Thu, 13 Jun 2019 10:54:56 GMT
Received: from [192.168.14.112] (/79.177.239.28)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 13 Jun 2019 03:54:56 -0700
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.1 \(3445.4.7\))
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
From: Liran Alon <liran.alon@oracle.com>
In-Reply-To: <20190612182550.GI20308@linux.intel.com>
Date: Thu, 13 Jun 2019 13:54:51 +0300
Cc: Marius Hillenbrand <mhillenb@amazon.de>, kvm@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com,
        linux-mm@kvack.org, Alexander Graf <graf@amazon.de>,
        David Woodhouse <dwmw@amazon.co.uk>
Content-Transfer-Encoding: quoted-printable
Message-Id: <65D4DBEB-5A9A-457D-909B-2D31A3031607@oracle.com>
References: <20190612170834.14855-1-mhillenb@amazon.de>
 <20190612182550.GI20308@linux.intel.com>
To: Sean Christopherson <sean.j.christopherson@intel.com>
X-Mailer: Apple Mail (2.3445.4.7)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9286 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=707
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906130085
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9286 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=756 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906130085
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On 12 Jun 2019, at 21:25, Sean Christopherson =
<sean.j.christopherson@intel.com> wrote:
>=20
> On Wed, Jun 12, 2019 at 07:08:24PM +0200, Marius Hillenbrand wrote:
>> The Linux kernel has a global address space that is the same for any
>> kernel code. This address space becomes a liability in a world with
>> processor information leak vulnerabilities, such as L1TF. With the =
right
>> cache load gadget, an attacker-controlled hyperthread pair can leak
>> arbitrary data via L1TF. Disabling hyperthreading is one recommended
>> mitigation, but it comes with a large performance hit for a wide =
range
>> of workloads.
>>=20
>> An alternative mitigation is to not make certain data in the kernel
>> globally visible, but only when the kernel executes in the context of
>> the process where this data belongs to.
>>=20
>> This patch series proposes to introduce a region for what we call
>> process-local memory into the kernel's virtual address space. Page
>> tables and mappings in that region will be exclusive to one address
>> space, instead of implicitly shared between all kernel address =
spaces.
>> Any data placed in that region will be out of reach of cache load
>> gadgets that execute in different address spaces. To implement
>> process-local memory, we introduce a new interface =
kmalloc_proclocal() /
>> kfree_proclocal() that allocates and maps pages exclusively into the
>> current kernel address space. As a first use case, we move =
architectural
>> state of guest CPUs in KVM out of reach of other kernel address =
spaces.
>=20
> Can you briefly describe what types of attacks this is intended to
> mitigate?  E.g. guest-guest, userspace-guest, etc...  I don't want to
> make comments based on my potentially bad assumptions.

I think I can assist in the explanation.

Consider the following scenario:
1) Hyperthread A in CPU core runs in guest and triggers a VMExit which =
is handled by host kernel.
While hyperthread A runs VMExit handler, it populates CPU core cache / =
internal-resources (e.g. MDS buffers)
with some sensitive data it have speculatively/architecturally access.
2) During hyperthread A running on host kernel, hyperthread B on same =
CPU core runs in guest and use
some CPU speculative execution vulnerability to leak the sensitive host =
data populated by hyperthread A
in CPU core cache / internal-resources.

Current CPU microcode mitigations (L1D/MDS flush) only handle the case =
of a single hyperthread and don=E2=80=99t
provide a mechanism to mitigate this hyperthreading attack scenario.

Assuming there is some guest triggerable speculative load gadget in some =
VMExit path,
it can be used to force any data that is mapped into kernel address =
space to be loaded into CPU resource that is subject to leak.
Therefore, there were multiple attempts to reduce sensitive information =
from being mapped into the kernel address space
that is accessible by this VMExit path.

One attempt was XPFO which attempts to remove from kernel direct-map any =
page that is currently used only by userspace.
Unfortunately, XPFO currently exhibits multiple performance issues that =
*currently* makes it impractical as far as I know.

Another attempt is this patch-series which attempts to remove from one =
vCPU thread host kernel address space,
the state of vCPUs of other guests. Which is very specific but I =
personally have additional ideas on how this patch series can be further =
used.
For example, vhost-net needs to kmap entire guest memory into =
kernel-space to write ingress packets data into guest memory.
Thus, vCPU thread kernel address space now maps entire other guest =
memory which can be leaked using the technique described above.
Therefore, it should be useful to also move this kmap() to happen on =
process-local kernel virtual address region.

One could argue however that there is still a much bigger issue because =
of kernel direct-map that maps all physical pages that kernel
manage (i.e. have struct page) in kernel virtual address space. And all =
of those pages can theoretically be leaked.
However, this could be handled by complementary techniques such as =
booting host kernel with =E2=80=9Cmem=3DX=E2=80=9D and mapping guest =
memory
by directly mmap relevant portion of /dev/mem.
Which is probably what AWS does given these upstream KVM patches they =
have contributed:
bd53cb35a3e9 X86/KVM: Handle PFNs outside of kernel reach when touching =
GPTEs
e45adf665a53 KVM: Introduce a new guest mapping API
0c55671f84ff kvm, x86: Properly check whether a pfn is an MMIO or not

Also note that when using such =E2=80=9Cmem=3DX=E2=80=9D technique, you =
can also avoid performance penalties introduced by CPU microcode =
mitigations.
E.g. You can avoid doing L1D flush on VMEntry if VMExit handler run only =
in kernel and didn=E2=80=99t context-switch as you assume kernel address
space don=E2=80=99t map any host sensitive data.

It=E2=80=99s also worth mentioning that another alternative that I have =
attempted to this =E2=80=9Cmem=3DX=E2=80=9D technique
was to create an isolated address space that is only used when running =
KVM VMExit handlers.
For more information, refer to:
https://lkml.org/lkml/2019/5/13/515
(See some of my comments on that thread)

This is my 2cents on this at least.

-Liran


