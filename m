Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53356C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 22:51:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBF582087C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 22:51:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBF582087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4EE2A8E000A; Wed, 13 Mar 2019 18:51:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4744C8E0001; Wed, 13 Mar 2019 18:51:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 315438E000A; Wed, 13 Mar 2019 18:51:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E00668E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 18:51:14 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a6so3919393pgj.4
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:51:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kV+2XON+fhwv1QVvYOAafi8L0TSDty7Wr6ehgk5Jov8=;
        b=bVejvUCJujOf1i0AIeBWTywrT3kykeIOkm8jvpYRk8jMNHVOKo0X8HnL02ZHzejv6d
         BDsQVkw2Qylxsc91ClYsm4EFgEq+1biaVI61cym4JxbqB56fBXjaHShmi/ktMxTsMeQx
         eIWutYgoPsKYRDtfC3bRCZKEgiFF36188BOlkYXjbt3bOplVOdRsZh4GD6IUMdb78XzW
         YBK7ouZOmVKl9dFFxBsrvtMUvd9iUJE0CRpEDmTeIHoTq+mZrHNNVGqRkw9KNegPlWld
         EA0d2tTYCS9hfqiQiA42u2JFIchtO+mKYbuY3Z6McP2caq/EhId2WR515ytKcbtdl+7d
         NIRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWgqZHM7BAYMGf4ubwiq7JVa2sAyhDQgRpzpFWIJs1zb1IsI/6K
	vNpYFtRUPOxZnUcBB8znudovp6umbsdraGcheJ5ISa90pJITz7RDMDC06yMDOIpDzurWfu8yj3h
	YJ9xkFHSirwIsNFPtf6+bSvs44/kwYsiYfexiUbQWfXc2LQHIdCxOhXJbbqIJcumhSg==
X-Received: by 2002:a63:e002:: with SMTP id e2mr3326455pgh.300.1552517474444;
        Wed, 13 Mar 2019 15:51:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzs9oU8G5SsI1i8ihbZ9etNm667zH1sK7Z+GnBrJWmKFqm1fGrx8AOV6UEGVraHJyhXuNts
X-Received: by 2002:a63:e002:: with SMTP id e2mr3326410pgh.300.1552517473055;
        Wed, 13 Mar 2019 15:51:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552517473; cv=none;
        d=google.com; s=arc-20160816;
        b=vY6BR0ktgy3K2EjpytFYIw5hR+BHvyR+ZO62tPPUd2hCR7/1ipItzaQCGj6GAfYh44
         I7tW2hwtElg8BnwKnf//NgoHqnjOR6/SxNTO5vFQHLCEmLqE8KKB/RsHdtXzhNgvweO2
         ztS2n1aqbxxRv7s82QNgTvHjaG97sDczU49kECs49LrXc8ziBROJ2Lak59pFHY77EDHY
         U3PyTjBeIsHnXAR7Yw3tMiwan3mPz9Ub/zU7S634islfy8Xq3LQ2n+OvfkSm5TMhoINT
         hkbbLspMP/lpxOFDlAWvKk3y8xiwxODwxz6nhL8NEAH7xDBOd8k0AGrscZ9cVXlD4P0v
         R/cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kV+2XON+fhwv1QVvYOAafi8L0TSDty7Wr6ehgk5Jov8=;
        b=cDGWocqDfraWu+Lc7krvXQHthH8Uuq05WJ/goF974hlRBwh2pTVWEgfyp41eUyp7cr
         PB0+vHZRdehhEuAVBwt+Pie7TpHQopHvRCJ5wE0oXrwq8pHWpp0JtLyp0xVtFbf8Ryxv
         mDp1QdESz9Mu8RJKCzh/DGn+1f/bW/bxXIU94hBUol5orGrfBveaCDh46Jy+zxZSy55w
         0vWqtCIp6EhDpyUkTPhIXzfeHTsSQlPtsHYCtfdGzW5J1JfhoDY7wVbjdai8iEVKCJir
         pWO9miMhGFRI0c/Xa0LWQJgbwS7zJAaU8HMmCjys2XgI+DFwJZMbvazkd9zQg86BEXcz
         ptkw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id j26si10988892pff.289.2019.03.13.15.51.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 15:51:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Mar 2019 15:51:12 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,476,1544515200"; 
   d="scan'208";a="327081402"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga006.fm.intel.com with ESMTP; 13 Mar 2019 15:51:09 -0700
Date: Wed, 13 Mar 2019 07:49:41 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v3 1/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190313144941.GA23350@iweiny-DESK2.sc.intel.com>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <20190306235455.26348-2-jhubbard@nvidia.com>
 <20190312153033.GG1119@iweiny-DESK2.sc.intel.com>
 <c9c80511-0805-a877-af6f-b769c6dcb111@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c9c80511-0805-a877-af6f-b769c6dcb111@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 05:38:55PM -0700, John Hubbard wrote:
> On 3/12/19 8:30 AM, Ira Weiny wrote:
> > On Wed, Mar 06, 2019 at 03:54:55PM -0800, john.hubbard@gmail.com wrote:
> > > From: John Hubbard <jhubbard@nvidia.com>
> > > 
> > > Introduces put_user_page(), which simply calls put_page().
> > > This provides a way to update all get_user_pages*() callers,
> > > so that they call put_user_page(), instead of put_page().
> > 
> > So I've been running with these patches for a while but today while ramping up
> > my testing I hit the following:
> > 
> > [ 1355.557819] ------------[ cut here ]------------
> > [ 1355.563436] get_user_pages pin count overflowed
> 
> Hi Ira,
> 
> Thanks for reporting this. That overflow, at face value, means that we've
> used more than the 22 bits worth of gup pin counts, so about 4 million pins
> of the same page...

This is my bug in the patches I'm playing with.  Somehow I'm causing more puts
than gets...  I'm not sure how but this is for sure my problem.

Backing off to your patch set the numbers are good.

Sorry for the noise.

With the testing I've done today I feel comfortable adding

Tested-by: Ira Weiny <ira.weiny@intel.com>

For the main GUP and InfiniBand patches.

Ira

> 
> > [ 1355.563446] WARNING: CPU: 1 PID: 1740 at mm/gup.c:73 get_gup_pin_page+0xa5/0xb0
> > [ 1355.577391] Modules linked in: ib_isert iscsi_target_mod ib_srpt target_core_mod ib_srp scsi_transpo
> > rt_srp ext4 mbcache jbd2 mlx4_ib opa_vnic rpcrdma sunrpc rdma_ucm ib_iser rdma_cm ib_umad iw_cm libiscs
> > i ib_ipoib scsi_transport_iscsi ib_cm sb_edac x86_pkg_temp_thermal intel_powerclamp coretemp kvm irqbyp
> > ass snd_hda_codec_realtek ib_uverbs snd_hda_codec_generic crct10dif_pclmul ledtrig_audio snd_hda_intel
> > crc32_pclmul snd_hda_codec snd_hda_core ghash_clmulni_intel snd_hwdep snd_pcm aesni_intel crypto_simd s
> > nd_timer ib_core cryptd snd glue_helper dax_pmem soundcore nd_pmem ipmi_si device_dax nd_btt ioatdma nd
> > _e820 ipmi_devintf ipmi_msghandler iTCO_wdt i2c_i801 iTCO_vendor_support libnvdimm pcspkr lpc_ich mei_m
> > e mei mfd_core wmi pcc_cpufreq acpi_cpufreq sch_fq_codel xfs libcrc32c mlx4_en sr_mod cdrom sd_mod mgag
> > 200 drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops mlx4_core ttm crc32c_intel igb isci ah
> > ci dca libsas firewire_ohci drm i2c_algo_bit libahci scsi_transport_sas
> > [ 1355.577429]  firewire_core crc_itu_t i2c_core libata dm_mod [last unloaded: rdmavt]
> > [ 1355.686703] CPU: 1 PID: 1740 Comm: reg-mr Not tainted 5.0.0+ #10
> > [ 1355.693851] Hardware name: Intel Corporation W2600CR/W2600CR, BIOS SE5C600.86B.02.04.0003.1023201411
> > 38 10/23/2014
> > [ 1355.705750] RIP: 0010:get_gup_pin_page+0xa5/0xb0
> > [ 1355.711348] Code: e8 40 02 ff ff 80 3d ba a2 fb 00 00 b8 b5 ff ff ff 75 bb 48 c7 c7 48 0a e9 81 89 4
> > 4 24 04 c6 05 a1 a2 fb 00 01 e8 35 63 e8 ff <0f> 0b 8b 44 24 04 eb 9c 0f 1f 00 66 66 66 66 90 41 57 49
> > bf 00 00
> > [ 1355.733244] RSP: 0018:ffffc90005a23b30 EFLAGS: 00010286
> > [ 1355.739536] RAX: 0000000000000000 RBX: ffffea0014220000 RCX: 0000000000000000
> > [ 1355.748005] RDX: 0000000000000003 RSI: ffffffff827d94a3 RDI: 0000000000000246
> > [ 1355.756453] RBP: ffffea0014220000 R08: 0000000000000002 R09: 0000000000022400
> > [ 1355.764907] R10: 0009ccf0ad0c4203 R11: 0000000000000001 R12: 0000000000010207
> > [ 1355.773369] R13: ffff8884130b7040 R14: fff0000000000fff R15: 000fffffffe00000
> > [ 1355.781836] FS:  00007f2680d0d740(0000) GS:ffff88842e840000(0000) knlGS:0000000000000000
> > [ 1355.791384] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [ 1355.798319] CR2: 0000000000589000 CR3: 000000040b05e004 CR4: 00000000000606e0
> > [ 1355.806809] Call Trace:
> > [ 1355.810078]  follow_page_pte+0x4f3/0x5c0
> > [ 1355.814987]  __get_user_pages+0x1eb/0x730
> > [ 1355.820020]  get_user_pages+0x3e/0x50
> > [ 1355.824657]  ib_umem_get+0x283/0x500 [ib_uverbs]
> > [ 1355.830340]  ? _cond_resched+0x15/0x30
> > [ 1355.835065]  mlx4_ib_reg_user_mr+0x75/0x1e0 [mlx4_ib]
> > [ 1355.841235]  ib_uverbs_reg_mr+0x10c/0x220 [ib_uverbs]
> > [ 1355.847400]  ib_uverbs_write+0x2f9/0x4d0 [ib_uverbs]
> > [ 1355.853473]  __vfs_write+0x36/0x1b0
> > [ 1355.857904]  ? selinux_file_permission+0xf0/0x130
> > [ 1355.863702]  ? security_file_permission+0x2e/0xe0
> > [ 1355.869503]  vfs_write+0xa5/0x1a0
> > [ 1355.873751]  ksys_write+0x4f/0xb0
> > [ 1355.878009]  do_syscall_64+0x5b/0x180
> > [ 1355.882656]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> > [ 1355.888862] RIP: 0033:0x7f2680ec3ed8
> > [ 1355.893420] Code: 89 02 48 c7 c0 ff ff ff ff eb b3 0f 1f 80 00 00 00 00 f3 0f 1e fa 48 8d 05 45 78 0
> > d 00 8b 00 85 c0 75 17 b8 01 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 58 c3 0f 1f 80 00 00 00 00 41 54 49
> > 89 d4 55
> > [ 1355.915573] RSP: 002b:00007ffe65d50bc8 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
> > [ 1355.924621] RAX: ffffffffffffffda RBX: 00007ffe65d50c74 RCX: 00007f2680ec3ed8
> > [ 1355.933195] RDX: 0000000000000030 RSI: 00007ffe65d50c80 RDI: 0000000000000003
> > [ 1355.941760] RBP: 0000000000000030 R08: 0000000000000007 R09: 0000000000581260
> > [ 1355.950326] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000581930
> > [ 1355.958885] R13: 000000000000000c R14: 0000000000581260 R15: 0000000000000000
> > [ 1355.967430] ---[ end trace bc771ac6189977a2 ]---
> > 
> > 
> > I'm not sure what I did to do this and I'm going to work on a reproducer.  At
> > the time of the Warning I only had 1 GUP user?!?!?!?!
> 
> If there is a get_user_pages() call that lacks a corresponding put_user_pages()
> call, then the count could start working its way up, and up. Either that, or a
> bug in my patches here, could cause this. The basic counting works correctly
> in fio runs on an NVMe driver with Direct IO, when I dump out
> `cat /proc/vmstat | grep gup`: the counts match up, but that is a simple test.
> 
> One way to force a faster repro is to increase the GUP_PIN_COUNTING_BIAS, so
> that the gup pin count runs into the max much sooner.
> 
> I'd really love to create a test setup that would generate this failure, so
> anything you discover on how to repro (including what hardware is required--I'm
> sure I can scrounge up some IB gear in a pinch) is of great interest.
> 
> Also, I'm just now starting on the DEBUG_USER_PAGE_REFERENCES idea that Jerome,
> Jan, and Dan floated some months ago. It's clearly a prerequisite to converting
> the call sites properly--just our relatively small IB driver is showing that.
> This feature will provide a different mapping of the struct pages, if get
> them via get_user_pages(). That will allow easily asserting that put_user_page()
> and put_page() are not swapped, in either direction.
> 
> 
> > 
> > I'm not using ODP, so I don't think the changes we have discussed there are a
> > problem.
> > 
> > Ira
> > 
> 
> 
> thanks,
> -- 
> John Hubbard
> NVIDIA

