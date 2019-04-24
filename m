Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1CE7C282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:49:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F84F20674
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:49:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F84F20674
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=linux.microsoft.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F43A6B0005; Wed, 24 Apr 2019 15:49:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17AA56B0006; Wed, 24 Apr 2019 15:49:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 042666B0007; Wed, 24 Apr 2019 15:48:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id BDEE66B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 15:48:59 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b12so12462248pfj.5
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 12:48:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=RKjNePx9D/ECdRDdmO66lIWVGsVfD2+1fIN9qgzCcOg=;
        b=bkBMTcup61vqjp/XgcoAuq7gpWTjZ4s2j37QbIZVXODTDF3fyeUtrSbx0laCj+Aaqj
         FY2Hf1f8opm3HjHVO66BpRbKVNHJyIwbxfBbZQGaOubVnRgu1XhxKHujuBmQLZVgcRfh
         HQnnOtN0MHZaJ+CDZxTV2FNMWA40rMeRFtf9XkOY50yt0v5bqGc7K22IVQrrNTedZ44F
         2G+I33Ah3llZDeK9YKQmlKWvywQH6G+jjWZKh7IeqWHy1NTswX2bWaijCBuVDbOYBrLQ
         /uPxe1YvC8YF24WSgLTdxIZ1QlbYylyIC3NzxFe9fPrRNkaFxZY5sr+fMmfM/P4pOPeW
         h4aw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of patatash@linux.microsoft.com designates 13.77.154.182 as permitted sender) smtp.mailfrom=patatash@linux.microsoft.com;       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=microsoft.com
X-Gm-Message-State: APjAAAVai/lhSthnAn8frUsyWKgRVBf34VAGAnk8C0jDOUliozXGgovJ
	j36lLJOQFQdjwu/rMR1JIxt1ewWBFQTX+IWlruBOs3+25UEbaWmHHxkSrf1uUAX9fhbEP8mdp9d
	ickQ1aNKCaLlDFc2HA3zTQwdVk1WsBjmXCrNJ0nRoWsNPr/EJ+WePNn5zjL1J0desnQ==
X-Received: by 2002:aa7:8392:: with SMTP id u18mr36379005pfm.217.1556135339388;
        Wed, 24 Apr 2019 12:48:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdQDEjEbuAULNOZ0LaSSMQcPN7IPQo3gARQRz8n45dtVxD4jc5X8ofGHnjXPwro2iOiVYr
X-Received: by 2002:aa7:8392:: with SMTP id u18mr36378946pfm.217.1556135338535;
        Wed, 24 Apr 2019 12:48:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556135338; cv=none;
        d=google.com; s=arc-20160816;
        b=bzvWg9MjzKn+mqB9oiVcdQGlZwAfEwR8Ajt2+p031GEvo5SEnemeGLNZCsqYTdmhu8
         rjoosFj9BtSSU0TRwE7Moc25g9aYqhjy0B0MCbTeo7sBzYRa1HI0LEdrR26cW72zvGFq
         Qf2TDyCA0SsYIFnxR4RMJzh5B4pKk13/uvUnRuvEg+JLpXMfLnH8ShHTjSoXmDcD0mRr
         /RiQLhig1SYJD5o0zjbitXYKHzIqalNIm3sadx4eCQPmpMaJe4o1FAUu/glHMscHuknz
         THWj0qhiH2ETCQkst4WFOsCF29NvS9zfPB4y0SwMdY4+J4Fgih6KxkG2CC5os6F3RIGa
         xY+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=RKjNePx9D/ECdRDdmO66lIWVGsVfD2+1fIN9qgzCcOg=;
        b=vacs1oyJX6UKjkFcaT9CyKfW6jxhJbk82J7g3k0KWHF9Z1EqAl4nHZlfiFNq+MSz6Q
         vMqLKTFFaYEReKKIytIPOcU0JZSCny8LZI+WsmCA3antoG05PoAz4g9Ou/TviqeOZaJB
         Jhihqffwrt4vYBxXCI0FuGgQEJ1JRsxdG9FLZ1rZE7QfPNQArljK89fz1DQlmWuK5QoP
         QCF30C6KTnO05RNYecwXo96rySrIrAuC43hoKWBMzj/zTBUy18ltLv8b7taOjfNyrueN
         gwRma63//Z2o7HGypVxhsYSbM7eQ9qnbHms7ZH9AbYKv0V8qE58bcsN816ZkIFkvCTK1
         W4ow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of patatash@linux.microsoft.com designates 13.77.154.182 as permitted sender) smtp.mailfrom=patatash@linux.microsoft.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=microsoft.com
Received: from linux.microsoft.com ([13.77.154.182])
        by mx.google.com with ESMTP id m10si908894pgp.478.2019.04.24.12.48.58
        for <linux-mm@kvack.org>;
        Wed, 24 Apr 2019 12:48:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of patatash@linux.microsoft.com designates 13.77.154.182 as permitted sender) client-ip=13.77.154.182;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of patatash@linux.microsoft.com designates 13.77.154.182 as permitted sender) smtp.mailfrom=patatash@linux.microsoft.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=microsoft.com
Received: from mail-ed1-f44.google.com (mail-ed1-f44.google.com [209.85.208.44])
	by linux.microsoft.com (Postfix) with ESMTPSA id 595C530CB914
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 12:48:57 -0700 (PDT)
Received: by mail-ed1-f44.google.com with SMTP id y67so17052776ede.2
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 12:48:57 -0700 (PDT)
X-Received: by 2002:a17:906:b291:: with SMTP id q17mr17493373ejz.56.1556135335559;
 Wed, 24 Apr 2019 12:48:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190423203843.2898-1-pasha.tatashin@soleen.com> <7f7499bd-8d48-945b-6d69-60685a02c8da@arm.com>
In-Reply-To: <7f7499bd-8d48-945b-6d69-60685a02c8da@arm.com>
From: Pavel Tatashin <patatash@linux.microsoft.com>
Date: Wed, 24 Apr 2019 15:48:44 -0400
X-Gmail-Original-Message-ID: <CA+CK2bCD11x64pJj5gSnsu5jsUqJyU6o+=J4K8oYAsHqz9ULqQ@mail.gmail.com>
Message-ID: <CA+CK2bCD11x64pJj5gSnsu5jsUqJyU6o+=J4K8oYAsHqz9ULqQ@mail.gmail.com>
Subject: Re: [PATCH] arm64: configurable sparsemem section size
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>, 
	Vishal L Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, 
	Ross Zwisler <zwisler@kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>, 
	"Huang, Ying" <ying.huang@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, 
	Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	catalin.marinas@arm.com, Will Deacon <will.deacon@arm.com>, rppt@linux.vnet.ibm.com, 
	Ard Biesheuvel <ard.biesheuvel@linaro.org>, andrew.murray@arm.com, james.morse@arm.com, 
	Marc Zyngier <marc.zyngier@arm.com>, sboyd@kernel.org, 
	linux-arm-kernel@lists.infradead.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 5:07 AM Anshuman Khandual
<anshuman.khandual@arm.com> wrote:
>
> On 04/24/2019 02:08 AM, Pavel Tatashin wrote:
> > sparsemem section size determines the maximum size and alignment that
> > is allowed to offline/online memory block. The bigger the size the less
> > the clutter in /sys/devices/system/memory/*. On the other hand, however,
> > there is less flexability in what granules of memory can be added and
> > removed.
>
> Is there any scenario where less than a 1GB needs to be added on arm64 ?

Yes, DAX hotplug loses 1G of memory without allowing smaller sections.
Machines on which we are going to be using this functionality have 8G
of System RAM, therefore losing 1G is a big problem.

For details about using scenario see this cover letter:
https://lore.kernel.org/lkml/20190421014429.31206-1-pasha.tatashin@soleen.com/

>
> >
> > Recently, it was enabled in Linux to hotadd persistent memory that
> > can be either real NV device, or reserved from regular System RAM
> > and has identity of devdax.
>
> devdax (even ZONE_DEVICE) support has not been enabled on arm64 yet.

Correct, I use your patches to enable ZONE_DEVICE, and  thus devdax on ARM64:
https://lore.kernel.org/lkml/1554265806-11501-1-git-send-email-anshuman.khandual@arm.com/

>
> >
> > The problem is that because ARM64's section size is 1G, and devdax must
> > have 2M label section, the first 1G is always missed when device is
> > attached, because it is not 1G aligned.
>
> devdax has to be 2M aligned ? Does Linux enforce that right now ?

Unfortunately, there is no way around this. Part of the memory can be
reserved as persistent memory via device tree.
        memory@40000000 {
                device_type = "memory";
                reg = < 0x00000000 0x40000000
                        0x00000002 0x00000000 >;
        };

        pmem@1c0000000 {
                compatible = "pmem-region";
                reg = <0x00000001 0xc0000000
                       0x00000000 0x80000000>;
                volatile;
                numa-node-id = <0>;
        };

So, while pmem is section aligned, as it should be, the dax device is
going to be pmem start address + label size, which is 2M. The actual
DAX device starts at:
0x1c0000000 + 2M.

Because section size is 1G, the hotplug will able to add only memory
starting from
0x1c0000000 + 1G

> 27 and 28 do not even compile for ARM64_64_PAGES because of MAX_ORDER and
> SECTION_SIZE mismatch.

Can you please elaborate what configs are you using? I have no
problems compiling with 27 and 28 bit.

Thank you,
Pasha

