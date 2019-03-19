Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 839D4C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:24:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 292BB20835
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:24:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="XdDHSgWx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 292BB20835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4B486B0005; Tue, 19 Mar 2019 15:24:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFC536B0006; Tue, 19 Mar 2019 15:24:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE9E46B0007; Tue, 19 Mar 2019 15:24:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 72ED66B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:24:03 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f67so4566089pfh.9
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 12:24:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=s8cH6GtN38AlGs5As8/XCfKmUKmyncY/yyySe4XbvA4=;
        b=sf//WQvv/zct4GhFY3x7ADWCxTkjnew2NqyxEo0Lh23YOgcCh/ULR67SSQb3iaMb9o
         5HcJgyGAaxQPAjYbS49vwzHXRUABDV2O7LpiK+1A8hGJGIecp16gDAE134OYwLfJwsSM
         OpxGvoMlXsDYnCSfY74NTyGSxTmpqLDiviWhNyGME2KrpFcHfJmLZG4+z1alXYvmQ3xz
         M0YUZoHKcO3F5On+ifCJLsTO7zgToxuN09g9sR2pmNiFsY7xvYdDCoU/Hd0DsVSRZPWD
         lpdN8q7YQngvLccsNPBlmltu0vQETsGiAx6dLP5rW9WApEbpM21jJqeedmrDcuLxn0VB
         08ug==
X-Gm-Message-State: APjAAAWSFs4evs6ivHFPsCdrHXC6C93WCDtNnRKrYF/iLVL8JiPcBIa8
	beNTOaBLgy/XmR22LV3Km4g1kBCoMO991GHtQU2mm+58uysoyL9OtHeLdLeS47fLktF8wKSu5os
	KwQgFVJpnFoJLfTR7+22I9CIj6RUeTvRjG/bff97myQEnoOftuWkYXg37soE8OWE1TA==
X-Received: by 2002:a63:cc44:: with SMTP id q4mr3781285pgi.183.1553023443130;
        Tue, 19 Mar 2019 12:24:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzb2tVWHF6aADssCD41Uj/FexehhG+4oXGh/Z2xIZzP+lEDjpxNoveE++THIkFfx/yp457D
X-Received: by 2002:a63:cc44:: with SMTP id q4mr3781189pgi.183.1553023441978;
        Tue, 19 Mar 2019 12:24:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553023441; cv=none;
        d=google.com; s=arc-20160816;
        b=VdGcw7QxFDT0WW/2W8TRwavsptYnItKtR9TSjmb1aBD6S3jkdQQ6P6hHMK+4amH7nx
         4IrYKU5MSWMAvKtLsPPbOdZDJYqxO5229z+z7ofaM1OgamP/vVumxRtxvwkabsWtvFBc
         HglGC/F2UQ7a0OMnu3///eQTW6lsExu/Y2VDTZah3aMMNYhmSAxbOakVDBwRXHn81iwB
         fDzwrjgOAIT6qK6/mXgEVY2S3XSfANOoYSr+vtQWYkbhtXUv8F5EZWuwq2gy16E8/ZIf
         Llb1ZPUGvINh/2nSQN1Y1jh0DYIgRRA7qzsR7+PKIWvNRheDMiAqRpFAJmDseJ5CkGcn
         Eoig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=s8cH6GtN38AlGs5As8/XCfKmUKmyncY/yyySe4XbvA4=;
        b=w8++OSIpTcoGu3hIdxztFUUjyF2Yt7U+Pipr1Me0NrCCM+poa6/XthJo1GfkdTySt9
         rR/tOfRfHwXqpOPNJegLcHHwSCnd5LyN9rkxSuxwwI00a+24DE1hzFZnUcME6Z58ZmKl
         KoQ16poYcXFiYYLktyqezOw7Or4tJIFhC23JIj1iQ0wk4nYro7OXLXPsTVRaB7OOXTud
         jCjuOVWapMEc1/Gm31ehnVmRsobwoYB145ayBFFbOXDymB3RW2WmmFOhArDOlC0nJMId
         haGHvCoOEUNDMUm80SoczwB83Yr6immoLNwllUZY451jWFU7Ts6E7MG+XenMzb3zyEeM
         jr2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=XdDHSgWx;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id d34si12905618pla.89.2019.03.19.12.24.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 12:24:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=XdDHSgWx;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9141d30000>; Tue, 19 Mar 2019 12:24:03 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 19 Mar 2019 12:24:01 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 19 Mar 2019 12:24:01 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 19 Mar
 2019 19:24:00 +0000
Subject: Re: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder
 versions
To: Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov"
	<kirill@shutemov.name>
CC: <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>,
	<linux-mm@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti
	<benve@cisco.com>, Christoph Hellwig <hch@infradead.org>, Christopher Lameter
	<cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner
	<david@fromorbit.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>, Jan Kara
	<jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox
	<willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Rapoport
	<rppt@linux.ibm.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Ralph
 Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, LKML
	<linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <bf443287-2461-ea2d-5a15-251190782ab7@nvidia.com>
Date: Tue, 19 Mar 2019 12:24:00 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190319134724.GB3437@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553023443; bh=s8cH6GtN38AlGs5As8/XCfKmUKmyncY/yyySe4XbvA4=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=XdDHSgWxr8k7fXVywWGcvgHobknERbwVazMm7P2MkPdZY/S6rCF0VxJMzL0ZpARox
	 bN/CUD2JyGwBCPOBqaNLNkcKY9rkzHDvyjo9JBS50FvVGKpZUxRGKl4r6DRCxvfMZr
	 byJ2JXSvISHPFq8A2k0CzeuCoYNt0dXUElaYXZUX9DjZdrJaUQ4EMYFhTfKVkHbDJA
	 yiKr93mwLLYFgp0eb1630BtR5rxsJlJossR8U7Hwu2KLdE6aJq3Cd3K22cdbEEUCyB
	 7WXK3sOalp6C8h9FrcPFk+TaHXLv+qFpW9lt1bqdQkOe0IdlIepnavBH3+V0qs+Vyq
	 qSZYXxoBH8x8g==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/19/19 6:47 AM, Jerome Glisse wrote:
> On Tue, Mar 19, 2019 at 03:04:17PM +0300, Kirill A. Shutemov wrote:
>> On Fri, Mar 08, 2019 at 01:36:33PM -0800, john.hubbard@gmail.com wrote:
>>> From: John Hubbard <jhubbard@nvidia.com>
> 
> [...]
>>> +void put_user_pages_dirty(struct page **pages, unsigned long npages)
>>> +{
>>> +	__put_user_pages_dirty(pages, npages, set_page_dirty);
>>
>> Have you checked if compiler is clever enough eliminate indirect function
>> call here? Maybe it's better to go with an opencodded approach and get rid
>> of callbacks?
>>
> 
> Good point, dunno if John did check that.

Hi Kirill, Jerome,

The compiler does *not* eliminate the indirect function call, at least unless
I'm misunderstanding things. The __put_user_pages_dirty() function calls the
appropriate set_page_dirty*() call, via __x86_indirect_thunk_r12, which seems
pretty definitive.

ffffffff81a00ef0 <__x86_indirect_thunk_r12>:
ffffffff81a00ef0:	41 ff e4             	jmpq   *%r12
ffffffff81a00ef3:	90                   	nop
ffffffff81a00ef4:	90                   	nop
ffffffff81a00ef5:	90                   	nop
ffffffff81a00ef6:	90                   	nop
ffffffff81a00ef7:	90                   	nop
ffffffff81a00ef8:	90                   	nop
ffffffff81a00ef9:	90                   	nop
ffffffff81a00efa:	90                   	nop
ffffffff81a00efb:	90                   	nop
ffffffff81a00efc:	90                   	nop
ffffffff81a00efd:	90                   	nop
ffffffff81a00efe:	90                   	nop
ffffffff81a00eff:	90                   	nop
ffffffff81a00f00:	90                   	nop
ffffffff81a00f01:	66 66 2e 0f 1f 84 00 	data16 nopw %cs:0x0(%rax,%rax,1)
ffffffff81a00f08:	00 00 00 00 
ffffffff81a00f0c:	0f 1f 40 00          	nopl   0x0(%rax)

However, there is no visible overhead to doing so, at a macro level. An fio
O_DIRECT run with and without the full conversion patchset shows the same 
numbers:

cat fio.conf 
[reader]
direct=1
ioengine=libaio
blocksize=4096
size=1g
numjobs=1
rw=read
iodepth=64

=====================
Before (baseline):
=====================

reader: (g=0): rw=read, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64
fio-3.3
Starting 1 process

reader: (groupid=0, jobs=1): err= 0: pid=1828: Mon Mar 18 14:56:22 2019
   read: IOPS=192k, BW=751MiB/s (787MB/s)(1024MiB/1364msec)
    slat (nsec): min=1274, max=42375, avg=1564.12, stdev=682.65
    clat (usec): min=168, max=12209, avg=331.01, stdev=184.95
     lat (usec): min=171, max=12215, avg=332.61, stdev=185.11
    clat percentiles (usec):
     |  1.00th=[  326],  5.00th=[  326], 10.00th=[  326], 20.00th=[  326],
     | 30.00th=[  326], 40.00th=[  326], 50.00th=[  326], 60.00th=[  326],
     | 70.00th=[  326], 80.00th=[  326], 90.00th=[  326], 95.00th=[  326],
     | 99.00th=[  519], 99.50th=[  523], 99.90th=[  537], 99.95th=[  594],
     | 99.99th=[12125]
   bw (  KiB/s): min=755280, max=783016, per=100.00%, avg=769148.00, stdev=19612.31, samples=2
   iops        : min=188820, max=195754, avg=192287.00, stdev=4903.08, samples=2
  lat (usec)   : 250=0.14%, 500=98.59%, 750=1.25%
  lat (msec)   : 20=0.02%
  cpu          : usr=12.69%, sys=48.20%, ctx=248836, majf=0, minf=73
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
     issued rwts: total=262144,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=64

Run status group 0 (all jobs):
   READ: bw=751MiB/s (787MB/s), 751MiB/s-751MiB/s (787MB/s-787MB/s), io=1024MiB (1074MB), run=1364-1364msec

Disk stats (read/write):
  nvme0n1: ios=220106/0, merge=0/0, ticks=70136/0, in_queue=704, util=91.19%

==================================================
After (with enough callsites converted to run fio:
==================================================

reader: (g=0): rw=read, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64
fio-3.3
Starting 1 process

reader: (groupid=0, jobs=1): err= 0: pid=2026: Mon Mar 18 14:35:07 2019
   read: IOPS=192k, BW=751MiB/s (787MB/s)(1024MiB/1364msec)
    slat (nsec): min=1263, max=41861, avg=1591.99, stdev=692.09
    clat (usec): min=154, max=12205, avg=330.82, stdev=184.98
     lat (usec): min=157, max=12212, avg=332.45, stdev=185.14
    clat percentiles (usec):
     |  1.00th=[  322],  5.00th=[  326], 10.00th=[  326], 20.00th=[  326],
     | 30.00th=[  326], 40.00th=[  326], 50.00th=[  326], 60.00th=[  326],
     | 70.00th=[  326], 80.00th=[  326], 90.00th=[  326], 95.00th=[  326],
     | 99.00th=[  502], 99.50th=[  510], 99.90th=[  523], 99.95th=[  570],
     | 99.99th=[12125]
   bw (  KiB/s): min=746848, max=783088, per=99.51%, avg=764968.00, stdev=25625.55, samples=2
   iops        : min=186712, max=195772, avg=191242.00, stdev=6406.39, samples=2
  lat (usec)   : 250=0.09%, 500=98.88%, 750=1.01%
  lat (msec)   : 20=0.02%
  cpu          : usr=14.38%, sys=48.64%, ctx=248037, majf=0, minf=73
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
     issued rwts: total=262144,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=64

Run status group 0 (all jobs):
   READ: bw=751MiB/s (787MB/s), 751MiB/s-751MiB/s (787MB/s-787MB/s), io=1024MiB (1074MB), run=1364-1364msec

Disk stats (read/write):
  nvme0n1: ios=220228/0, merge=0/0, ticks=70426/0, in_queue=704, util=91.27%


So, I could be persuaded either way. But given the lack of an visible perf
effects, and given that this could will get removed anyway because we'll
likely end up with set_page_dirty() called at GUP time instead...it seems
like it's probably OK to just leave it as is.

thanks,
-- 
John Hubbard
NVIDIA

