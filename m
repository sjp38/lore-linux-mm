Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86FC7C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:15:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23E0E2083B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:15:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="icMJpTY3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23E0E2083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 885F78E00A0; Thu, 21 Feb 2019 13:15:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80CB18E0094; Thu, 21 Feb 2019 13:15:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D4AC8E00A0; Thu, 21 Feb 2019 13:15:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5EE8E0094
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 13:15:16 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id b187so5960389qkf.3
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:15:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=yv34WL27/4P4RfS0vK/c/1T6Xzpdilnzi7RivTUP56o=;
        b=BjSs98DZ260epGjvFfBlkvmMUtWlslpAy9IEhNCkxJiz6eVaCzBdT6kF9WAEicR7g6
         PfFU/U6hvMbH6H+cZ5OzYeV0WUaUY6WeFikb1BIIyM1+K7VF6MFqkcTJjnD8vzCp8NsU
         +P9Q9kgk0dXlKEMABPhTXA9f+6kuQ8rSAcZzgZhEdseGJcZVIZGaKVzowl42Cc1/5m9n
         btPVRM56OUlRiA/ax7ZZ4Sb4Rx0I9wjQVXwLhK59NASiadwGUbkH1bh5VW3II5t9TqxH
         sU3jZ5c1nAneFTP0VOIez1RnNjUcFuMp+0OrWHbYSlYs4WvfFFImdW680LZjBj0MS0qO
         lj8g==
X-Gm-Message-State: AHQUAuZuii3JJKFWUoT09bHz3qhOTVs2fBAXEpUV7S7QsPHuhIxYFiZy
	XQmehnVp+K4AGuiBI6MkdVM3OcyEPbyE6jSdCQvrzwLJAgcMDsNfuobfHV0ze+sQPeTqInFtluz
	v9fYd6ofUwqpMk/6eeouGQDZq9Q9GOv5lKL8W1nRdFlEOXyjaQZZ38uDojGb9WHw=
X-Received: by 2002:a37:85c7:: with SMTP id h190mr29422739qkd.225.1550772915905;
        Thu, 21 Feb 2019 10:15:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZTYj8Ljam43qrac93+GBpbI4YkKUBdwDFRhrkVwgEi8K4PA6JS48UM2+9KxzoirVXVHE8p
X-Received: by 2002:a37:85c7:: with SMTP id h190mr29422695qkd.225.1550772915053;
        Thu, 21 Feb 2019 10:15:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550772915; cv=none;
        d=google.com; s=arc-20160816;
        b=ihl8xJS4utlauTs1te61AO8jU8I08/UYSx3f96qV1XW9CsryH2XABn1FH349VnNTxw
         pWQQeBAZUZ24z2keuVNS/7Ad19EBkQ9zUHPF24B1RpD4EOQzrmO6LjAq9UazwQ1T2+Dv
         YnxzFCONuBaWaLUMEkzlDswnkc5syBwkbgr9eYfGmX+U+m5jvtIM7Hmydo0vpbQDDbS8
         llniH1W00aJbpZa/RrNJazryBh504x+9PG7vyXTbB3U/F4tifyoHSMwJPqjhpvKRuzBc
         zPrsHfJhT8XtgB4MFlKue2KLaPWDnK347P6uKmaMhoi7UEf54NFWB7FrQ8ssHQaOmWYB
         YzfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=yv34WL27/4P4RfS0vK/c/1T6Xzpdilnzi7RivTUP56o=;
        b=P4mNA4YVPtXvg8c9DaNkkU0ii2Um+McJls1tqIyAiZncdJHS0gie6ZZmnXEfSTqMeG
         BlCA9F1Uh+si4HhNaX0DpSHiIJAp3nq1ZVVeOeHoFVqlYDYQvjocn49eHDIU6ySUE4yA
         o0/SiRz18BiqOkYU6BdnwXdg6l36GneSOZFTxDxVh5RsgtWjWE1r1LMqri7VZYeDHOdY
         4hT5nh1IfYAguf+bykVajA4SDTNbpI3W7HaHm0PPTpqI0aEfMBCR33NIszKynPY9uElS
         pwwwlg9HCqonX34zH2AKVvaQpTncrqEA5cMPbih2C1NRLOOS9EY4GeqZRGVEJU68IqLs
         BNgw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=icMJpTY3;
       spf=pass (google.com: domain of 010001691144c94b-c935fd1d-9c90-40a5-9763-2c05ef0df7f4-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=010001691144c94b-c935fd1d-9c90-40a5-9763-2c05ef0df7f4-000000@amazonses.com
Received: from a9-37.smtp-out.amazonses.com (a9-37.smtp-out.amazonses.com. [54.240.9.37])
        by mx.google.com with ESMTPS id i7si313204qvi.199.2019.02.21.10.15.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 21 Feb 2019 10:15:15 -0800 (PST)
Received-SPF: pass (google.com: domain of 010001691144c94b-c935fd1d-9c90-40a5-9763-2c05ef0df7f4-000000@amazonses.com designates 54.240.9.37 as permitted sender) client-ip=54.240.9.37;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=icMJpTY3;
       spf=pass (google.com: domain of 010001691144c94b-c935fd1d-9c90-40a5-9763-2c05ef0df7f4-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=010001691144c94b-c935fd1d-9c90-40a5-9763-2c05ef0df7f4-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1550772914;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=VKotv5gnFhWSl58uJlkmDtgmW5vNpFO0vBucsZ46CUQ=;
	b=icMJpTY3XhV9BT06pVog4fA9l0tA4Ry2Klw0Ipm6O8uYmAdpRTzFJtxoG/OfoD/y
	rmyEaDQv1ZitV3ZBXa/Bfs5Vq18eiJR06nnhFtWeSDaPuXTrPgAZNONsLIsPLCmZ7zz
	2/gYh9XRQiVrlb0yx7A7kclwIeNYkIyVSoqezeNU=
Date: Thu, 21 Feb 2019 18:15:14 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Michal Hocko <mhocko@kernel.org>
cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Subject: Re: Memory management facing a 400Gpbs network link
In-Reply-To: <20190220083157.GV4525@dhcp22.suse.cz>
Message-ID: <010001691144c94b-c935fd1d-9c90-40a5-9763-2c05ef0df7f4-000000@email.amazonses.com>
References: <01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@email.amazonses.com> <20190219122609.GN4525@dhcp22.suse.cz> <01000169062262ea-777bfd38-e0f9-4e9c-806f-1c64e507ea2c-000000@email.amazonses.com> <20190219173622.GQ4525@dhcp22.suse.cz>
 <0100016906fdc80b-4471de43-3f22-45ec-8f77-f2ff1b76d9fe-000000@email.amazonses.com> <20190219191325.GS4525@dhcp22.suse.cz> <0100016907829c4c-7593c8e2-1e01-4be4-8eec-a8aa3de00c18-000000@email.amazonses.com> <20190220083157.GV4525@dhcp22.suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.21-54.240.9.37
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2019, Michal Hocko wrote:

> > I dont like the existing approaches but I can present them?
>
> Please give us at least some rough outline so that we can evaluate a
> general interest and see how/whether to schedule such a topic.

Ok. I am fuzzy on this one too. Lets give this another shot:

In the HPC world we often have to bypass operating system mechanisms for
full speed. Usually this has been through accellerators in the network
card, in sharing memory between multiple systems (with NUMA being a
special case of this) or with devices that provide some specialized memory
access. There is a whole issue here with pinned memory access (I think
that is handled in another session at the MM summit)

The intend was typically to bring the data into the system so that an
application can act on it. However, with the increasing speeds of the
interconnect that may even be faster than the internal busses on
contemporary platforms that may have to change since the processor and the
system as a whole is no longer able to handle the inbound data stream.
This is partially due to the I/O bus speeds no longer increasing.

The solutions to this issue coming from some vendors are falling
mostly into the following categories:

A) Provide preprocessing in the NIC.

   This can compress data, modify it and direct it to certain cores of
   the system. Preprocessing may allow multiple hosts to use one NIC
   (Makes sense since a single host may no longer be able to handle the
   data).

B) Provide fast memory in the NIC

   Since the NIC is at capacity limits when it comes to pushing data
   from the NIC into memory the obvious solution is to not go to main
   memory but provide faster on NIC memory that can then be accessed
   from the host as needed. Now the applications creates I/O bottlenecks
   when accessing their data or they need to implement complicated
   transfer mechanisms to retrieve and store data onto the NIC memory.

C) Direct passthrough to other devices

   The host I/O bus is used or another enhanced bus is provided to reach
   other system components without the constraints imposed by the OS or
   hardware. This means for example that a NIC can directly write to an
   NVME storage device (f.e. NVMEoF). A NIC can directly exchange data with
   another NIC. In an extreme case a hardware addressable global data fabric
   exists that is shared between multiple systems and the devices can
   share memory areas with one another. In the ultra extreme case there
   is a bypass  even using the memory channels since non volatile memory
   (a storage device essentially) is now  supported that way.

All of this leads to the development of numerous specialized accellerators
and special mechamisms to access memory on such devices. We already see a
proliferation of various remote memory schemes (HMM, PCI device memory
etc)

So how does memory work in the systems of the future? It seems that we may
need some new way of tracking memory that is remote on some device in
additional to the classic NUMA nodes? Or can we change the existing NUMA
schemes to cover these use cases?

We need some consistent and hopefully vendor neutral way to work with
memory I think.





----- Old proposal


00G Infiniband will become available this year. This means that the data
ingest speeds can be higher than the bandwidth of the processor
interacting with its own memory.

For example a single hardware thread is limited to 20Gbyte/sec whereas the
network interface provides 50Gbytes/sec. These rates can only be obtained
currently with pinned memory.

How can we evolve the memory management subsystem to operate at higher
speeds with more the comforts of paging and system calls that we are used
to?

It is likely that these speeds with increase further and since the lead
processor vendor seems to be caught in a management induced corporate
suicide attempt we will not likely see any process on the processors from
there. The straightforward solution would be to use the high speed tech
for fabrics for the internal busses (doh!). Alternate processors are
likely to show up in 2019 and 2020 but those will take a long time to
mature.

So what does the future hold and how do we scale up our HPC systems given
these problems?

