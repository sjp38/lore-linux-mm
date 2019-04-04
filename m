Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E68BEC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 17:18:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89A9A206BA
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 17:18:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="m92GlC4U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89A9A206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C8F86B0010; Thu,  4 Apr 2019 13:18:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1773D6B026A; Thu,  4 Apr 2019 13:18:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03F3A6B026B; Thu,  4 Apr 2019 13:18:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE31A6B0010
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 13:18:10 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e19so2164516pfd.19
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 10:18:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=2gnZpfLx2SGsquTBuuZIgEnDFdOAOjSRDoTrCcLLYUE=;
        b=rt/sfLYNDnzO8eun9uNcAcWJX9DHRYNqHeU+o8SRsAXKDf9GC72C39EzAtBuVWtvE8
         svmtgIiRaDgjY/aC0EtAgjmFbfFleRpXriIKC7GbAe2WLufExyFQfBI5xLtg2NHChEaK
         k43vOwYKGQvOFgBpVnsauDPP39l/OxNkVYNfbWA6lkegQckSfzxcVSBL2/KX1MQcHWAp
         KmXYsiFX749BI0hhSyyKcmX1MJPCdFN+xrRddW6bHD7JFasb3BpC8EAdErtbKYjhvedT
         Z16S9Zsvm92Omwp9Xi3BqIePx96CmUZWKm8mDNSFL1UN7PFZOO69606SE9thL6NHYy1g
         bL5A==
X-Gm-Message-State: APjAAAV0RGxyNJTxyeL9Jgf/rI47lKrvFeWn0p5kE+xNwkwX2N+A35Ap
	grLltXc2ByP8kqMMkX2/hHv64iyexFqQwUFP/pOMpnDXeuouPYUzgIB+sVxi1d3bhSMdjnrbRgi
	QlxRb+s8WGHIbBoPrOL8A5mIv/90ZFtMD3shcboCHbZwnk5Y1NY5uy77t8XDOS6k80A==
X-Received: by 2002:a17:902:1e2:: with SMTP id b89mr7720872plb.278.1554398290194;
        Thu, 04 Apr 2019 10:18:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNLDgffvi65F8BHFYaCOPoObgHI4jsPMx1SzkgdJanL+pd1ZhdeiW7MuJ2d0SXWmdfGSJ6
X-Received: by 2002:a17:902:1e2:: with SMTP id b89mr7720799plb.278.1554398289229;
        Thu, 04 Apr 2019 10:18:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554398289; cv=none;
        d=google.com; s=arc-20160816;
        b=C8jM+PN4frayOeDoAhczb5CZSCEtRspoMX9nZM9WWrus3Fjjiws9VSZGj7xSoTmPmD
         X3Eu46q4YBEigU51S/tYSHridFWCWFn9cT+GqpkdZkoD0foZ/Cu/P7nEI4G1Qlig89sc
         jW4EioLk2g/LIeFUtkfCK+unzZkJw3gzoLUy7yOWPLUp//lsO/Ui2tZjeSpDP7eJ3wMX
         vIijkxVVWC+Neow8ufoGoxGGNpcGpqGig8nmHPrNP1xqOLVum1uG+n9uMCycb/zPDz2+
         0DA3huYTNrasj1YUos5OGKtm+TQ11e8K3dIkt7GxSafIvpiLPZI+o+X74ozxmjMgt9S5
         G2FA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=2gnZpfLx2SGsquTBuuZIgEnDFdOAOjSRDoTrCcLLYUE=;
        b=NhGpNIusNQqcm1bcEYdnoWMMuW1dR2r7fjBPY/F329V9JhNSL9J9B9t9j1lSH2qKJp
         nqgGHAd47FGQHgkUiYbzmqmmYNruJ2V7p/ZlqvKSbBlS3E/znee+bM1Gywe2GS0wxNvw
         JgtgZt/iHNs1OL23d93p9HfX64AqudsjSXROdqikSpzpCiyqnGhQVQZnK+z2E72Qwjh/
         DYeFpXgzh93sIMPOca0b2zf578fD8YzK06lc7Vgaq66vbPagARMm4Q91zlrTLLV1xTQU
         Johl0eEzaNd3XxZ0M/yJsU779OSnE72NpoWonidIgWfg8Top1u7UyE9Duij8udSoNPQ+
         lFYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=m92GlC4U;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id k14si16361985pll.126.2019.04.04.10.18.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 10:18:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=m92GlC4U;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x34H8ujE143134;
	Thu, 4 Apr 2019 17:18:05 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=2gnZpfLx2SGsquTBuuZIgEnDFdOAOjSRDoTrCcLLYUE=;
 b=m92GlC4Ue96N9rSiECgyxTlPHgeb0airlJZPymt+NEs9mUUqQHm0J3jDEvYunKVdwXTy
 /edNPuXiFl5zsGf+w1/OP+AYK2YGXCGmHNBaZEc8Nwnqs1a5rw2budWjcdyCxvaSy632
 6zRWDM4KwwacHFV2Efgu0sqM8IA5B9rfGd0r3RUwf8UFiQVU0qFLSECyzD/Wv6g1+B7g
 xxHLLcUn9CR4gN+QAjUopwlvCgO3BU+NySoNHryaH51kSd93BqG4AZ0XmaAK3LEacbjn
 TJ0eh1CMWmBBKJkv7Z1PrQPFVRnFU3qaFJlKoj+nIYkdgvRbd6adXK1vhaQFpPYGSpQL 9w== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2rhyvtgjxw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 04 Apr 2019 17:18:04 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x34HHP6F128583;
	Thu, 4 Apr 2019 17:18:04 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2rm9mjrpsx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 04 Apr 2019 17:18:04 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x34HI2rS027763;
	Thu, 4 Apr 2019 17:18:02 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 04 Apr 2019 10:18:02 -0700
Subject: Re: [RFC PATCH v9 00/13] Add support for eXclusive Page Frame
 Ownership
To: Nadav Amit <nadav.amit@gmail.com>
Cc: X86 ML <x86@kernel.org>, linux-arm-kernel@lists.infradead.org,
        "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
        Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
        Linux-MM <linux-mm@kvack.org>,
        LSM List <linux-security-module@vger.kernel.org>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <3F95B70B-7910-4150-A9D3-05C4D0195B67@gmail.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <e8081e89-3fe2-a6b8-119d-8981cd62c6e0@oracle.com>
Date: Thu, 4 Apr 2019 11:18:02 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <3F95B70B-7910-4150-A9D3-05C4D0195B67@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9217 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904040110
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9217 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904040110
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/4/19 10:44 AM, Nadav Amit wrote:
>> On Apr 3, 2019, at 10:34 AM, Khalid Aziz <khalid.aziz@oracle.com> wrot=
e:
>>
>> This is another update to the work Juerg, Tycho and Julian have
>> done on XPFO.
>=20
> Interesting work, but note that it triggers a warning on my system due =
to
> possible deadlock. It seems that the patch-set disables IRQs in
> xpfo_kunmap() and then might flush remote TLBs when a large page is spl=
it.
> This is wrong, since it might lead to deadlocks.
>=20
>=20
> [  947.262208] WARNING: CPU: 6 PID: 9892 at kernel/smp.c:416 smp_call_f=
unction_many+0x92/0x250
> [  947.263767] Modules linked in: sb_edac vmw_balloon crct10dif_pclmul =
crc32_pclmul joydev ghash_clmulni_intel input_leds intel_rapl_perf serio_=
raw mac_hid sch_fq_codel ib_iser rdma_cm iw_cm ib_cm ib_core vmw_vsock_vm=
ci_transport vsock vmw_vmci iscsi_tcp libiscsi_tcp libiscsi scsi_transpor=
t_iscsi ip_tables x_tables autofs4 btrfs zstd_compress raid10 raid456 asy=
nc_raid6_recov async_memcpy async_pq async_xor async_tx libcrc32c xor rai=
d6_pq raid1 raid0 multipath linear hid_generic usbhid hid vmwgfx drm_kms_=
helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm aesni_intel =
psmouse aes_x86_64 crypto_simd cryptd glue_helper mptspi vmxnet3 scsi_tra=
nsport_spi mptscsih ahci mptbase libahci i2c_piix4 pata_acpi
> [  947.274649] CPU: 6 PID: 9892 Comm: cc1 Not tainted 5.0.0+ #7
> [  947.275804] Hardware name: VMware, Inc. VMware Virtual Platform/440B=
X Desktop Reference Platform, BIOS 6.00 07/28/2017
> [  947.277704] RIP: 0010:smp_call_function_many+0x92/0x250
> [  947.278640] Code: 3b 05 66 fc 4e 01 72 26 48 83 c4 10 5b 41 5c 41 5d=
 41 5e 41 5f 5d c3 8b 05 2b cc 7e 01 85 c0 75 bf 80 3d a8 99 4e 01 00 75 =
b6 <0f> 0b eb b2 44 89 c7 48 c7 c2 a0 9a 61 aa 4c 89 fe 44 89 45 d0 e8
> [  947.281895] RSP: 0000:ffffafe04538f970 EFLAGS: 00010046
> [  947.282821] RAX: 0000000000000000 RBX: 0000000000000006 RCX: 0000000=
000000001
> [  947.284084] RDX: 0000000000000000 RSI: ffffffffa9078d70 RDI: fffffff=
faa619aa0
> [  947.285343] RBP: ffffafe04538f9a8 R08: ffff9d7040000ff0 R09: 0000000=
000000000
> [  947.286596] R10: 0000000000000000 R11: 0000000000000000 R12: fffffff=
fa9078d70
> [  947.287855] R13: 0000000000000000 R14: 0000000000000001 R15: fffffff=
faa619aa0
> [  947.289118] FS:  00007f668b122ac0(0000) GS:ffff9d727fd80000(0000) kn=
lGS:0000000000000000
> [  947.290550] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  947.291569] CR2: 00007f6688389004 CR3: 0000000224496006 CR4: 0000000=
0003606e0
> [  947.292861] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000=
000000000
> [  947.294125] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000=
000000400
> [  947.295394] Call Trace:
> [  947.295854]  ? load_new_mm_cr3+0xe0/0xe0
> [  947.296568]  on_each_cpu+0x2d/0x60
> [  947.297191]  flush_tlb_all+0x1c/0x20
> [  947.297846]  __split_large_page+0x5d9/0x640
> [  947.298604]  set_kpte+0xfe/0x260
> [  947.299824]  get_page_from_freelist+0x1633/0x1680
> [  947.301260]  ? lookup_address+0x2d/0x30
> [  947.302550]  ? set_kpte+0x1e1/0x260
> [  947.303760]  __alloc_pages_nodemask+0x13f/0x2e0
> [  947.305137]  alloc_pages_vma+0x7a/0x1c0
> [  947.306378]  wp_page_copy+0x201/0xa30
> [  947.307582]  ? generic_file_read_iter+0x96a/0xcf0
> [  947.308946]  do_wp_page+0x1cc/0x420
> [  947.310086]  __handle_mm_fault+0xc0d/0x1600
> [  947.311331]  handle_mm_fault+0xe1/0x210
> [  947.312502]  __do_page_fault+0x23a/0x4c0
> [  947.313672]  ? _cond_resched+0x19/0x30
> [  947.314795]  do_page_fault+0x2e/0xe0
> [  947.315878]  ? page_fault+0x8/0x30
> [  947.316916]  page_fault+0x1e/0x30
> [  947.317930] RIP: 0033:0x76581e
> [  947.318893] Code: eb 05 89 d8 48 8d 04 80 48 8d 34 c5 08 00 00 00 48=
 85 ff 74 04 44 8b 67 04 e8 de 80 08 00 81 e3 ff ff ff 7f 48 89 45 00 8b =
10 <44> 89 60 04 81 e2 00 00 00 80 09 da 89 10 c1 ea 18 83 e2 7f 88 50
> [  947.323337] RSP: 002b:00007ffde06c0e40 EFLAGS: 00010202
> [  947.324663] RAX: 00007f6688389000 RBX: 0000000000000004 RCX: 0000000=
000000001
> [  947.326317] RDX: 0000000000000000 RSI: 0000000001000001 RDI: 0000000=
000000017
> [  947.327973] RBP: 00007f66883882d8 R08: 00000000032e05f0 R09: 00007f6=
68b30e6f0
> [  947.329619] R10: 0000000000000002 R11: 00000000032e05f0 R12: 0000000=
000000000
> [  947.331260] R13: 00007f6688388230 R14: 00007f6688388288 R15: 00007f6=
68ac3b0a8
> [  947.332911] ---[ end trace 7d605a38c67d83ae ]---
>=20

Thanks for letting me know. xpfo_kunmap() is not quite right. It will
end up being rewritten for the next version.

--
Khalid

