Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36135C04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 21:42:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B59BD2070D
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 21:42:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="FEdwacA3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B59BD2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EBC16B0005; Thu, 16 May 2019 17:42:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29C756B0006; Thu, 16 May 2019 17:42:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1631A6B0007; Thu, 16 May 2019 17:42:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id E884E6B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 17:42:49 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id u10so4622379itb.5
        for <linux-mm@kvack.org>; Thu, 16 May 2019 14:42:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=nLETqqMNckwgOQaTIvkZ+E5+zN8Owy6XgRXHqWLpflI=;
        b=IebjHJklSD4hFoH6Fw0oLwQ49HPXIUMEbJ+Ruyzs0GeTkUDlZE0a0ghk2DXW6Fu7ma
         ZhHC+UOzigoroE1MnLHfsB7DURc6gnNP9hTRTB2K1nOQ7IUvA+wYWqpRREy+vw/CPKHs
         mQKnvz3t5c2+tFdlNrIBtmOFH/pgbauISuKHkuCcrrvDxMmP+mVY8UqfzyDFNXggNLpG
         Y/ACq0Qalf0kaSygCevYQx8Nu2cFpH2wHxVrqPZvH0CsH92B44zw9HlXEKLKUxmPkDGo
         6ltu4k/GCBblYTNQtAAvcCnv2Y+YpLxIXb9cRwFKgHqyE8r3Vkr130+kBUeG/yWTFiT5
         9nug==
X-Gm-Message-State: APjAAAWQGrbSEhZn/gAlsyBNGyLQ+rHv20XCL5/g6mGVbz2a1CcOLGcd
	cYiAtQ8/VRkAiGnRctPux4hvpdbIV4fcomuVkVaVPvx7DIBVCqoOxfbuqGn84oql1ZCLVTrmpgf
	B2pF2+S71t2iTcAjjZ+A+xAL8377598t80ro+RhuFXGss/MDZVM7fJVTC2XnN9Zo4Og==
X-Received: by 2002:a6b:cf0f:: with SMTP id o15mr30183908ioa.5.1558042969680;
        Thu, 16 May 2019 14:42:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrnySWsBIHcV7eqqPt962xYQyhWorVzIeQPfbt5rQRp8OkVFhSkIyatZ06pZdRZO83n2mT
X-Received: by 2002:a6b:cf0f:: with SMTP id o15mr30183856ioa.5.1558042968514;
        Thu, 16 May 2019 14:42:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558042968; cv=none;
        d=google.com; s=arc-20160816;
        b=s0waerSm4CgpYvRcVcdE6ORJP4GKqAg5EIyTuXkNG3AMrrGtI1BMy6RM9YN8m4X+0C
         6SMVXdj+K5NYmRzCNRulKqfCETkWOxwPoy53nx2ZQSfLggVhJ9AAHuecaQUPl2fg6+Et
         3G0QkMQKXyJtXAzqjmi90Y6xQkg0PgHtMw60UcOye4YNsWNwYHle0vvnpWuJtry1uC+R
         L51gbXm+iKQVJ/Tdg1YcGd9MDZy2wQMKo2Vzt/ad/x16GR78ewzH8ER+pK0XuhKwFJVH
         xWWH6Fp9NiNEiPZU4Mrv5Mq0m7UgTI0dvefhizEjNFFOgwkhEVV9XHWHBa/f+7DQAapR
         r1vQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:references:cc:to:from
         :subject:dkim-signature;
        bh=nLETqqMNckwgOQaTIvkZ+E5+zN8Owy6XgRXHqWLpflI=;
        b=vWANBDA0BUC4Oz6mcohUliF2NDK5GZGBC3oLpOAMi7vE5a6pyPSeqissBnHkywLM18
         VcWxUYEX68JsjC9UY09wgf0u397UZxhg4YEVOH5lW9Cyd8h3sSzQi5RFKPZU517QeVLG
         z3KicuTl9/iclHwh20jkfZuXoYdz4n7jRyLh0/929XgNo8avaa5WR4Z24kKvbCrYN23R
         73r2fOvj1uTfMam4PNHpRN/d21NkH/TLB5/u2EEopu9LfaKY9j+AeKFVjhVW87bNfY59
         kI1Vwk9sJbFvtgouiz/uvq8ZkDRufxuO7+s7K8U8dWOJEaUr73QZ4wCXV6UfkSkx7PSP
         Vk+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=FEdwacA3;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id k202si4369841itk.79.2019.05.16.14.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 14:42:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=FEdwacA3;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4GLO7LI092142;
	Thu, 16 May 2019 21:42:42 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : references : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=nLETqqMNckwgOQaTIvkZ+E5+zN8Owy6XgRXHqWLpflI=;
 b=FEdwacA3lcmAtwtPf3l6CqkGy9vb3R7d37Q3Lh8/W6/QZP+q10761Abeh8Et36dzDQIe
 b2pR0syIiQs0B4hxC2YUPZB7a3h/yHo8XkMEQHoxD62Mm3nsSQVEwcg1HPOz4cX//COp
 NtZ3LXcsGjuAmHL2vyyNayjnQXjonyR9ARirMAPWueFm1tZJenqKUp1CJFk6Fm/mCOIm
 afZnfHtpoeBJzxDUN4dBEeKvRNTJ9kZuj0VgETiF/Ly0b1V9qpmMKZDkWc37UQMUYaH+
 jKFVWsE6EmrakBvrPo5oNBdTz90O8VT6blxKU0eufLnnlON3iOSpyfwf3iD/ycTkNKNH FQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2sdntu6916-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 16 May 2019 21:42:42 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4GLgfiS146307;
	Thu, 16 May 2019 21:42:41 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2sgp338fd2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 16 May 2019 21:42:41 +0000
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4GLgUaO027241;
	Thu, 16 May 2019 21:42:30 GMT
Received: from [10.132.93.219] (/10.132.93.219)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 16 May 2019 14:42:29 -0700
Subject: Re: [PATCH v2 0/6] mm/devm_memremap_pages: Fix page release race
From: jane.chu@oracle.com
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-nvdimm <linux-nvdimm@lists.01.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux MM <linux-mm@kvack.org>,
        =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Christoph Hellwig <hch@lst.de>
References: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
 <059859ca-3cc8-e3ff-f797-1b386931c41e@deltatee.com>
 <17ada515-f488-d153-90ef-7a5cc5fefb0f@deltatee.com>
 <8a7cfa6b-6312-e8e5-9314-954496d2f6ce@oracle.com>
 <CAPcyv4i28tQMVrscQo31cfu1ZcMAb74iMkKYhu9iO_BjJvp+9A@mail.gmail.com>
 <6bd8319d-3b73-bb1e-5f41-94c580ba271b@oracle.com>
 <d699e312-0e88-30c7-8e50-ff624418d486@oracle.com>
Organization: Oracle Corporation
Message-ID: <6d1a4be1-bfaa-103c-770a-3055d76d6346@oracle.com>
Date: Thu, 16 May 2019 14:42:28 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <d699e312-0e88-30c7-8e50-ff624418d486@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9259 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905160131
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9259 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905160130
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Apology for resending in plain text.
-jane

On 5/16/19 9:45 AM, Jane Chu wrote:
> Hi,
> 
> I'm able to reproduce the panic below by running two sets of ndctl
> commands that actually serve legitimate purpose in parallel (unlike
> the brute force experiment earlier), each set in a indefinite loop.
> This time it takes about an hour to panic.  But I gather the cause
> is probably the same: I've overlapped ndctl commands on the same
> region.
> 
> Could we add a check in nd_ioctl(), such that if there is
> an ongoing ndctl command on a region, subsequent ndctl request
> will fail immediately with something to the effect of EAGAIN?
> The rationale being that kernel should protect itself against
> user mistakes.
> 
> Also, sensing the subject fix is for a different problem, and has been
> verified, I'm happy to see it in upstream, so we have a better
> code base to digger deeper in terms of how the destructive ndctl
> commands interacts to typical mission critical applications, include
> but not limited to rdma.
> 
> thanks,
> -jane
> 
> On 5/14/2019 2:18 PM, Jane Chu wrote:
>> On 5/14/2019 12:04 PM, Dan Williams wrote:
>>
>>> On Tue, May 14, 2019 at 11:53 AM Jane Chu <jane.chu@oracle.com> wrote:
>>>> On 5/13/2019 12:22 PM, Logan Gunthorpe wrote:
>>>>
>>>> On 2019-05-08 11:05 a.m., Logan Gunthorpe wrote:
>>>>
>>>> On 2019-05-07 5:55 p.m., Dan Williams wrote:
>>>>
>>>> Changes since v1 [1]:
>>>> - Fix a NULL-pointer deref crash in pci_p2pdma_release() (Logan)
>>>>
>>>> - Refresh the p2pdma patch headers to match the format of other p2pdma
>>>>     patches (Bjorn)
>>>>
>>>> - Collect Ira's reviewed-by
>>>>
>>>> [1]: 
>>>> https://lore.kernel.org/lkml/155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com/ 
>>>>
>>>>
>>>> This series looks good to me:
>>>>
>>>> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
>>>>
>>>> However, I haven't tested it yet but I intend to later this week.
>>>>
>>>> I've tested libnvdimm-pending which includes this series on my setup 
>>>> and
>>>> everything works great.
>>>>
>>>> Just wondering in a difference scenario where pmem pages are 
>>>> exported to
>>>> a KVM guest, and then by mistake the user issues "ndctl 
>>>> destroy-namespace -f",
>>>> will the kernel wait indefinitely until the user figures out to kill 
>>>> the guest
>>>> and release the pmem pages?
>>> It depends on whether the pages are pinned. Typically DAX memory
>>> mappings assigned to a guest are not pinned in the host and can be
>>> invalidated at any time. The pinning only occurs with VFIO and
>>> device-assignment which isn't the common case, especially since that
>>> configuration is blocked by fsdax. However, with devdax, yes you can
>>> arrange for the system to go into an indefinite wait.
>>>
>>> This somewhat ties back to the get_user_pages() vs DAX debate. The
>>> indefinite stall issue with device-assignment could be addressed with
>>> a requirement to hold a lease and expect that a lease revocation event
>>> may escalate to SIGKILL in response to 'ndctl destroy-namespace'. The
>>> expectation with device-dax is that it is already a raw interface with
>>> pointy edges and caveats, but I would not be opposed to introducing a
>>> lease semantic.
>>
>> Thanks for the quick response Dan.
>>
>> I am not convinced that the get_user_pages() vs FS-DAX dilemma is a 
>> perfect
>> comparison to "ndctl destroy-namespace -f" vs namespace-is-busy dilemma.
>>
>> Others might disagree with me, I thought that there is no risk of panic
>> if we fail "ndctl destroy-namespace -f" to honor a clean shutdown of the
>> user application. Also, both actions are on the same host, so in theory
>> the admin could shutdown the application before attempt a destructive
>> action.
>>
>> By allowing 'opposite' actions in competition with each other at fine
>> granularity, there is potential for panic in general, not necessarily 
>> with
>> pinned page I guess.  I just ran an experiment and panic'd the system.
>>
>> So, as Optane DCPMEM is generally for server/cloud deployment, and as
>> RAS is a priority for server over administrative commands, to allow
>> namespace management command to panic kernel is not an option?
>>
>> Here is my stress experiment -
>>   Start out with ./create_nm.sh to create as many 48G devdax namespaces
>> as possible. Once that's completed, firing up 6 actions in quick
>> successions in below order:
>>   -> ndctl destroy-namespace all -f
>>   -> ./create_nm.sh
>>   -> ndctl destroy-namespace all -f
>>   -> ./create_nm.sh
>>   -> ndctl destroy-namespace all -f
>>   -> ./create_nm.sh
>>
>> ==========  console message =======
>> Kernel 5.1.0-rc7-next-20190501-libnvdimm-pending on an x86_64
>>
>> ban25uut130 login: [ 1620.866813] BUG: kernel NULL pointer 
>> dereference, address: 0000000000000020
>> [ 1620.874585] #PF: supervisor read access in kernel mode
>> [ 1620.880319] #PF: error_code(0x0000) - not-present page
>> [ 1620.886052] PGD 0 P4D 0
>> [ 1620.888879] Oops: 0000 [#1] SMP NOPTI
>> [ 1620.892964] CPU: 19 PID: 5611 Comm: kworker/u130:3 Tainted: 
>> G        W         5.1.0-rc7-next-20190501-libnvdimm-pending #5
>> [ 1620.905389] Hardware name: Oracle Corporation ORACLE SERVER 
>> X8-2L/ASM,MTHRBD,2U, BIOS 52020101 05/07/2019
>> [ 1620.916069] Workqueue: events_unbound async_run_entry_fn
>> [ 1620.921997] RIP: 0010:klist_put+0x1b/0x6c
>> [ 1620.926471] Code: 48 8b 43 08 5b 41 5c 41 5d 41 5e 41 5f 5d c3 55 
>> 48 89 e5 41 56 41 89 f6 41 55 41 54 53 4c 8b 27 48 89 fb 49 83 e4 fe 
>> 4c 89 e7 <4d> 8b 6c 24 20 e8 3a d4 01 00 45 84 f6 74 10 48 8b 03 a8 01 
>> 74 02
>> [ 1620.947427] RSP: 0018:ffffb1a5e6727da0 EFLAGS: 00010246
>> [ 1620.953258] RAX: ffff956796604c00 RBX: ffff956796604c28 RCX: 
>> 0000000000000000
>> [ 1620.961223] RDX: ffff955000c2c4d8 RSI: 0000000000000001 RDI: 
>> 0000000000000000
>> [ 1620.969185] RBP: ffffb1a5e6727dc0 R08: 0000000000000002 R09: 
>> ffffffffbb54b3c0
>> [ 1620.977150] R10: ffffb1a5e6727d40 R11: fefefefefefefeff R12: 
>> 0000000000000000
>> [ 1620.985116] R13: ffff94d18dcfd000 R14: 0000000000000001 R15: 
>> ffff955000caf140
>> [ 1620.993081] FS:  0000000000000000(0000) GS:ffff95679f4c0000(0000) 
>> knlGS:0000000000000000
>> [ 1621.002113] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [ 1621.008524] CR2: 0000000000000020 CR3: 0000009fa100a005 CR4: 
>> 00000000007606e0
>> [ 1621.016487] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
>> 0000000000000000
>> [ 1621.024450] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 
>> 0000000000000400
>> [ 1621.032413] PKRU: 55555554
>> [ 1621.035433] Call Trace:
>> [ 1621.038161]  klist_del+0xe/0x10
>> [ 1621.041667]  device_del+0x8a/0x2c9
>> [ 1621.045463]  ? __switch_to_asm+0x34/0x70
>> [ 1621.049840]  ? __switch_to_asm+0x40/0x70
>> [ 1621.054220]  device_unregister+0x44/0x4f
>> [ 1621.058603]  nd_async_device_unregister+0x22/0x2d [libnvdimm]
>> [ 1621.065016]  async_run_entry_fn+0x47/0x15a
>> [ 1621.069588]  process_one_work+0x1a2/0x2eb
>> [ 1621.074064]  worker_thread+0x1b8/0x26e
>> [ 1621.078239]  ? cancel_delayed_work_sync+0x15/0x15
>> [ 1621.083490]  kthread+0xf8/0xfd
>> [ 1621.086897]  ? kthread_destroy_worker+0x45/0x45
>> [ 1621.091954]  ret_from_fork+0x1f/0x40
>> [ 1621.095944] Modules linked in: xt_REDIRECT xt_nat xt_CHECKSUM 
>> iptable_mangle xt_MASQUERADE xt_conntrack ipt_REJECT nf_reject_ipv4 
>> tun bridge stp llc ebtable_filter ebtables ip6table_filter 
>> iptable_filter scsi_transport_iscsi ip6table_nat ip6_tables 
>> iptable_nat nf_nat nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 vfat fat 
>> skx_edac intel_powerclamp coretemp kvm_intel kvm irqbypass 
>> crct10dif_pclmul crc32_pclmul ghash_clmulni_intel iTCO_wdt 
>> iTCO_vendor_support aesni_intel ipmi_si crypto_simd cryptd glue_helper 
>> ipmi_devintf ipmi_msghandler sg pcspkr dax_pmem_compat device_dax 
>> dax_pmem_core i2c_i801 pcc_cpufreq lpc_ich ioatdma wmi nfsd 
>> auth_rpcgss nfs_acl lockd grace sunrpc ip_tables xfs libcrc32c nd_pmem 
>> nd_btt sr_mod cdrom sd_mod mgag200 drm_kms_helper syscopyarea 
>> crc32c_intel sysfillrect sysimgblt fb_sys_fops ttm megaraid_sas drm 
>> igb ahci libahci ptp libata pps_core dca i2c_algo_bit nfit libnvdimm 
>> uas usb_storage dm_mirror dm_region_hash dm_log dm_mod
>> [ 1621.189449] CR2: 0000000000000020
>> [ 1621.193169] ---[ end trace 7c3f7029ef24aa5a ]---
>> [ 1621.305383] RIP: 0010:klist_put+0x1b/0x6c
>> [ 1621.309860] Code: 48 8b 43 08 5b 41 5c 41 5d 41 5e 41 5f 5d c3 55 
>> 48 89 e5 41 56 41 89 f6 41 55 41 54 53 4c 8b 27 48 89 fb 49 83 e4 fe 
>> 4c 89 e7 <4d> 8b 6c 24 20 e8 3a d4 01 00 45 84 f6 74 10 48 8b 03 a8 01 
>> 74 02
>> [ 1621.330809] RSP: 0018:ffffb1a5e6727da0 EFLAGS: 00010246
>> [ 1621.336642] RAX: ffff956796604c00 RBX: ffff956796604c28 RCX: 
>> 0000000000000000
>> [ 1621.344606] RDX: ffff955000c2c4d8 RSI: 0000000000000001 RDI: 
>> 0000000000000000
>> [ 1621.352570] RBP: ffffb1a5e6727dc0 R08: 0000000000000002 R09: 
>> ffffffffbb54b3c0
>> [ 1621.360533] R10: ffffb1a5e6727d40 R11: fefefefefefefeff R12: 
>> 0000000000000000
>> [ 1621.368496] R13: ffff94d18dcfd000 R14: 0000000000000001 R15: 
>> ffff955000caf140
>> [ 1621.376460] FS:  0000000000000000(0000) GS:ffff95679f4c0000(0000) 
>> knlGS:0000000000000000
>> [ 1621.385490] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [ 1621.391902] CR2: 0000000000000020 CR3: 0000009fa100a005 CR4: 
>> 00000000007606e0
>> [ 1621.399867] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
>> 0000000000000000
>> [ 1621.407830] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 
>> 0000000000000400
>> [ 1621.415793] PKRU: 55555554
>> [ 1621.418814] Kernel panic - not syncing: Fatal exception
>> [ 1621.424740] Kernel Offset: 0x39000000 from 0xffffffff81000000 
>> (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
>> [ 1621.550711] ---[ end Kernel panic - not syncing: Fatal exception ]---
>>
>>
>> Thanks!
>> -jane
>>
>> _______________________________________________
>> Linux-nvdimm mailing list
>> Linux-nvdimm@lists.01.org
>> https://lists.01.org/mailman/listinfo/linux-nvdimm
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

