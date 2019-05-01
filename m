Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CD60C04AA8
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 19:12:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE16F2089E
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 19:12:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="KvFmuLge"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE16F2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52AB86B0005; Wed,  1 May 2019 15:12:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DA706B0006; Wed,  1 May 2019 15:12:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A3916B0007; Wed,  1 May 2019 15:12:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0086A6B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 15:12:39 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r4so4731213pfh.16
        for <linux-mm@kvack.org>; Wed, 01 May 2019 12:12:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=AmRJhTtjfmKOoXa3/mXW1aySDkpXtExm2OlSrQR+ugY=;
        b=F9ovZ79qCOCdcwOkbjmb+PLSyxl3ebh/ZDWbmq1FJpAt8ailFC/Jdg0Jsb/UtXvfF1
         9/IyrPGKrV1vezCStznKT+sSth0HzOTh4kLI+8WqxkxT3P1+Ivssu1SgwotYeL8DdEnw
         bCC00VGJiwYt47X53pU7a+5bLw4Bj4RvAD371Km8cJAHXARGLmZn81CKA5FQcIwRxqNf
         brorp+0DTYPHcchv6yRRF7VqlOH+6wPU3FZIrE2xCeTRGAaQR9Ps/VDzsTd6DPt20lP7
         7d4MLabGnmQesQl8/uSy7QJhC5vtpRcogk2KjBi/FRaMgj3T+9JCVss1roF9fuB+KWix
         lcTg==
X-Gm-Message-State: APjAAAWZMLbPjeYeiTldL/ZohnR2oNANHz3UWElHQs2cqj3XYiN55viT
	km8Od6PG119RghoTa2db+6dXYisQHtKjYTdZ2TyTEAM3FEuEaIqyMDVfkhA+EtYZ5l9HL8WvKdv
	uTsyL9ALkMmqbSUAjU5VkpK2bgwZC2UbtgxplvJkUceNdiW637irl7LOZRCCsTramQA==
X-Received: by 2002:a17:902:1024:: with SMTP id b33mr76609003pla.46.1556737958464;
        Wed, 01 May 2019 12:12:38 -0700 (PDT)
X-Received: by 2002:a17:902:1024:: with SMTP id b33mr76608920pla.46.1556737957219;
        Wed, 01 May 2019 12:12:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556737957; cv=none;
        d=google.com; s=arc-20160816;
        b=l4vG63qO98By5kgXG2X9xzKgFWfaFW51nbEVQfaYWyIaFyRksbxBzCWu2D5WB07OBr
         SoPZZMnSIgHGEu5GF2uEH+ZrOnRxqzGHilR8xtV2oTxGOPMqvt3QXzZkAjUfGn7J33WO
         FKCvtvHQn419wXaU20MvRaVh4WIvDMVmMp78UPqim3L60rxv+1aEeM44kp1Y+edglc2k
         K+CRN5aKSIJ5cql+FSWkunzRzO84u5TBYLxboAElVpxJywNCP0bWkkq1B1FFlVSUNZtg
         4PA09GDemn2qHOSPPMrY9MVoDzVPcH7B/GgfcE6w8MXocnK69onkkjoFOfx88WBAgdB3
         f/eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=AmRJhTtjfmKOoXa3/mXW1aySDkpXtExm2OlSrQR+ugY=;
        b=fmFFJyQLhbakpgmD+qkQSFMqAPQhPfQ+mdzg/6dTG4EkcmzNXIMATm5N0stDfYJgIJ
         Qu9HynUZIWkoV3NemnQBJfHMnd5m/G0Gf139PMWwx9vYsxTnrLMCmLGN/B8w9vcSJb0d
         TjqSXCgJilniJfn0dzdmkOmzTPANo5f7bD9xnSa9ay/5o/gnm4UPmix6nuyl1VnXvTXi
         pThZuQ1j8BLcklj34ljI/bCfc5VIyn2fO6z5Tn2Kb67rUEiptxriZBCUxbOxaEQkVTYN
         kX/fZYRIHJXt3HEUOLjnD9mVDYgwo64zezjrVJsZKgqjQTqrLbS3eWnRfg2ZfxjxDgMI
         DxpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KvFmuLge;
       spf=pass (google.com: domain of brho@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=brho@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e23sor15821697pgv.49.2019.05.01.12.12.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 May 2019 12:12:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of brho@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=KvFmuLge;
       spf=pass (google.com: domain of brho@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=brho@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=AmRJhTtjfmKOoXa3/mXW1aySDkpXtExm2OlSrQR+ugY=;
        b=KvFmuLges6lzqL86Wp4gV1PjIrKF2kIQ/Yx5XZyG3wDE/yk+PZ0IVgcKRTiSxkGLmY
         1emllscLGeYik7SfWUbHKjEFkULGXLTyFTx9+jjwTcyIvZJasqta7kh2z2r7mjT4cSeQ
         4hpXBEfzBwkCxMI4TwM79Gtu32AExBI1rbCo+PlgaIzg6sFgQZ1vzOM2KigHWiYPUXkV
         QprpwrRd079y/Nxc/lpMMk7S3HRq7u7hQQfE0+wWT5en57lOtJB1ulKZXaSkWzxyQFsf
         hIRjjYWDacbrRvIdvx85yv5+PzzwpDEUVEAE3ELVQoXlTXAWk0klZ2IZZdCPBZD3/AhY
         hUWA==
X-Google-Smtp-Source: APXvYqy31d2sjh8GWh1zvaBPPWQhuKan83tMATfhwqSzWvN6oZmlGEUpR+06ZSdcPU34fmyVNmOyUg==
X-Received: by 2002:a63:66c1:: with SMTP id a184mr13541136pgc.412.1556737956127;
        Wed, 01 May 2019 12:12:36 -0700 (PDT)
Received: from gnomeregan.cam.corp.google.com ([2620:15c:6:14:ad22:1cbb:d8fa:7d55])
        by smtp.googlemail.com with ESMTPSA id j12sm15835555pff.148.2019.05.01.12.12.33
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 12:12:35 -0700 (PDT)
Subject: Re: [PATCH 1/2] x86, numa: always initialize all possible nodes
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Dave Hansen <dave.hansen@intel.com>,
 Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>,
 linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org,
 LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
 Michal Hocko <mhocko@suse.com>
References: <20190212095343.23315-1-mhocko@kernel.org>
 <20190212095343.23315-2-mhocko@kernel.org>
From: Barret Rhoden <brho@google.com>
Message-ID: <34f96661-41c2-27cc-422d-5a7aab526f87@google.com>
Date: Wed, 1 May 2019 15:12:32 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190212095343.23315-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi -

This patch triggered an oops for me (more below).

On 2/12/19 4:53 AM, Michal Hocko wrote:
[snip]
> Fix the issue by reworking how x86 initializes the memory less nodes.
> The current implementation is hacked into the workflow and it doesn't
> allow any flexibility. There is init_memory_less_node called for each
> offline node that has a CPU as already mentioned above. This will make
> sure that we will have a new online node without any memory. Much later
> on we build a zone list for this node and things seem to work, except
> they do not (e.g. due to nr_cpus). Not to mention that it doesn't really
> make much sense to consider an empty node as online because we just
> consider this node whenever we want to iterate nodes to use and empty
> node is obviously not the best candidate. This is all just too fragile.

The problem might be in here - I have a case with a 'memoryless' node 
that has CPUs that get onlined during SMP boot, but that onlining 
triggers a page fault during device registration.

I'm running on a NUMA machine but I marked all of the memory on node 1 
as type 12 (PRAM), using the memmap arg.  That makes node 1 appear to 
have no memory.

During SMP boot, the fault is in bus_add_device():

	error = sysfs_create_link(&bus->p->devices_kset->kobj,

bus->p is NULL.

That p is the subsys_private struct, and it should have been set in

	postcore_initcall(register_node_type);

But that happens after SMP boot.  This fault happens during SMP boot.

The old code had set this node online via alloc_node_data(), so when it 
came time to do_cpu_up() -> try_online_node(), the node was already up 
and nothing happened.

Now, it attempts to online the node, which registers the node with 
sysfs, but that can't happen before the 'node' subsystem is registered.

My modified e820 map looks like this:

> [    0.000000] user: [mem 0x0000000000000100-0x000000000009c7ff] usable
> [    0.000000] user: [mem 0x000000000009c800-0x000000000009ffff] reserved
> [    0.000000] user: [mem 0x00000000000e0000-0x00000000000fffff] reserved
> [    0.000000] user: [mem 0x0000000000100000-0x0000000073216fff] usable
> [    0.000000] user: [mem 0x0000000073217000-0x0000000075316fff] reserved
> [    0.000000] user: [mem 0x0000000075317000-0x00000000754f8fff] ACPI data
> [    0.000000] user: [mem 0x00000000754f9000-0x0000000076057fff] ACPI NVS
> [    0.000000] user: [mem 0x0000000076058000-0x0000000077ae9fff] reserved
> [    0.000000] user: [mem 0x0000000077aea000-0x0000000077ffffff] usable
> [    0.000000] user: [mem 0x0000000078000000-0x000000008fffffff] reserved
> [    0.000000] user: [mem 0x00000000fd000000-0x00000000fe7fffff] reserved
> [    0.000000] user: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
> [    0.000000] user: [mem 0x0000000100000000-0x00000004ffffffff] usable
> [    0.000000] user: [mem 0x0000000500000000-0x000000603fffffff] persistent (type 12)

Which leads to an empty zone 1:

> [    0.016060] Initmem setup node 0 [mem 0x0000000000001000-0x00000004ffffffff]
> [    0.073310] Initmem setup node 1 [mem 0x0000000000000000-0x0000000000000000]

The backtrace:

> [    2.175327] Call Trace:
> [    2.175327]  device_add+0x43e/0x690
> [    2.175327]  device_register+0x107/0x110
> [    2.175327]  __register_one_node+0x72/0x150
> [    2.175327]  __try_online_node+0x8f/0xd0
> [    2.175327]  try_online_node+0x2b/0x50
> [    2.175327]  do_cpu_up+0x46/0xf0
> [    2.175327]  cpu_up+0x13/0x20
> [    2.175327]  smp_init+0x6e/0xd0
> [    2.175327]  kernel_init_freeable+0xe5/0x21f
> [    2.175327]  ? rest_init+0xb0/0xb0
> [    2.175327]  kernel_init+0xf/0x180
> [    2.175327]  ? rest_init+0xb0/0xb0
> [    2.175327]  ret_from_fork+0x1f/0x30

To get it booting again, I unconditionally node_set_online:

arch/x86/mm/numa.c
@@ -583,7 +583,7 @@ static int __init numa_register_memblks(struct 
numa_meminfo *mi)
                         continue;

                 alloc_node_data(nid);
-               if (end)
+               //if (end)
                         node_set_online(nid);
         }

A more elegant solution may be to avoid registering with sysfs during 
early boot, or something else entirely.  But I figured I'd ask for help 
at this point.  =)

Thanks,

Barret

