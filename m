Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09139C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:19:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A37ED20873
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:19:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="UkWlsKxO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A37ED20873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A90D6B0005; Tue, 14 May 2019 17:19:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 332EF6B0006; Tue, 14 May 2019 17:19:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AC646B0007; Tue, 14 May 2019 17:19:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id DABBC6B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 17:19:21 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id e5so180195oih.23
        for <linux-mm@kvack.org>; Tue, 14 May 2019 14:19:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=EQWSirsGlqa3NQye335of+ycNoUAgzqdpgdwkI5ffCA=;
        b=GWyszSxuW8yuBNIlXjgO0MC5cz6r2Hqlp5bLNsfXA9+t2JK6zgMgEUFB6Oz7WhHBsD
         AJawYi5ll7NOt5Rrmg4YX1oFmFg+xxWZdr0l3ME7JIP66cGl5Xje0L4qWLvk+Zn/njkn
         HRpcivr2oNsI4x6xFH1d9foQkLpYsuS89OGHUSEG4axtyR8PmHHtSWGeqJKtaBjEzJ/E
         g9H4fbb2K0mEt0wAawdnmt78uBBqoFy/IiN48lq5lTJdrk+ydPhE+WmQXNNHx1p+haKs
         D60mRXWdqqz4DmVTWl/BsoZO16P9WpZ/QEaaz59jLRdgbdL8rMidnUiKpxw45ZVytNGm
         EYow==
X-Gm-Message-State: APjAAAX7a8r1OdFXjkvuqdMo238qaRr062u0uviYxUgDPlg8Qedqy63X
	mNmoTU7Zd8oJz2JMK43koAady+66Ynz6kr4GiA7EnHG+Nzh9P422sfNrGSNHKHcWMiuOpRAmk5x
	JxT32sLrwVsL8a2SJJyvdiDI5WundYrjwyZZsKPHvu+Zq/2BeGA+hyCRjlJFszEQsQw==
X-Received: by 2002:a9d:6210:: with SMTP id g16mr23581750otj.225.1557868761507;
        Tue, 14 May 2019 14:19:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBlSj6Nt8VlMflzcgwk1h4GuAm9IbKFvZGtZm+Hw+VfTtJo9aSwa6QJDc5KzDlRGQursmJ
X-Received: by 2002:a9d:6210:: with SMTP id g16mr23581670otj.225.1557868760131;
        Tue, 14 May 2019 14:19:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557868760; cv=none;
        d=google.com; s=arc-20160816;
        b=e42RS/vvhzt6f6OzMLLazEOqohw/3j54X0kGYIfukQBQKBf1RcJSvQrJuJa5YI09au
         e8YvZYjsKohDAAqsFvkeC5n5mAhOmdol2pv7eFS+lvQdisA8Y9xp/4EzacXY+eYn79Bh
         QeTj+fpfYbjZnGxaK5SUfEGgXGPkoU6EvVuy3MbLghq+8oOwm/SRgA2rZ/kfAxcu1S60
         Jk69hhwIZVZUD+uY7K0RwIzdne9rrfUBnhtdo2gkUUhBJxy65+Jy+IKmnln5jqmE0rtN
         owxpznegw7Vl8wkeVX6Q960HSraLSulLDGYroy8M8Xg/U8sY0Sic2cTcegAoUVWsWyze
         zTuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=EQWSirsGlqa3NQye335of+ycNoUAgzqdpgdwkI5ffCA=;
        b=TUcJIRrsGJzjwxdeD7PeK1YMkpgr4cCBnDJVMJnp/hTih3xIpGAVKb1emdLZk91CFf
         5nNA1CNNf4AXALND8GjLPsC8AXOA6m3HMlWlbaUvMXzrknl1WvxzoqYizE13TAHBDxmr
         wP+RuVVHJb+JfI0AHUmXlH7myW56rSPaRLmzeY6ExA9YY/a1401cZGu8Vi2SuR6XvQX7
         vANaY+Q4SuTmIPKIedffqHhOV+j8kA9+afDC3EmYXZaJCD6KtVcORtC0m4m9ApXzdWqo
         FplQT5+BJbkf2YIMtLUlEYH+sGe5KjJQaezsFWN0VJKaqI/rWwr3B5fHJt8oN8uH6IGM
         WyNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=UkWlsKxO;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id x62si77819oig.33.2019.05.14.14.19.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 14:19:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=UkWlsKxO;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4ELDlXD160157;
	Tue, 14 May 2019 21:19:06 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=EQWSirsGlqa3NQye335of+ycNoUAgzqdpgdwkI5ffCA=;
 b=UkWlsKxOm5yF3JEAAKMk7Fu3Ql4DnruLjduZWZQ8lkdO46S82VwlI9LjT6SClB+uPC4p
 Ug/8SzJy/TL/nViBHIATr3OZNgTB87wr3vupEMeITYrON3jcpr0jIqjvaFWnerryH+CD
 sru8FWnfSNp9K65VH0MPet9DFMz2XbkG4msOaLrp9GZTzEW4sc7LoMzLO4A/Adw2nfqi
 AOBQwOEvoqW4ROhZ/+i29aqEKuthSnYjsSsrqj4MupwzDAlPnAv1izKjghLkzQ4g58I5
 nhxiL7w361QOCttpEF+1Drl1obGHyHprEzaZHPn2XSl99xRh664sZZMX9YvzGe9zoNKU VQ== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2130.oracle.com with ESMTP id 2sdkwds4kg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 21:19:06 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4ELICvE069878;
	Tue, 14 May 2019 21:19:05 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3030.oracle.com with ESMTP id 2sf3cnh6um-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 21:19:05 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4ELJ1tX022558;
	Tue, 14 May 2019 21:19:02 GMT
Received: from [10.159.158.136] (/10.159.158.136)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 14 May 2019 14:19:01 -0700
Subject: Re: [PATCH v2 0/6] mm/devm_memremap_pages: Fix page release race
To: Dan Williams <dan.j.williams@intel.com>
Cc: Logan Gunthorpe <logang@deltatee.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        "Rafael J. Wysocki" <rafael@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-nvdimm <linux-nvdimm@lists.01.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux MM <linux-mm@kvack.org>,
        =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>,
        Bjorn Helgaas <bhelgaas@google.com>, Christoph Hellwig <hch@lst.de>
References: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
 <059859ca-3cc8-e3ff-f797-1b386931c41e@deltatee.com>
 <17ada515-f488-d153-90ef-7a5cc5fefb0f@deltatee.com>
 <8a7cfa6b-6312-e8e5-9314-954496d2f6ce@oracle.com>
 <CAPcyv4i28tQMVrscQo31cfu1ZcMAb74iMkKYhu9iO_BjJvp+9A@mail.gmail.com>
From: Jane Chu <jane.chu@oracle.com>
Organization: Oracle Corporation
Message-ID: <6bd8319d-3b73-bb1e-5f41-94c580ba271b@oracle.com>
Date: Tue, 14 May 2019 14:18:59 -0700
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4i28tQMVrscQo31cfu1ZcMAb74iMkKYhu9iO_BjJvp+9A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9257 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905140140
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9257 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905140140
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/14/2019 12:04 PM, Dan Williams wrote:

> On Tue, May 14, 2019 at 11:53 AM Jane Chu <jane.chu@oracle.com> wrote:
>> On 5/13/2019 12:22 PM, Logan Gunthorpe wrote:
>>
>> On 2019-05-08 11:05 a.m., Logan Gunthorpe wrote:
>>
>> On 2019-05-07 5:55 p.m., Dan Williams wrote:
>>
>> Changes since v1 [1]:
>> - Fix a NULL-pointer deref crash in pci_p2pdma_release() (Logan)
>>
>> - Refresh the p2pdma patch headers to match the format of other p2pdma
>>     patches (Bjorn)
>>
>> - Collect Ira's reviewed-by
>>
>> [1]: https://lore.kernel.org/lkml/155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com/
>>
>> This series looks good to me:
>>
>> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
>>
>> However, I haven't tested it yet but I intend to later this week.
>>
>> I've tested libnvdimm-pending which includes this series on my setup and
>> everything works great.
>>
>> Just wondering in a difference scenario where pmem pages are exported to
>> a KVM guest, and then by mistake the user issues "ndctl destroy-namespace -f",
>> will the kernel wait indefinitely until the user figures out to kill the guest
>> and release the pmem pages?
> It depends on whether the pages are pinned. Typically DAX memory
> mappings assigned to a guest are not pinned in the host and can be
> invalidated at any time. The pinning only occurs with VFIO and
> device-assignment which isn't the common case, especially since that
> configuration is blocked by fsdax. However, with devdax, yes you can
> arrange for the system to go into an indefinite wait.
>
> This somewhat ties back to the get_user_pages() vs DAX debate. The
> indefinite stall issue with device-assignment could be addressed with
> a requirement to hold a lease and expect that a lease revocation event
> may escalate to SIGKILL in response to 'ndctl destroy-namespace'. The
> expectation with device-dax is that it is already a raw interface with
> pointy edges and caveats, but I would not be opposed to introducing a
> lease semantic.

Thanks for the quick response Dan.

I am not convinced that the get_user_pages() vs FS-DAX dilemma is a perfect
comparison to "ndctl destroy-namespace -f" vs namespace-is-busy dilemma.

Others might disagree with me, I thought that there is no risk of panic
if we fail "ndctl destroy-namespace -f" to honor a clean shutdown of the
user application. Also, both actions are on the same host, so in theory
the admin could shutdown the application before attempt a destructive
action.

By allowing 'opposite' actions in competition with each other at fine
granularity, there is potential for panic in general, not necessarily with
pinned page I guess.  I just ran an experiment and panic'd the system.

So, as Optane DCPMEM is generally for server/cloud deployment, and as
RAS is a priority for server over administrative commands, to allow
namespace management command to panic kernel is not an option?

Here is my stress experiment -
   
Start out with ./create_nm.sh to create as many 48G devdax namespaces
as possible. Once that's completed, firing up 6 actions in quick
successions in below order:
   -> ndctl destroy-namespace all -f
   -> ./create_nm.sh
   -> ndctl destroy-namespace all -f
   -> ./create_nm.sh
   -> ndctl destroy-namespace all -f
   -> ./create_nm.sh

==========  console message =======
Kernel 5.1.0-rc7-next-20190501-libnvdimm-pending on an x86_64

ban25uut130 login: [ 1620.866813] BUG: kernel NULL pointer dereference, address: 0000000000000020
[ 1620.874585] #PF: supervisor read access in kernel mode
[ 1620.880319] #PF: error_code(0x0000) - not-present page
[ 1620.886052] PGD 0 P4D 0
[ 1620.888879] Oops: 0000 [#1] SMP NOPTI
[ 1620.892964] CPU: 19 PID: 5611 Comm: kworker/u130:3 Tainted: G        W         5.1.0-rc7-next-20190501-libnvdimm-pending #5
[ 1620.905389] Hardware name: Oracle Corporation ORACLE SERVER X8-2L/ASM,MTHRBD,2U, BIOS 52020101 05/07/2019
[ 1620.916069] Workqueue: events_unbound async_run_entry_fn
[ 1620.921997] RIP: 0010:klist_put+0x1b/0x6c
[ 1620.926471] Code: 48 8b 43 08 5b 41 5c 41 5d 41 5e 41 5f 5d c3 55 48 89 e5 41 56 41 89 f6 41 55 41 54 53 4c 8b 27 48 89 fb 49 83 e4 fe 4c 89 e7 <4d> 8b 6c 24 20 e8 3a d4 01 00 45 84 f6 74 10 48 8b 03 a8 01 74 02
[ 1620.947427] RSP: 0018:ffffb1a5e6727da0 EFLAGS: 00010246
[ 1620.953258] RAX: ffff956796604c00 RBX: ffff956796604c28 RCX: 0000000000000000
[ 1620.961223] RDX: ffff955000c2c4d8 RSI: 0000000000000001 RDI: 0000000000000000
[ 1620.969185] RBP: ffffb1a5e6727dc0 R08: 0000000000000002 R09: ffffffffbb54b3c0
[ 1620.977150] R10: ffffb1a5e6727d40 R11: fefefefefefefeff R12: 0000000000000000
[ 1620.985116] R13: ffff94d18dcfd000 R14: 0000000000000001 R15: ffff955000caf140
[ 1620.993081] FS:  0000000000000000(0000) GS:ffff95679f4c0000(0000) knlGS:0000000000000000
[ 1621.002113] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1621.008524] CR2: 0000000000000020 CR3: 0000009fa100a005 CR4: 00000000007606e0
[ 1621.016487] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1621.024450] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[ 1621.032413] PKRU: 55555554
[ 1621.035433] Call Trace:
[ 1621.038161]  klist_del+0xe/0x10
[ 1621.041667]  device_del+0x8a/0x2c9
[ 1621.045463]  ? __switch_to_asm+0x34/0x70
[ 1621.049840]  ? __switch_to_asm+0x40/0x70
[ 1621.054220]  device_unregister+0x44/0x4f
[ 1621.058603]  nd_async_device_unregister+0x22/0x2d [libnvdimm]
[ 1621.065016]  async_run_entry_fn+0x47/0x15a
[ 1621.069588]  process_one_work+0x1a2/0x2eb
[ 1621.074064]  worker_thread+0x1b8/0x26e
[ 1621.078239]  ? cancel_delayed_work_sync+0x15/0x15
[ 1621.083490]  kthread+0xf8/0xfd
[ 1621.086897]  ? kthread_destroy_worker+0x45/0x45
[ 1621.091954]  ret_from_fork+0x1f/0x40
[ 1621.095944] Modules linked in: xt_REDIRECT xt_nat xt_CHECKSUM iptable_mangle xt_MASQUERADE xt_conntrack ipt_REJECT nf_reject_ipv4 tun bridge stp llc ebtable_filter ebtables ip6table_filter iptable_filter scsi_transport_iscsi ip6table_nat ip6_tables iptable_nat nf_nat nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 vfat fat skx_edac intel_powerclamp coretemp kvm_intel kvm irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel iTCO_wdt iTCO_vendor_support aesni_intel ipmi_si crypto_simd cryptd glue_helper ipmi_devintf ipmi_msghandler sg pcspkr dax_pmem_compat device_dax dax_pmem_core i2c_i801 pcc_cpufreq lpc_ich ioatdma wmi nfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_tables xfs libcrc32c nd_pmem nd_btt sr_mod cdrom sd_mod mgag200 drm_kms_helper syscopyarea crc32c_intel sysfillrect sysimgblt fb_sys_fops ttm megaraid_sas drm igb ahci libahci ptp libata pps_core dca i2c_algo_bit nfit libnvdimm uas usb_storage dm_mirror dm_region_hash dm_log dm_mod
[ 1621.189449] CR2: 0000000000000020
[ 1621.193169] ---[ end trace 7c3f7029ef24aa5a ]---
[ 1621.305383] RIP: 0010:klist_put+0x1b/0x6c
[ 1621.309860] Code: 48 8b 43 08 5b 41 5c 41 5d 41 5e 41 5f 5d c3 55 48 89 e5 41 56 41 89 f6 41 55 41 54 53 4c 8b 27 48 89 fb 49 83 e4 fe 4c 89 e7 <4d> 8b 6c 24 20 e8 3a d4 01 00 45 84 f6 74 10 48 8b 03 a8 01 74 02
[ 1621.330809] RSP: 0018:ffffb1a5e6727da0 EFLAGS: 00010246
[ 1621.336642] RAX: ffff956796604c00 RBX: ffff956796604c28 RCX: 0000000000000000
[ 1621.344606] RDX: ffff955000c2c4d8 RSI: 0000000000000001 RDI: 0000000000000000
[ 1621.352570] RBP: ffffb1a5e6727dc0 R08: 0000000000000002 R09: ffffffffbb54b3c0
[ 1621.360533] R10: ffffb1a5e6727d40 R11: fefefefefefefeff R12: 0000000000000000
[ 1621.368496] R13: ffff94d18dcfd000 R14: 0000000000000001 R15: ffff955000caf140
[ 1621.376460] FS:  0000000000000000(0000) GS:ffff95679f4c0000(0000) knlGS:0000000000000000
[ 1621.385490] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1621.391902] CR2: 0000000000000020 CR3: 0000009fa100a005 CR4: 00000000007606e0
[ 1621.399867] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1621.407830] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[ 1621.415793] PKRU: 55555554
[ 1621.418814] Kernel panic - not syncing: Fatal exception
[ 1621.424740] Kernel Offset: 0x39000000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
[ 1621.550711] ---[ end Kernel panic - not syncing: Fatal exception ]---


Thanks!
-jane

