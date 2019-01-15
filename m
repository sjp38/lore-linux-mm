Return-Path: <SRS0=hkLx=PX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E0CFC43387
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 05:32:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE14720651
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 05:32:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="m6fF8bXI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE14720651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FE138E0003; Tue, 15 Jan 2019 00:32:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AADF8E0002; Tue, 15 Jan 2019 00:32:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C12D8E0003; Tue, 15 Jan 2019 00:32:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 642638E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 00:32:39 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id v3so1706370itf.4
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 21:32:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=H/Olo4Zo97UTApRdojgY9u8WeJGg3GDT9ZjHatNwaRQ=;
        b=neaHaRYShrEGt6ypfRZU23CJkeseyzkfA/DpF9zYefomSJS03DJICrajZ9ftTAY82M
         0pDP19yuKgmdDzZKBFO1vfMcT0p9BLzyhe7TcybtBKyop6rJPwBNq2tCZEw6ZYb7zhpR
         kN5EkK/xFSl/WFY+UKB11brsGxkjk4YYt/qRrfaucuarLIE60qVUPiTJIxkoDDX48K7F
         VwM8wWRFjSmv+8cIS6aoS2Oll2EFvopLL5busbOLbanprTT/3HSkFqpfQxojwyJ+2Kow
         5nUXdowq299OBCs68IZ9wFJIkbR/OJzxzzenD9mU2JadwKlU74SC0JthdSGZlQcNNnCi
         y3bg==
X-Gm-Message-State: AJcUuken5cNVdPMPhohc9wOgWElxsUY38nM95qw1zRxhEySQQ0kT51Ej
	VKSygM4+y8bXiQ87j+fSSDX5G+B2r8KYc3/b8rPLMPyVPHYSdEULRpEGB+EtK4Q0PSFDJ3TI2Ac
	pzFFYw63hGxiTa8ZlMuraygQoj0WqtC0mc59gdIkKTRRdW3lMm0wGw7pIiz5f3gXlHsnr4cB2qX
	yo3PZ2gKzl4rqF+oGWew1ZJG8lzfeQx+TmqLgYB37KQJm7y+PeBDCYGv9zqugxmrz4+gbyaysRN
	mwZP8Vf6NKhivaiOQ47dmc49bwDX2jfxmEOmAeTzWmIedUG0a2sOY1Ta+S2P2cKjj6/9fgrIoQF
	jyUHOI1tllHa1h79/xAVyvKCeHkBHLe4R7gzmLjj6GIJJZv1XO6mXMBr3DpzIqJY1MBj6/5SLLl
	p
X-Received: by 2002:a6b:2b95:: with SMTP id r143mr1089180ior.217.1547530359153;
        Mon, 14 Jan 2019 21:32:39 -0800 (PST)
X-Received: by 2002:a6b:2b95:: with SMTP id r143mr1089165ior.217.1547530358491;
        Mon, 14 Jan 2019 21:32:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547530358; cv=none;
        d=google.com; s=arc-20160816;
        b=x8fEmCJOQSNnP0WxeduTynKNLYFGYJljevBnITyQuKsxb1LpmDIrDP5s9eLZzBJYdE
         Fm3fsLiwcRUnilP1aeiXT9jUyr1BBlw1PWJogjQxsnAHEFv56xOLejQjChY8t+oNimdp
         dsC6yHFMavF/JnTuvBLc1W5SoBhCtURxhffK+a/C9Sq4wPhUuGjXhIFG2jEhGu0kKiWD
         aher+9lUVDMWUEsnVsYz6MHsCNv+c4P6Tmdyu9nOWyC4EZFrbJmgzxcSQknMTSdE1628
         29XMhY+bwi+2r9mhuj/q07N3AQRMRuRHsE/QzNDYD9/rOlZNpMHugPU1qlk55iozwTTJ
         CWeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=H/Olo4Zo97UTApRdojgY9u8WeJGg3GDT9ZjHatNwaRQ=;
        b=AO7ku0xR7JdAcOcJmwkRF/E8YYVgMXz5Zv00Oj6DhBP/8BGUrXpFDX4m/MngnhoPsB
         PcONOgmYov1FibctpEMtTTttAZF5UlBc4c4yUix6EXbSGKeUvrsFhuxxMR13z7Xdy3vv
         anP1a5wsl83CLVIK8FHkncNHzYWL/FatJ3MGZxsH9Bbadm6u8amHy8vF/h+4G3COwa0g
         BpgkSIpWhr6+vhAVakxm/zBhhyd425bABBfFwR4R5zTnSswjXkKpNjjbj7XsgKv1XYkU
         uMlqyglZOv15vOKEyP3DPES0hxYJmtxMRCmkeRkZlIj7Ii1YRqj4849fO6VL6NPD4fRz
         aU4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=m6fF8bXI;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o185sor4000358ito.8.2019.01.14.21.32.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 21:32:38 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=m6fF8bXI;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=H/Olo4Zo97UTApRdojgY9u8WeJGg3GDT9ZjHatNwaRQ=;
        b=m6fF8bXIVc6PWxgcCfFajs4IaHv7C0LorIWbySRC2P5gkUZfYyidyACmBfCbkdlqBu
         2SvZXnzDqtsqwAadvs/m29LnUoU6VaRQ8HJ+qamcCGIUZl/IaWKwjTn/YKcqnkSr5bCF
         +XCiNjzzt9f5jrM3uvakBSKBl3BRCMTtaDmW7fNREoIt7cn2cQfV8CXqoSAk7kwkHUpr
         V0UxIg6vkn1RQJpHm2me+/aeajx6MYJbMk5dO6TdCrp8pVEzBvdN3l6mX3l82+pyDDz8
         GRFQwIHqf2Qazm0YwazgrIE3Pv6/b4KxxuN2dYE3a78RDocIkp+lThSHLxl+rB+8Lgdq
         K2CQ==
X-Google-Smtp-Source: ALg8bN5O2lFzZTWu9TqA8JEFzWVvOWjL1NUo8it6as3mUcu/spjDS7kq3BiHGG9R0CwV9dXZcpnV/rdIvwa6dDOvGok=
X-Received: by 2002:a24:7a94:: with SMTP id a142mr1314367itc.88.1547530358246;
 Mon, 14 Jan 2019 21:32:38 -0800 (PST)
MIME-Version: 1.0
References: <20190114082416.30939-1-mhocko@kernel.org> <87pnszzg9s.fsf@concordia.ellerman.id.au>
In-Reply-To: <87pnszzg9s.fsf@concordia.ellerman.id.au>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 15 Jan 2019 13:32:26 +0800
Message-ID:
 <CAFgQCTsEtjKnCdUb=0d9aTNL94L1=XQGDtot=2MqmqQ-fqmr1g@mail.gmail.com>
Subject: Re: [RFC PATCH] x86, numa: always initialize all possible nodes
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, 
	Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tony Luck <tony.luck@intel.com>, 
	linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, 
	LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190115053226.6Y-Ca23jUPA6GYqC0rXbpAfBM5sy0x0Y6gInftHZHE0@z>

[...]
> >
> > I would appreciate a help with those architectures because I couldn't
> > really grasp how the memoryless nodes are really initialized there. E.g.
> > ppc only seem to call setup_node_data for online nodes but I couldn't
> > find any special treatment for nodes without any memory.
>
> We have a somewhat dubious hack in our hotplug code, see:
>
> e67e02a544e9 ("powerpc/pseries: Fix cpu hotplug crash with memoryless nodes")
>
> Which basically onlines the node when we hotplug a CPU into it.
>
This bug should be related with the present state of numa node during
boot time. On PowerNV and PSeries, the boot code seems not to bring up
all nodes if memoryless. Then it can not avoid this bug.

Thanks,
Pingfan

