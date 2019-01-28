Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAFA7C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 11:31:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83B8221738
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 11:31:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83B8221738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09DA38E0007; Mon, 28 Jan 2019 06:31:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04F9C8E0001; Mon, 28 Jan 2019 06:31:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E81A58E0007; Mon, 28 Jan 2019 06:31:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCA498E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 06:31:39 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id w4so6107899otj.2
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 03:31:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=mATiIp2L5KDQ3a8jzMgjpAFBkNXT74zCJEFQBA7P/Zo=;
        b=mdSdNLQ1B9gDslw7DqJM/SOOzJs+iPjIyye/5o4MAA4rZrIx0X9phjhyOswWTwpKn2
         OlMjzxUfNZXs3iooq8LfCkriS6VcEiq9GJE57JfHK/zKgVhBe6LDU6JQEHtrY+m+ZEmB
         J/HBtajeqMyueFuG2pJJUGiw1VP9MsWuC5WlNzzpWoubD1HuRJ8DhIomEeNBhFLa0YzY
         6QEal7XlI4pkSyU7fpCDMuNbZnE44o5dQudFxmsNZ9YtxwfCP+M7MLRQRXteHSamVDMV
         pKvDD2Xula9QeXxLIuifLfVchEIB32/505/iAMI3uHQVGJtlK2I0w4ICa+nxRc6Iq6ma
         ipyw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AJcUukfNfZIIO3JPEzRQk0Hy21+vQIlJ/9wbXymBIx250C0M+PjQ70TD
	8RjHURmO+mYlasKvwywqBVr+zJboIuKlEKB5C9JDVpfdxkWjiW81ChgXVQWXnRY/0Qwz6sPBRo4
	XTbs23xQNRnliBy92jbH1D3P48vQn/MaL2QNPEBfSMOpGetfwuIypTt8B0UBujE8HLQ==
X-Received: by 2002:a9d:6d81:: with SMTP id x1mr15020907otp.17.1548675099285;
        Mon, 28 Jan 2019 03:31:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6vgTyPL7R0RUmlbZvC0Bk2SttVxAjZAVZJst4LQ3HIx9qaocb467cDJtakpUTbC56R8EY8
X-Received: by 2002:a9d:6d81:: with SMTP id x1mr15020743otp.17.1548675095016;
        Mon, 28 Jan 2019 03:31:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548675095; cv=none;
        d=google.com; s=arc-20160816;
        b=PRyWMJyehznklgsO4EUvQ7QmcgGgekV/rfPX2cqAdSpUFw1z3FROZCFIlWKbhmnDHW
         NU3eXPpjmso3iA72XTvJHVqc4F3Q+36X2hJOTmkbiImc4RJqzKEJLhd5rQpHn6MNc+Xu
         0Hvjks+0ov7hibu6NbSPqNiwB9WjMUaG6s1bXlMCiLAixpGlIP6fCem3c4gK5fGpze/6
         fBES/nKcGPxeLDzBhTw1WzLnupXFdJaT2ndYXKO56i7aZJRsmIyvPp/YYnwtPtYOMFYy
         WQMLHAkvYpq9380DnpOyR6L0Lzm02oaajo838vdlKkEgoWedAG6yqrGFKN4L5B+AvamS
         ntoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=mATiIp2L5KDQ3a8jzMgjpAFBkNXT74zCJEFQBA7P/Zo=;
        b=hFyGTNihCLbHYJxFNtriB2U6pXHRkx26Cgm2aWiBNaStil4/mKnlheuKwkVJzDeQ6q
         xyhLdGPJtmpXZjYVyI3EOptPTylzclrWtwHkxEGpMc26uQ3i3Oqcpew1y1+I8tcDOWdL
         V3oYylXprhmunWqgXYJfkoGjSsNonlY4Edc/rRaPg4ZFQ0taVm4XlBrYRBsPdhSIuNvd
         58i4dvN/K9lUDDmtUsSoxCLlJec8JsX1lslfo25tR5JRnCRycHuKCU0qgmLezk8LeqWF
         93uxx4nPgMupe839eFXdSBIN61OtBtaoS9tlxGbmM3IYE3V3VCG0ZaIswfyZgmC+2gDX
         YpVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id w13si4820560oiw.238.2019.01.28.03.31.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 03:31:35 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id A1B29F49A16818FF7A10;
	Mon, 28 Jan 2019 19:31:29 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS410-HUB.china.huawei.com
 (10.3.19.210) with Microsoft SMTP Server id 14.3.408.0; Mon, 28 Jan 2019
 19:31:20 +0800
Date: Mon, 28 Jan 2019 11:31:08 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Bjorn Helgaas <helgaas@kernel.org>
CC: Dave Hansen <dave.hansen@intel.com>, <linux-pci@vger.kernel.org>,
	<x86@kernel.org>, <linuxarm@huawei.com>, Ingo Molnar <mingo@kernel.org>,
	"Dave Hansen" <dave.hansen@linux.intel.com>, Andy Lutomirski
	<luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
	<martin@geanix.com>, "Linux Memory Management List" <linux-mm@kvack.org>,
	"ACPI Devel   Maling List" <linux-acpi@vger.kernel.org>
Subject: Re: [PATCH V2] x86: Fix an issue with invalid ACPI NUMA config
Message-ID: <20190128112904.0000461a@huawei.com>
In-Reply-To: <20181220195714.GE183878@google.com>
References: <20181211094737.71554-1-Jonathan.Cameron@huawei.com>
	<a5a938d3-ecc9-028a-3b28-610feda8f3f8@intel.com>
	<20181212093914.00002aed@huawei.com>
	<20181220151225.GB183878@google.com>
	<65f5bb93-b6be-d6dd-6976-e2761f6f2a7b@intel.com>
	<20181220195714.GE183878@google.com>
Organization: Huawei
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190128113108.4bQn6n6OwKPJEMu5BQFbzcgvSkt2FW1X9m0uueAZvcc@z>

On Thu, 20 Dec 2018 13:57:14 -0600
Bjorn Helgaas <helgaas@kernel.org> wrote:

> On Thu, Dec 20, 2018 at 09:13:12AM -0800, Dave Hansen wrote:
> > On 12/20/18 7:12 AM, Bjorn Helgaas wrote:  
> > >> Other than the error we might be able to use acpi_map_pxm_to_online_node
> > >> for this, or call both acpi_map_pxm_to_node and acpi_map_pxm_to_online_node
> > >> and compare the answers to verify we are getting the node we want?  
> > > Where are we at with this?  It'd be nice to resolve it for v4.21, but
> > > it's a little out of my comfort zone, so I don't want to apply it
> > > unless there's clear consensus that this is the right fix.  
> > 
> > I still think the fix in this patch sweeps the problem under the rug too
> > much.  But, it just might be the best single fix for backports, for
> > instance.  
> 
> Sounds like we should first find the best fix, then worry about how to
> backport it.  So I think we have a little more noodling to do, and
> I'll defer this for now.
> 
> Bjorn

Hi All,

I'd definitely appreciate some guidance on what the 'right' fix is.
We are starting to get real performance issues reported as a result of not
being able to use this patch on mainline.

5-10% performance drop on some networking benchmarks.

As a brief summary (having added linux-mm / linux-acpi) the issue is:

1) ACPI allows _PXM to be applied to pci devices (including root ports for
   example, but any device is fine).
2) Due to the ordering of when the fw node was set for PCI devices this wasn't
   taking effect. Easy to solve by just adding the numa node if provided in
   pci_acpi_setup (which is late enough)
3) A patch to fix that was applied to the PCIe tree
  https://patchwork.kernel.org/patch/10597777/
   but we got non booting regressions on some threadripper platforms.
   That turned out to be because they don't have SRAT, but do have PXM entries.
  (i.e. broken firmware).  Naturally Bjorn reverted this very quickly!

I proposed this fix which was to do the same as on Arm and clearly mark numa as
off when SRAT isn't present on an ACPI system.
https://elixir.bootlin.com/linux/latest/source/arch/arm64/mm/numa.c#L460
https://elixir.bootlin.com/linux/latest/source/arch/x86/mm/numa.c#L688

Dave's response was that we needed to fix the underlying issue of trying to
allocate from non existent NUMA nodes.

Whilst I agree with that in principle (having managed to provide tables doing
exactly that during development a few times!), I'm not sure the path to doing so is
clear and so this has been stalled for a few months.  There is to my mind
still a strong argument, even with such protection in place, that we
should still be short cutting it so that you get the same paths if you deliberately
disable numa, and if you have no SRAT and hence can't have NUMA.

So given I have some 'mild for now' screaming going on, I'd definitely
appreciate input on how to move forward!

There are lots of places this could be worked around, e.g. we could sanity
check in the acpi_get_pxm call.  I'm not sure what side effects that would have
and also what cases it wouldn't cover.

Thanks,

Jonathan







