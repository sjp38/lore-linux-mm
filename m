Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96B46C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 22:46:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 351BD206DF
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 22:46:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="VyGHNfvl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 351BD206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5FC06B0007; Thu,  2 May 2019 18:46:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0F366B0008; Thu,  2 May 2019 18:46:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD86C6B000A; Thu,  2 May 2019 18:46:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 63C3C6B0007
	for <linux-mm@kvack.org>; Thu,  2 May 2019 18:46:22 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c1so880691edi.20
        for <linux-mm@kvack.org>; Thu, 02 May 2019 15:46:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=GA6AE3nbkJUtYedDned7ovjPAtRn38Gv/WcLw3WyhRM=;
        b=rLU0fDxvdE0r8SU/FdWjQgsre0cfeWUFPNkYT565S28JBQx2V3xTnoTfVruVA+pyLS
         5r0SSSDmwi0YDeZBQeCCH7cuJT4t0h/HIYRhH7Ftmv3pPlx7oSZVFdNlfvREmsf5KaCl
         BP+/J3miAqzYmo/bSO8nYqmPT4m8UKbFhyJt7ykPOdqjbuM3lp0Plh9mnS3CC7sK19Pj
         561KwxjIL/uHhekLXNanODqGuo41viwTPum05uhVsH1bA5vXIeu9ZCvpb6RBYMp1/uxu
         H6GoMV3WbG9d+/+wllRbrolZL0g+LnMYWnXfTMzRUAAOgz1UD1LFbTyiwzkMJGllvCDW
         frGg==
X-Gm-Message-State: APjAAAV9m8H7NDv1l0DgjHLipFg9qyD2twrMsGobaOeZ5UihHS4KclZC
	AXwT5rRuI5AL6Ax4A7mjC+NV9kZtcwihnI1ZscXQNb8XoN3HwVpbTHVZlhIzCcMkgpslb7C8utC
	Om1DbbT4pWagn8xfzbSln9gS0uEu6JuBFlH9KLZrdnBVcvLMRzTUXQ787P4qvBCHtLg==
X-Received: by 2002:aa7:db50:: with SMTP id n16mr4378178edt.108.1556837181975;
        Thu, 02 May 2019 15:46:21 -0700 (PDT)
X-Received: by 2002:aa7:db50:: with SMTP id n16mr4378114edt.108.1556837181075;
        Thu, 02 May 2019 15:46:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556837181; cv=none;
        d=google.com; s=arc-20160816;
        b=ECxrZ6n1Hyk60e1/01vh+9jr46n8MGwWe3pnH/VmCoumV7CMWoDR1d5xgCvaTV4QgJ
         As7iCX9xSWI4fGcoAk4QIc2QyvihlKOPwR97C6ouqlcaahZPU2wEBRBIJig39mEVPHPd
         c+DWlFeswCDP2Xmh6FD0BrW5m+oIaT7UBTVFz86xpk05G5zyjjVLOh9U1X6XnDgkdKTA
         JQSR+nOeNb6tqDV98R5qHteTS/Pctd5R8zCetLnC+VAinYI/fDM5i2l3F35y306GCcbL
         VWg2p0J7EoOhq9eufLK437oZSfMEzH8dRQ+KjunmnUk26b+5NjX14OmxH391EzSy7j1w
         9Iww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=GA6AE3nbkJUtYedDned7ovjPAtRn38Gv/WcLw3WyhRM=;
        b=UsZWPL9vp43kBdLV/siz0m7y/hDLdfTWuyZA1IP57Y9i/8WtXsr8JAz3lMNpckAmkG
         XN7fg5w7QFHaSUda4gzP7o1XpZjOEDrJMFwNICmSPNTDE/RfJ75lTC82J23R5jKYlWG7
         QFVYsDBmE5sSWz4niml6Hf7nUmhLqKsF/v4CZ2FAGzVvGeMdmHSLsy3NQqMe4R/pHp82
         X0L9Diz97dxo4/3t8K0Av8mH9ydZHUiCtrbi1YBkqOLN5UX5j2ywboqfQ3qTXzJCGvPh
         cWN4yM3nmQ1THjaFWeqDXcDXxpj2qyi4HBnvIWQ/y1xY5a7vkysHgZoadyZEQKGt6r/Y
         vAsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=VyGHNfvl;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i6sor243052edd.12.2019.05.02.15.46.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 15:46:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=VyGHNfvl;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=GA6AE3nbkJUtYedDned7ovjPAtRn38Gv/WcLw3WyhRM=;
        b=VyGHNfvlwO8ONwk/KifhHlo6j+UxiIO6vZVAJEIh/1HVZiBQdm6hsv7Pe0s7LBhtib
         DYwvUG89sAGEQgMraZsleAVrkfz3yCSF5e3mdty7AI3w8fvGzLvrD6iNdbwKzPPO6tB2
         WB6DAwnVzZVm4VW3ZepbbgIK47+nbIKMwSPeEpBw3fktP/V2czpbTX5jTue1sPbgj/eG
         6O2VZ1pwM/NbdV22t+0aEDCpaSSB5dVP9kd5aYfREuFkFv28OxBKfCldjaWjhv274Pe7
         2KZs9Qw1vLvH2eDnNdOeFw5/7sMhPbarlsTLuWEEHjLPnsnzTcCJN1/Gaatld2q9auYL
         jgjQ==
X-Google-Smtp-Source: APXvYqyxp62Y9u8Dg6nAw9ZEhyrJmqsbIRm9Uomm765huXXDRUc3RQdFsZu/ihmrxpq8Al0EC7JMIkEOIXHtl4sV7+o=
X-Received: by 2002:a50:fb19:: with SMTP id d25mr4513007edq.61.1556837180746;
 Thu, 02 May 2019 15:46:20 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 2 May 2019 18:46:09 -0400
Message-ID: <CA+CK2bBT=goxf5KWLhca7uQutUj9670aL9r02_+BsJ+bLkjj=g@mail.gmail.com>
Subject: Re: [PATCH v6 00/12] mm: Sub-section memory hotplug support
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand <david@redhat.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>, Jeff Moyer <jmoyer@redhat.com>, 
	Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Dan,

How do you test these patches? Do you have any instructions?

I see for example that check_hotplug_memory_range() still enforces
memory_block_size_bytes() alignment.

Also, after removing check_hotplug_memory_range(), I tried to online
16M aligned DAX memory, and got the following panic:

# echo online > /sys/devices/system/memory/memory7/state
[  202.193132] WARNING: CPU: 2 PID: 351 at drivers/base/memory.c:207
memory_block_action+0x110/0x178
[  202.193391] Modules linked in:
[  202.193698] CPU: 2 PID: 351 Comm: sh Not tainted
5.1.0-rc7_pt_devdax-00038-g865af4385544-dirty #9
[  202.193909] Hardware name: linux,dummy-virt (DT)
[  202.194122] pstate: 60000005 (nZCv daif -PAN -UAO)
[  202.194243] pc : memory_block_action+0x110/0x178
[  202.194404] lr : memory_block_action+0x90/0x178
[  202.194506] sp : ffff000016763ca0
[  202.194592] x29: ffff000016763ca0 x28: ffff80016fd29b80
[  202.194724] x27: 0000000000000000 x26: 0000000000000000
[  202.194838] x25: ffff000015546000 x24: 00000000001c0000
[  202.194949] x23: 0000000000000000 x22: 0000000000040000
[  202.195058] x21: 00000000001c0000 x20: 0000000000000008
[  202.195168] x19: 0000000000000007 x18: 0000000000000000
[  202.195281] x17: 0000000000000000 x16: 0000000000000000
[  202.195393] x15: 0000000000000000 x14: 0000000000000000
[  202.195505] x13: 0000000000000000 x12: 0000000000000000
[  202.195614] x11: 0000000000000000 x10: 0000000000000000
[  202.195744] x9 : 0000000000000000 x8 : 0000000180000000
[  202.195858] x7 : 0000000000000018 x6 : ffff000015541930
[  202.195966] x5 : ffff000015541930 x4 : 0000000000000001
[  202.196074] x3 : 0000000000000001 x2 : 0000000000000000
[  202.196185] x1 : 0000000000000070 x0 : 0000000000000000
[  202.196366] Call trace:
[  202.196455]  memory_block_action+0x110/0x178
[  202.196589]  memory_subsys_online+0x3c/0x80
[  202.196681]  device_online+0x6c/0x90
[  202.196761]  state_store+0x84/0x100
[  202.196841]  dev_attr_store+0x18/0x28
[  202.196927]  sysfs_kf_write+0x40/0x58
[  202.197010]  kernfs_fop_write+0xcc/0x1d8
[  202.197099]  __vfs_write+0x18/0x40
[  202.197187]  vfs_write+0xa4/0x1b0
[  202.197295]  ksys_write+0x64/0xd8
[  202.197430]  __arm64_sys_write+0x18/0x20
[  202.197521]  el0_svc_common.constprop.0+0x7c/0xe8
[  202.197621]  el0_svc_handler+0x28/0x78
[  202.197706]  el0_svc+0x8/0xc
[  202.197828] ---[ end trace 57719823dda6d21e ]---

Thank you,
Pasha

