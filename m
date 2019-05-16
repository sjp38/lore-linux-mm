Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D37BC04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 16:45:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15DE920833
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 16:45:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="mQi4S6uD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15DE920833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E9DD6B0008; Thu, 16 May 2019 12:45:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99C1B6B000A; Thu, 16 May 2019 12:45:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83A146B000C; Thu, 16 May 2019 12:45:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5ECEE6B0008
	for <linux-mm@kvack.org>; Thu, 16 May 2019 12:45:54 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id u10so3834952itb.5
        for <linux-mm@kvack.org>; Thu, 16 May 2019 09:45:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language;
        bh=zKwoGXh781PAbE+wPKnK/xaiBZjIopEmj/bI3ZgPDS4=;
        b=Kaa0p8aBgrPyHgH828mfcI+MCVr3chyNugGQj80xwoJtnHcR+pDIfP2WnBGTXOLHv/
         Zz1e+6Q1KyXfNiULqvGKcD4HSD/jH479yVr1X7P/EbARkPk3NqxM7xoG2+nhzzb2WYZu
         1/SoXDhSzoCjQhn4Nbv+QVItQvesa9f5nCDIPUY2J3S71Vs9/jFWcmTV3XXksiznVIj2
         ceMWbVyEifkoA9iGLoidgL0VPLBi1FVNfs71syDOsH1n322oC6kb9Me2M03nV1QfJmHc
         ETczHJ0wrEcO4HFj40kYB3kn/gBhVfNnasSz3nBxr8Na/JqZ/Xux6z33N17eF/Dzo4Wg
         drSw==
X-Gm-Message-State: APjAAAUnFYWEP5x3BRMq1CDUsUveA3Mt0fjErvNN66/PWK9qlumvnFM8
	0xnIzc5fuFGe5mgg0bGX5e/etIAty0TS94FXvXetNcW4vHdVlGBkFuZ/kdKqWWbxW1z7JCw91IB
	vi8z9Koc+Z+AH6cSMDKZAkVDxArMkmg4ugFXhL+aIOZ6sJYrmGz8v9e8QYeMKUpryWQ==
X-Received: by 2002:a24:c182:: with SMTP id e124mr12520980itg.177.1558025154050;
        Thu, 16 May 2019 09:45:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+X6kZasA/yJmogh+/vtdfvQhVxPm4tO6yoteGQOF+4BZ8ModNseWAQZb5ebLTL05Ie+x6
X-Received: by 2002:a24:c182:: with SMTP id e124mr12520879itg.177.1558025152607;
        Thu, 16 May 2019 09:45:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558025152; cv=none;
        d=google.com; s=arc-20160816;
        b=qpAgbfFZjLQvx1J++GPoFg64SoBtVOTagAy9JFAj5m7ERIDJVzwRbAXBGnAZQySXDb
         BrMbn3in3sFUnC+LlSxzGqoaJZM4cXILxeIppqo2jBORXCE7OKuaq2jde2tst/WszYlh
         43NxfH9G7bVGucOdlDznJ19brrULdzd7vfRe7mSomZB9zSdN/PutBNTGrZFZwuicDZ0T
         h/Fr1b1mvyY8h5dI0OAvMaHeGAOHqWixFt+oZn42jB9zniZzzRjJas+2UU0xRlMTvpIq
         H4KCDOmrAsfMDp7Nf/d6MqN/wvUetCFwwlpq54zQd3V1sdkzRy9iwSUBRy09nzRcYNcF
         j5NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:in-reply-to:mime-version:user-agent:date
         :message-id:organization:references:cc:to:from:subject
         :dkim-signature;
        bh=zKwoGXh781PAbE+wPKnK/xaiBZjIopEmj/bI3ZgPDS4=;
        b=KhutEvvahjVkg04I/ewxbpLFa0QBZECGc5zaWT4Xoyi7D3kcl1nng0HBrMOvCncCM6
         hwVvEo06MDch6xpc4QMj0xKhaYXAKosc7EKXwFXmnl3ufz6p94N/e+7hRCplxVJWyDM0
         i24DAXlFgJnRFrY/twzG/4otmncc2uRr8nHGfsp6hKmhVMRWt4ApWIjyTBsbQDVdNaVv
         cYdi0lmo/mRWUm1Qf4BDSXC7H75+Iber6e4YNryrcTlXfI3KmLoj2NX7tvbIcom+FaTh
         IbfswdGvvYHmdnRMZxPnF+84NesJMvyzaVhxToj0vFQ3FXFdsRPKZGIqsleThm1qKTGQ
         lBzg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=mQi4S6uD;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id a7si4107272jap.6.2019.05.16.09.45.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 09:45:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=mQi4S6uD;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4GGi7L5056512;
	Thu, 16 May 2019 16:45:47 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : references : message-id : date : mime-version : in-reply-to :
 content-type; s=corp-2018-07-02;
 bh=zKwoGXh781PAbE+wPKnK/xaiBZjIopEmj/bI3ZgPDS4=;
 b=mQi4S6uD45leJkLbzvv+rhCIpGEPi0L+1K9NHWdu+KUyB9ikn67hg40u7BGZS5SgnFv+
 YcBu0afZPnU2aW3Xyf6cTk4GnEnP7i5Uxxv+dhDBtwIWezv8sI1YhR1Eu14Ikvi9iQBh
 mYLpsEhpq/TN/tQKj0WdHGM2XvCJuIjZlxjVlxaTk/GSRW9sX/NEuhJi7klBRmdd8Fn2
 S8VvDfUcrgiymmZsCoCpmn7pwREeClAhWAtsA+EWThqZuOMSGkFj+utNbKBTzY5gvZcb
 gX5r3Eqd4njgtqJvif8mwRwsAyPsOVYhiUT4U0PPsNKv843AY5/XVPLe3MGmDnprJnCN sg== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2sdntu4sbr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 16 May 2019 16:45:47 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4GGjOU5188334;
	Thu, 16 May 2019 16:45:46 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2sggett0y2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 16 May 2019 16:45:46 +0000
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4GGjhgP030983;
	Thu, 16 May 2019 16:45:43 GMT
Received: from [10.159.243.226] (/10.159.243.226)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 16 May 2019 09:45:43 -0700
Subject: Re: [PATCH v2 0/6] mm/devm_memremap_pages: Fix page release race
From: Jane Chu <jane.chu@oracle.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "Rafael J. Wysocki" <rafael@kernel.org>,
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
Organization: Oracle Corporation
Message-ID: <d699e312-0e88-30c7-8e50-ff624418d486@oracle.com>
Date: Thu, 16 May 2019 09:45:41 -0700
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <6bd8319d-3b73-bb1e-5f41-94c580ba271b@oracle.com>
Content-Type: multipart/alternative;
 boundary="------------E314D6BAC65F1C6EA4CA0C60"
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9259 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905160106
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9259 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905160106
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------E314D6BAC65F1C6EA4CA0C60
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi,

I'm able to reproduce the panic below by running two sets of ndctl
commands that actually serve legitimate purpose in parallel (unlike
the brute force experiment earlier), each set in a indefinite loop.
This time it takes about an hour to panic.  But I gather the cause
is probably the same: I've overlapped ndctl commands on the same
region.

Could we add a check in nd_ioctl(), such that if there is
an ongoing ndctl command on a region, subsequent ndctl request
will fail immediately with something to the effect of EAGAIN?
The rationale being that kernel should protect itself against
user mistakes.

Also, sensing the subject fix is for a different problem, and has been
verified, I'm happy to see it in upstream, so we have a better
code base to digger deeper in terms of how the destructive ndctl
commands interacts to typical mission critical applications, include
but not limited to rdma.

thanks,
-jane

On 5/14/2019 2:18 PM, Jane Chu wrote:
> On 5/14/2019 12:04 PM, Dan Williams wrote:
>
>> On Tue, May 14, 2019 at 11:53 AM Jane Chu <jane.chu@oracle.com> wrote:
>>> On 5/13/2019 12:22 PM, Logan Gunthorpe wrote:
>>>
>>> On 2019-05-08 11:05 a.m., Logan Gunthorpe wrote:
>>>
>>> On 2019-05-07 5:55 p.m., Dan Williams wrote:
>>>
>>> Changes since v1 [1]:
>>> - Fix a NULL-pointer deref crash in pci_p2pdma_release() (Logan)
>>>
>>> - Refresh the p2pdma patch headers to match the format of other p2pdma
>>>     patches (Bjorn)
>>>
>>> - Collect Ira's reviewed-by
>>>
>>> [1]: 
>>> https://lore.kernel.org/lkml/155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com/
>>>
>>> This series looks good to me:
>>>
>>> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
>>>
>>> However, I haven't tested it yet but I intend to later this week.
>>>
>>> I've tested libnvdimm-pending which includes this series on my setup 
>>> and
>>> everything works great.
>>>
>>> Just wondering in a difference scenario where pmem pages are 
>>> exported to
>>> a KVM guest, and then by mistake the user issues "ndctl 
>>> destroy-namespace -f",
>>> will the kernel wait indefinitely until the user figures out to kill 
>>> the guest
>>> and release the pmem pages?
>> It depends on whether the pages are pinned. Typically DAX memory
>> mappings assigned to a guest are not pinned in the host and can be
>> invalidated at any time. The pinning only occurs with VFIO and
>> device-assignment which isn't the common case, especially since that
>> configuration is blocked by fsdax. However, with devdax, yes you can
>> arrange for the system to go into an indefinite wait.
>>
>> This somewhat ties back to the get_user_pages() vs DAX debate. The
>> indefinite stall issue with device-assignment could be addressed with
>> a requirement to hold a lease and expect that a lease revocation event
>> may escalate to SIGKILL in response to 'ndctl destroy-namespace'. The
>> expectation with device-dax is that it is already a raw interface with
>> pointy edges and caveats, but I would not be opposed to introducing a
>> lease semantic.
>
> Thanks for the quick response Dan.
>
> I am not convinced that the get_user_pages() vs FS-DAX dilemma is a 
> perfect
> comparison to "ndctl destroy-namespace -f" vs namespace-is-busy dilemma.
>
> Others might disagree with me, I thought that there is no risk of panic
> if we fail "ndctl destroy-namespace -f" to honor a clean shutdown of the
> user application. Also, both actions are on the same host, so in theory
> the admin could shutdown the application before attempt a destructive
> action.
>
> By allowing 'opposite' actions in competition with each other at fine
> granularity, there is potential for panic in general, not necessarily 
> with
> pinned page I guess.  I just ran an experiment and panic'd the system.
>
> So, as Optane DCPMEM is generally for server/cloud deployment, and as
> RAS is a priority for server over administrative commands, to allow
> namespace management command to panic kernel is not an option?
>
> Here is my stress experiment -
>   Start out with ./create_nm.sh to create as many 48G devdax namespaces
> as possible. Once that's completed, firing up 6 actions in quick
> successions in below order:
>   -> ndctl destroy-namespace all -f
>   -> ./create_nm.sh
>   -> ndctl destroy-namespace all -f
>   -> ./create_nm.sh
>   -> ndctl destroy-namespace all -f
>   -> ./create_nm.sh
>
> ==========  console message =======
> Kernel 5.1.0-rc7-next-20190501-libnvdimm-pending on an x86_64
>
> ban25uut130 login: [ 1620.866813] BUG: kernel NULL pointer 
> dereference, address: 0000000000000020
> [ 1620.874585] #PF: supervisor read access in kernel mode
> [ 1620.880319] #PF: error_code(0x0000) - not-present page
> [ 1620.886052] PGD 0 P4D 0
> [ 1620.888879] Oops: 0000 [#1] SMP NOPTI
> [ 1620.892964] CPU: 19 PID: 5611 Comm: kworker/u130:3 Tainted: 
> G        W         5.1.0-rc7-next-20190501-libnvdimm-pending #5
> [ 1620.905389] Hardware name: Oracle Corporation ORACLE SERVER 
> X8-2L/ASM,MTHRBD,2U, BIOS 52020101 05/07/2019
> [ 1620.916069] Workqueue: events_unbound async_run_entry_fn
> [ 1620.921997] RIP: 0010:klist_put+0x1b/0x6c
> [ 1620.926471] Code: 48 8b 43 08 5b 41 5c 41 5d 41 5e 41 5f 5d c3 55 
> 48 89 e5 41 56 41 89 f6 41 55 41 54 53 4c 8b 27 48 89 fb 49 83 e4 fe 
> 4c 89 e7 <4d> 8b 6c 24 20 e8 3a d4 01 00 45 84 f6 74 10 48 8b 03 a8 01 
> 74 02
> [ 1620.947427] RSP: 0018:ffffb1a5e6727da0 EFLAGS: 00010246
> [ 1620.953258] RAX: ffff956796604c00 RBX: ffff956796604c28 RCX: 
> 0000000000000000
> [ 1620.961223] RDX: ffff955000c2c4d8 RSI: 0000000000000001 RDI: 
> 0000000000000000
> [ 1620.969185] RBP: ffffb1a5e6727dc0 R08: 0000000000000002 R09: 
> ffffffffbb54b3c0
> [ 1620.977150] R10: ffffb1a5e6727d40 R11: fefefefefefefeff R12: 
> 0000000000000000
> [ 1620.985116] R13: ffff94d18dcfd000 R14: 0000000000000001 R15: 
> ffff955000caf140
> [ 1620.993081] FS:  0000000000000000(0000) GS:ffff95679f4c0000(0000) 
> knlGS:0000000000000000
> [ 1621.002113] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1621.008524] CR2: 0000000000000020 CR3: 0000009fa100a005 CR4: 
> 00000000007606e0
> [ 1621.016487] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
> 0000000000000000
> [ 1621.024450] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 
> 0000000000000400
> [ 1621.032413] PKRU: 55555554
> [ 1621.035433] Call Trace:
> [ 1621.038161]  klist_del+0xe/0x10
> [ 1621.041667]  device_del+0x8a/0x2c9
> [ 1621.045463]  ? __switch_to_asm+0x34/0x70
> [ 1621.049840]  ? __switch_to_asm+0x40/0x70
> [ 1621.054220]  device_unregister+0x44/0x4f
> [ 1621.058603]  nd_async_device_unregister+0x22/0x2d [libnvdimm]
> [ 1621.065016]  async_run_entry_fn+0x47/0x15a
> [ 1621.069588]  process_one_work+0x1a2/0x2eb
> [ 1621.074064]  worker_thread+0x1b8/0x26e
> [ 1621.078239]  ? cancel_delayed_work_sync+0x15/0x15
> [ 1621.083490]  kthread+0xf8/0xfd
> [ 1621.086897]  ? kthread_destroy_worker+0x45/0x45
> [ 1621.091954]  ret_from_fork+0x1f/0x40
> [ 1621.095944] Modules linked in: xt_REDIRECT xt_nat xt_CHECKSUM 
> iptable_mangle xt_MASQUERADE xt_conntrack ipt_REJECT nf_reject_ipv4 
> tun bridge stp llc ebtable_filter ebtables ip6table_filter 
> iptable_filter scsi_transport_iscsi ip6table_nat ip6_tables 
> iptable_nat nf_nat nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 vfat fat 
> skx_edac intel_powerclamp coretemp kvm_intel kvm irqbypass 
> crct10dif_pclmul crc32_pclmul ghash_clmulni_intel iTCO_wdt 
> iTCO_vendor_support aesni_intel ipmi_si crypto_simd cryptd glue_helper 
> ipmi_devintf ipmi_msghandler sg pcspkr dax_pmem_compat device_dax 
> dax_pmem_core i2c_i801 pcc_cpufreq lpc_ich ioatdma wmi nfsd 
> auth_rpcgss nfs_acl lockd grace sunrpc ip_tables xfs libcrc32c nd_pmem 
> nd_btt sr_mod cdrom sd_mod mgag200 drm_kms_helper syscopyarea 
> crc32c_intel sysfillrect sysimgblt fb_sys_fops ttm megaraid_sas drm 
> igb ahci libahci ptp libata pps_core dca i2c_algo_bit nfit libnvdimm 
> uas usb_storage dm_mirror dm_region_hash dm_log dm_mod
> [ 1621.189449] CR2: 0000000000000020
> [ 1621.193169] ---[ end trace 7c3f7029ef24aa5a ]---
> [ 1621.305383] RIP: 0010:klist_put+0x1b/0x6c
> [ 1621.309860] Code: 48 8b 43 08 5b 41 5c 41 5d 41 5e 41 5f 5d c3 55 
> 48 89 e5 41 56 41 89 f6 41 55 41 54 53 4c 8b 27 48 89 fb 49 83 e4 fe 
> 4c 89 e7 <4d> 8b 6c 24 20 e8 3a d4 01 00 45 84 f6 74 10 48 8b 03 a8 01 
> 74 02
> [ 1621.330809] RSP: 0018:ffffb1a5e6727da0 EFLAGS: 00010246
> [ 1621.336642] RAX: ffff956796604c00 RBX: ffff956796604c28 RCX: 
> 0000000000000000
> [ 1621.344606] RDX: ffff955000c2c4d8 RSI: 0000000000000001 RDI: 
> 0000000000000000
> [ 1621.352570] RBP: ffffb1a5e6727dc0 R08: 0000000000000002 R09: 
> ffffffffbb54b3c0
> [ 1621.360533] R10: ffffb1a5e6727d40 R11: fefefefefefefeff R12: 
> 0000000000000000
> [ 1621.368496] R13: ffff94d18dcfd000 R14: 0000000000000001 R15: 
> ffff955000caf140
> [ 1621.376460] FS:  0000000000000000(0000) GS:ffff95679f4c0000(0000) 
> knlGS:0000000000000000
> [ 1621.385490] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1621.391902] CR2: 0000000000000020 CR3: 0000009fa100a005 CR4: 
> 00000000007606e0
> [ 1621.399867] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
> 0000000000000000
> [ 1621.407830] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 
> 0000000000000400
> [ 1621.415793] PKRU: 55555554
> [ 1621.418814] Kernel panic - not syncing: Fatal exception
> [ 1621.424740] Kernel Offset: 0x39000000 from 0xffffffff81000000 
> (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
> [ 1621.550711] ---[ end Kernel panic - not syncing: Fatal exception ]---
>
>
> Thanks!
> -jane
>
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

--------------E314D6BAC65F1C6EA4CA0C60
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <pre>Hi,

I'm able to reproduce the panic below by running two sets of ndctl
commands that actually serve legitimate purpose in parallel (unlike
the brute force experiment earlier), each set in a indefinite loop.
This time it takes about an hour to panic.  But I gather the cause
is probably the same: I've overlapped ndctl commands on the same
region.  

Could we add a check in nd_ioctl(), such that if there is
an ongoing ndctl command on a region, subsequent ndctl request
will fail immediately with something to the effect of EAGAIN?
The rationale being that kernel should protect itself against
user mistakes.

Also, sensing the subject fix is for a different problem, and has been
verified, I'm happy to see it in upstream, so we have a better 
code base to digger deeper in terms of how the destructive ndctl
commands interacts to typical mission critical applications, include
but not limited to rdma.

thanks,
-jane

</pre>
    <div class="moz-cite-prefix">On 5/14/2019 2:18 PM, Jane Chu wrote:<br>
    </div>
    <blockquote type="cite"
      cite="mid:6bd8319d-3b73-bb1e-5f41-94c580ba271b@oracle.com">On
      5/14/2019 12:04 PM, Dan Williams wrote:
      <br>
      <br>
      <blockquote type="cite">On Tue, May 14, 2019 at 11:53 AM Jane Chu
        <a class="moz-txt-link-rfc2396E" href="mailto:jane.chu@oracle.com">&lt;jane.chu@oracle.com&gt;</a> wrote:
        <br>
        <blockquote type="cite">On 5/13/2019 12:22 PM, Logan Gunthorpe
          wrote:
          <br>
          <br>
          On 2019-05-08 11:05 a.m., Logan Gunthorpe wrote:
          <br>
          <br>
          On 2019-05-07 5:55 p.m., Dan Williams wrote:
          <br>
          <br>
          Changes since v1 [1]:
          <br>
          - Fix a NULL-pointer deref crash in pci_p2pdma_release()
          (Logan)
          <br>
          <br>
          - Refresh the p2pdma patch headers to match the format of
          other p2pdma
          <br>
              patches (Bjorn)
          <br>
          <br>
          - Collect Ira's reviewed-by
          <br>
          <br>
          [1]:
<a class="moz-txt-link-freetext" href="https://lore.kernel.org/lkml/155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com/">https://lore.kernel.org/lkml/155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com/</a><br>
          <br>
          This series looks good to me:
          <br>
          <br>
          Reviewed-by: Logan Gunthorpe <a class="moz-txt-link-rfc2396E" href="mailto:logang@deltatee.com">&lt;logang@deltatee.com&gt;</a>
          <br>
          <br>
          However, I haven't tested it yet but I intend to later this
          week.
          <br>
          <br>
          I've tested libnvdimm-pending which includes this series on my
          setup and
          <br>
          everything works great.
          <br>
          <br>
          Just wondering in a difference scenario where pmem pages are
          exported to
          <br>
          a KVM guest, and then by mistake the user issues "ndctl
          destroy-namespace -f",
          <br>
          will the kernel wait indefinitely until the user figures out
          to kill the guest
          <br>
          and release the pmem pages?
          <br>
        </blockquote>
        It depends on whether the pages are pinned. Typically DAX memory
        <br>
        mappings assigned to a guest are not pinned in the host and can
        be
        <br>
        invalidated at any time. The pinning only occurs with VFIO and
        <br>
        device-assignment which isn't the common case, especially since
        that
        <br>
        configuration is blocked by fsdax. However, with devdax, yes you
        can
        <br>
        arrange for the system to go into an indefinite wait.
        <br>
        <br>
        This somewhat ties back to the get_user_pages() vs DAX debate.
        The
        <br>
        indefinite stall issue with device-assignment could be addressed
        with
        <br>
        a requirement to hold a lease and expect that a lease revocation
        event
        <br>
        may escalate to SIGKILL in response to 'ndctl
        destroy-namespace'. The
        <br>
        expectation with device-dax is that it is already a raw
        interface with
        <br>
        pointy edges and caveats, but I would not be opposed to
        introducing a
        <br>
        lease semantic.
        <br>
      </blockquote>
      <br>
      Thanks for the quick response Dan.
      <br>
      <br>
      I am not convinced that the get_user_pages() vs FS-DAX dilemma is
      a perfect
      <br>
      comparison to "ndctl destroy-namespace -f" vs namespace-is-busy
      dilemma.
      <br>
      <br>
      Others might disagree with me, I thought that there is no risk of
      panic
      <br>
      if we fail "ndctl destroy-namespace -f" to honor a clean shutdown
      of the
      <br>
      user application. Also, both actions are on the same host, so in
      theory
      <br>
      the admin could shutdown the application before attempt a
      destructive
      <br>
      action.
      <br>
      <br>
      By allowing 'opposite' actions in competition with each other at
      fine
      <br>
      granularity, there is potential for panic in general, not
      necessarily with
      <br>
      pinned page I guess.  I just ran an experiment and panic'd the
      system.
      <br>
      <br>
      So, as Optane DCPMEM is generally for server/cloud deployment, and
      as
      <br>
      RAS is a priority for server over administrative commands, to
      allow
      <br>
      namespace management command to panic kernel is not an option?
      <br>
      <br>
      Here is my stress experiment -
      <br>
        Start out with ./create_nm.sh to create as many 48G devdax
      namespaces
      <br>
      as possible. Once that's completed, firing up 6 actions in quick
      <br>
      successions in below order:
      <br>
        -&gt; ndctl destroy-namespace all -f
      <br>
        -&gt; ./create_nm.sh
      <br>
        -&gt; ndctl destroy-namespace all -f
      <br>
        -&gt; ./create_nm.sh
      <br>
        -&gt; ndctl destroy-namespace all -f
      <br>
        -&gt; ./create_nm.sh
      <br>
      <br>
      ==========  console message =======
      <br>
      Kernel 5.1.0-rc7-next-20190501-libnvdimm-pending on an x86_64
      <br>
      <br>
      ban25uut130 login: [ 1620.866813] BUG: kernel NULL pointer
      dereference, address: 0000000000000020
      <br>
      [ 1620.874585] #PF: supervisor read access in kernel mode
      <br>
      [ 1620.880319] #PF: error_code(0x0000) - not-present page
      <br>
      [ 1620.886052] PGD 0 P4D 0
      <br>
      [ 1620.888879] Oops: 0000 [#1] SMP NOPTI
      <br>
      [ 1620.892964] CPU: 19 PID: 5611 Comm: kworker/u130:3 Tainted:
      G        W         5.1.0-rc7-next-20190501-libnvdimm-pending #5
      <br>
      [ 1620.905389] Hardware name: Oracle Corporation ORACLE SERVER
      X8-2L/ASM,MTHRBD,2U, BIOS 52020101 05/07/2019
      <br>
      [ 1620.916069] Workqueue: events_unbound async_run_entry_fn
      <br>
      [ 1620.921997] RIP: 0010:klist_put+0x1b/0x6c
      <br>
      [ 1620.926471] Code: 48 8b 43 08 5b 41 5c 41 5d 41 5e 41 5f 5d c3
      55 48 89 e5 41 56 41 89 f6 41 55 41 54 53 4c 8b 27 48 89 fb 49 83
      e4 fe 4c 89 e7 &lt;4d&gt; 8b 6c 24 20 e8 3a d4 01 00 45 84 f6 74
      10 48 8b 03 a8 01 74 02
      <br>
      [ 1620.947427] RSP: 0018:ffffb1a5e6727da0 EFLAGS: 00010246
      <br>
      [ 1620.953258] RAX: ffff956796604c00 RBX: ffff956796604c28 RCX:
      0000000000000000
      <br>
      [ 1620.961223] RDX: ffff955000c2c4d8 RSI: 0000000000000001 RDI:
      0000000000000000
      <br>
      [ 1620.969185] RBP: ffffb1a5e6727dc0 R08: 0000000000000002 R09:
      ffffffffbb54b3c0
      <br>
      [ 1620.977150] R10: ffffb1a5e6727d40 R11: fefefefefefefeff R12:
      0000000000000000
      <br>
      [ 1620.985116] R13: ffff94d18dcfd000 R14: 0000000000000001 R15:
      ffff955000caf140
      <br>
      [ 1620.993081] FS:  0000000000000000(0000)
      GS:ffff95679f4c0000(0000) knlGS:0000000000000000
      <br>
      [ 1621.002113] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
      <br>
      [ 1621.008524] CR2: 0000000000000020 CR3: 0000009fa100a005 CR4:
      00000000007606e0
      <br>
      [ 1621.016487] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
      0000000000000000
      <br>
      [ 1621.024450] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:
      0000000000000400
      <br>
      [ 1621.032413] PKRU: 55555554
      <br>
      [ 1621.035433] Call Trace:
      <br>
      [ 1621.038161]  klist_del+0xe/0x10
      <br>
      [ 1621.041667]  device_del+0x8a/0x2c9
      <br>
      [ 1621.045463]  ? __switch_to_asm+0x34/0x70
      <br>
      [ 1621.049840]  ? __switch_to_asm+0x40/0x70
      <br>
      [ 1621.054220]  device_unregister+0x44/0x4f
      <br>
      [ 1621.058603]  nd_async_device_unregister+0x22/0x2d [libnvdimm]
      <br>
      [ 1621.065016]  async_run_entry_fn+0x47/0x15a
      <br>
      [ 1621.069588]  process_one_work+0x1a2/0x2eb
      <br>
      [ 1621.074064]  worker_thread+0x1b8/0x26e
      <br>
      [ 1621.078239]  ? cancel_delayed_work_sync+0x15/0x15
      <br>
      [ 1621.083490]  kthread+0xf8/0xfd
      <br>
      [ 1621.086897]  ? kthread_destroy_worker+0x45/0x45
      <br>
      [ 1621.091954]  ret_from_fork+0x1f/0x40
      <br>
      [ 1621.095944] Modules linked in: xt_REDIRECT xt_nat xt_CHECKSUM
      iptable_mangle xt_MASQUERADE xt_conntrack ipt_REJECT
      nf_reject_ipv4 tun bridge stp llc ebtable_filter ebtables
      ip6table_filter iptable_filter scsi_transport_iscsi ip6table_nat
      ip6_tables iptable_nat nf_nat nf_conntrack nf_defrag_ipv6
      nf_defrag_ipv4 vfat fat skx_edac intel_powerclamp coretemp
      kvm_intel kvm irqbypass crct10dif_pclmul crc32_pclmul
      ghash_clmulni_intel iTCO_wdt iTCO_vendor_support aesni_intel
      ipmi_si crypto_simd cryptd glue_helper ipmi_devintf
      ipmi_msghandler sg pcspkr dax_pmem_compat device_dax dax_pmem_core
      i2c_i801 pcc_cpufreq lpc_ich ioatdma wmi nfsd auth_rpcgss nfs_acl
      lockd grace sunrpc ip_tables xfs libcrc32c nd_pmem nd_btt sr_mod
      cdrom sd_mod mgag200 drm_kms_helper syscopyarea crc32c_intel
      sysfillrect sysimgblt fb_sys_fops ttm megaraid_sas drm igb ahci
      libahci ptp libata pps_core dca i2c_algo_bit nfit libnvdimm uas
      usb_storage dm_mirror dm_region_hash dm_log dm_mod
      <br>
      [ 1621.189449] CR2: 0000000000000020
      <br>
      [ 1621.193169] ---[ end trace 7c3f7029ef24aa5a ]---
      <br>
      [ 1621.305383] RIP: 0010:klist_put+0x1b/0x6c
      <br>
      [ 1621.309860] Code: 48 8b 43 08 5b 41 5c 41 5d 41 5e 41 5f 5d c3
      55 48 89 e5 41 56 41 89 f6 41 55 41 54 53 4c 8b 27 48 89 fb 49 83
      e4 fe 4c 89 e7 &lt;4d&gt; 8b 6c 24 20 e8 3a d4 01 00 45 84 f6 74
      10 48 8b 03 a8 01 74 02
      <br>
      [ 1621.330809] RSP: 0018:ffffb1a5e6727da0 EFLAGS: 00010246
      <br>
      [ 1621.336642] RAX: ffff956796604c00 RBX: ffff956796604c28 RCX:
      0000000000000000
      <br>
      [ 1621.344606] RDX: ffff955000c2c4d8 RSI: 0000000000000001 RDI:
      0000000000000000
      <br>
      [ 1621.352570] RBP: ffffb1a5e6727dc0 R08: 0000000000000002 R09:
      ffffffffbb54b3c0
      <br>
      [ 1621.360533] R10: ffffb1a5e6727d40 R11: fefefefefefefeff R12:
      0000000000000000
      <br>
      [ 1621.368496] R13: ffff94d18dcfd000 R14: 0000000000000001 R15:
      ffff955000caf140
      <br>
      [ 1621.376460] FS:  0000000000000000(0000)
      GS:ffff95679f4c0000(0000) knlGS:0000000000000000
      <br>
      [ 1621.385490] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
      <br>
      [ 1621.391902] CR2: 0000000000000020 CR3: 0000009fa100a005 CR4:
      00000000007606e0
      <br>
      [ 1621.399867] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
      0000000000000000
      <br>
      [ 1621.407830] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:
      0000000000000400
      <br>
      [ 1621.415793] PKRU: 55555554
      <br>
      [ 1621.418814] Kernel panic - not syncing: Fatal exception
      <br>
      [ 1621.424740] Kernel Offset: 0x39000000 from 0xffffffff81000000
      (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
      <br>
      [ 1621.550711] ---[ end Kernel panic - not syncing: Fatal
      exception ]---
      <br>
      <br>
      <br>
      Thanks!
      <br>
      -jane
      <br>
      <br>
      _______________________________________________
      <br>
      Linux-nvdimm mailing list
      <br>
      <a class="moz-txt-link-abbreviated" href="mailto:Linux-nvdimm@lists.01.org">Linux-nvdimm@lists.01.org</a>
      <br>
      <a class="moz-txt-link-freetext" href="https://lists.01.org/mailman/listinfo/linux-nvdimm">https://lists.01.org/mailman/listinfo/linux-nvdimm</a>
      <br>
    </blockquote>
  </body>
</html>

--------------E314D6BAC65F1C6EA4CA0C60--

