Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 733C1C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 15:13:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 087F32083D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 15:13:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 087F32083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BA356B0003; Mon, 25 Mar 2019 11:13:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 774026B0006; Mon, 25 Mar 2019 11:13:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E6596B0007; Mon, 25 Mar 2019 11:13:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 20B166B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 11:13:14 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s22so116651plq.1
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 08:13:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DRFFFuypedpyni9ZzLiLCnIyphA5+60OeFwz+bX6UAY=;
        b=GGZZZpPngHNvjia0KquZN6ACSXcCzpfAKB3AMFtyWGHHIcCs2AlmwUHp8HgppioKd2
         NlwUIdNLnWkWiWYeSNzMORyKw2NWAcb0C084SHGILYDawa8U/3VI918SBxY+WdSj3qS6
         1nXzu/bkadzMh3oiMNKSEERJ8sdcm/10xrhApfV+UImF7v9TjJFC12OPo6g1F+rd9Wjv
         8Sr7EbYxnLBk6H80SCX7rTMMZFxOEZKthuR1J8/a7SVZa2qLVA+srjxNNPypBIvpMrNd
         lanaM+Q/Bohww4L0iq2/ucXZNru0NoCqm/ZAmlVxskO0TJbEjdZ6rdi8xqiMHujeCMyC
         rUlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of sakari.ailus@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=sakari.ailus@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUWGzSZIdp4LlBS9OybdvrJpvJ+5Ya+CW5l4Pt3aQzgWmCzjlNt
	rzP6opyGkJ0F/spP8ka35WVEEptPqdqWA3w0R2+7kZJ2pZ4wNrNmz39SUiU5vW72ayQgryG5lOu
	Frs3ZCRKA+nOUa3L7OHb723FEWZmnImizOwkekIXwiv0ITFXzThv6gNh7NjLMq4vJDQ==
X-Received: by 2002:a62:a509:: with SMTP id v9mr25264946pfm.64.1553526793693;
        Mon, 25 Mar 2019 08:13:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3MqHo+AYEfXedlM4yz7jWWHUEasggyzX22+E+nAtXcL2QyWvhSSAW0MTnF414XFLRcW2u
X-Received: by 2002:a62:a509:: with SMTP id v9mr25264850pfm.64.1553526792637;
        Mon, 25 Mar 2019 08:13:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553526792; cv=none;
        d=google.com; s=arc-20160816;
        b=vppAWokHrZeHCvOFJwVCCv4ST77hzotw6+Sk+hJ7GfxkR9Cc06fRolqaXs0xfNGXnj
         F20eLR3pIh+enxb0NNh6wsOGCvyWOBbtx5bqziuuD4tko+D6SQrWAJzFJsKORicrapA3
         mW+3542wUJF5dbGORrmqjcdNZSdU5KIenVcxtchZ9WUBg69uphV0/4NMgRdwghKb++yS
         kiOalQoFTEmotQOEEXzU6kcVaApScPiCyZA89nvoNh0zTpfRirYguthYi8sIaT5W5nBa
         Yv0HKrX2YHHahFS1d45qXzd/n6UzNrNRdcoqhPCJ0l8mQhdtUt3y1fJcl123YRcEyPdV
         69WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DRFFFuypedpyni9ZzLiLCnIyphA5+60OeFwz+bX6UAY=;
        b=DXg9qBc3t15Niv0KvDCzk9AuGaKqrnkMuDD7A0wjsIkjs+OYFRFx2nwA40EW1Rhu8E
         3LKcztlc7Mtrnv8WEWD39OVT/ii7PaFtl903xRhUiqKa5UeUcC0C2r0zgXZwW/h88otj
         KiNyn2Z/a3+bq2yuEoD48RnZbwon1SySlEG05t4gCWtr7ga6voafcE2RlFk7n26Kh3JA
         8FOFJnO1F29W73tebReCS1ah1x+0D53XPLDQ3/hbtjCsgBosXzyZ428sfGbXxeU73BBF
         ncfMQNPIbwggMbqwO/VtOiGRAOWPhjs98s5c5FEa3L04ImjaJ+oNFl6bTAkLTHOF7kXx
         s/MA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of sakari.ailus@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=sakari.ailus@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f34si14769034plf.343.2019.03.25.08.13.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 08:13:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of sakari.ailus@linux.intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of sakari.ailus@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=sakari.ailus@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Mar 2019 08:13:11 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,269,1549958400"; 
   d="scan'208";a="330511062"
Received: from ikahlonx-mobl.ger.corp.intel.com (HELO kekkonen.fi.intel.com) ([10.252.61.250])
  by fmsmga006.fm.intel.com with ESMTP; 25 Mar 2019 08:13:06 -0700
Received: by kekkonen.fi.intel.com (Postfix, from userid 1000)
	id 75F7A21D09; Mon, 25 Mar 2019 17:13:00 +0200 (EET)
Date: Mon, 25 Mar 2019 17:13:00 +0200
From: Sakari Ailus <sakari.ailus@linux.intel.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Petr Mladek <pmladek@suse.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	scsi <linux-scsi@vger.kernel.org>,
	Linux PM list <linux-pm@vger.kernel.org>,
	Linux MMC List <linux-mmc@vger.kernel.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	linux-um@lists.infradead.org,
	linux-f2fs-devel@lists.sourceforge.net, linux-block@vger.kernel.org,
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-btrfs <linux-btrfs@vger.kernel.org>,
	linux-pci <linux-pci@vger.kernel.org>,
	sparclinux <sparclinux@vger.kernel.org>,
	xen-devel@lists.xenproject.org,
	ceph-devel <ceph-devel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Lars Ellenberg <drbd-dev@lists.linbit.com>
Subject: Re: [PATCH 0/2] Remove support for deprecated %pf and %pF in vsprintf
Message-ID: <20190325151259.2w22y4ijqilrbaxj@kekkonen.localdomain>
References: <20190322132108.25501-1-sakari.ailus@linux.intel.com>
 <CAMuHMdVmqqjVx7As9AAywYxYXG=grijF5rF77OBn6TUjM9+xKw@mail.gmail.com>
 <20190322135350.2btpno7vspvewxvk@paasikivi.fi.intel.com>
 <20190322170550.GX9224@smile.fi.intel.com>
 <20190324211008.lypghym3gqcp62th@mara.localdomain>
 <20190324211932.GK9224@smile.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190324211932.GK9224@smile.fi.intel.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andy,

On Sun, Mar 24, 2019 at 11:19:32PM +0200, Andy Shevchenko wrote:
> On Sun, Mar 24, 2019 at 11:10:08PM +0200, Sakari Ailus wrote:
> > On Fri, Mar 22, 2019 at 07:05:50PM +0200, Andy Shevchenko wrote:
> > > On Fri, Mar 22, 2019 at 03:53:50PM +0200, Sakari Ailus wrote:
> > > 
> > > > Porting a patch
> > > > forward should have no issues either as checkpatch.pl has been complaining
> > > > of the use of %pf and %pF for a while now.
> > > 
> > > And that's exactly the reason why I think instead of removing warning on
> > > checkpatch, it makes sense to convert to an error for a while. People are
> > > tending read documentation on internet and thus might have outdated one. And
> > > yes, the compiler doesn't tell a thing about it.
> > > 
> > > P.S. Though, if majority of people will tell that I'm wrong, then it's okay to
> > > remove.
> > 
> > I wonder if you wrote this before seeing my other patchset.
> 
> Yes, I wrote it before seeing another series.
> 
> > What I think could be done is to warn of plain %pf (without following "w")
> > in checkpatch.pl, and %pf that is not followed by "w" in the kernel.
> > Although we didn't have such checks to begin with. The case is still a
> > little bit different as %pf used to be a valid conversion specifier whereas
> > %pO likely has never existed.
> > 
> > So, how about adding such checks in the other set? I can retain %p[fF] check
> > here, too, if you like.
> 
> Consistency tells me that the warning->error transformation in checkpatch.pl
> belongs this series.

All other invalid pointer conversion specifiers currently result into a
warning only. I see that as an orthogonal change to this set. I found
another issue in checkpatch.pl that may require some discussion; would you
be ok with addressing this in another set?

-- 
Regards,

Sakari Ailus
sakari.ailus@linux.intel.com

