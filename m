Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A5B1C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 17:33:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E53C121726
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 17:33:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="TdcT0ao8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E53C121726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73A376B0003; Fri, 17 May 2019 13:33:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6EC256B0005; Fri, 17 May 2019 13:33:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B3246B0006; Fri, 17 May 2019 13:33:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 086FC6B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 13:33:38 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n23so11664590edv.9
        for <linux-mm@kvack.org>; Fri, 17 May 2019 10:33:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=PAeoxF2imq2aUNGpWDXhVAfgD9B+GyCzgoCoPFLvAKA=;
        b=SWbcYtKq3bJkkjgu6OCnJzDvBcw7ZipiBHQDuIPrJcnA4Rs9Wtxz7e6tfgiRrGlh8S
         5pp9WbMNXOPYeGvQcfiQS/zKqjJ4XVT4TWCbAH97ds+GIrMjtjIL/qGNW5XYqAGYrEwA
         g1FjiZn+3hIVK91Nw0oV5LIDl5rxvQVTK9LCAu96bAIQfsKlHoPIBYMO3PRUtKK29Bxe
         z33+XL+0Fzztmhk+IUoPitlJ0wzrQ25eXWvn1GwTovgeacGvrk284P2NEFMV8ozp4nby
         DHumhJKNZTfwNri7aRZzUyGmIySHlelyJKk9WZ6gAytKTcXBLVQSnTHFZSfXIPU/O8/4
         2+TA==
X-Gm-Message-State: APjAAAXwdFbUzhLYSIO6B0w12QADOAQhGjCKw+hiGXtkSTWnhDVa1QFV
	oC9nPOZJmoZNHDLoCt1EFTamkc4I3PaBFoHYq1ecOEBQL0HjNXkjA7sPSZMN9k1/MFBkFhxAnc/
	98P/VcJS0PeMjiq2Dfs7LAOMTnoKAD+MD/4D6+8uaZFI8td6fuk3+bJjLf3oE/qMMtw==
X-Received: by 2002:a50:aef6:: with SMTP id f51mr58695542edd.225.1558114417588;
        Fri, 17 May 2019 10:33:37 -0700 (PDT)
X-Received: by 2002:a50:aef6:: with SMTP id f51mr58695457edd.225.1558114416665;
        Fri, 17 May 2019 10:33:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558114416; cv=none;
        d=google.com; s=arc-20160816;
        b=R4Jybsyq6gfXx+LGLE/y1VsFRtktB/A/n0tUnzY95HHH1BxXbibbFsVrFUQqt+/uLK
         nLNm68S+GWZZqwjBjZqNs4ppCNTRioW2dy5YzAQZqezal1GZkdDX4hsaPgfXRlD6zJQ/
         rT75ZupOcKnfZNnqjmRDqsmouVHfUfAD4H8mwyCELWvn7j1PU8KpieqM8qs6zO9mgdGF
         aB8V/si4crBGeriE+/Vrx7vlUaDAOVoREC4u7vsU3+DDWEqwynSuB46UgDJg8Po6/ufX
         d+gAhcXSiec/wAmH4PAuSEsZg2Q+dkRJ2C3gNgj9pGDdeMAyex65NKKVDrL5wzDj0/du
         rc1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=PAeoxF2imq2aUNGpWDXhVAfgD9B+GyCzgoCoPFLvAKA=;
        b=T59OAd7je5xriydZfp4BMBhLOkdEilSWb8zgGmNX5upxn0hUhwNBQ0AQP/Qu4sMX5W
         lPTYcxYQ96k0//ZtujeB5FAFmV+nCB+IyJupJAOzCKrl3gdeplSEB+JcUauWgUb3srV+
         VUZBNE3aMdf4E6a4aLcfsdjdbx3Zb2WonniYsr81NDas31mu2C7XXvYYf+a1aqCIt4i0
         WW8OpaeNbQX0r3uMWEiD7wjFkf3GsfYOw1zo8WnaaTpi65+iblqKlJK5LTlHBUD95JvL
         lFm11NHP6mwif4Arf85XIlxDm2DjPRj8RxfEdvZSgIGdpRBLmPzMp8MAO+rWktwAd9Rb
         T+KQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=TdcT0ao8;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v11sor1160719edc.7.2019.05.17.10.33.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 10:33:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=TdcT0ao8;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=PAeoxF2imq2aUNGpWDXhVAfgD9B+GyCzgoCoPFLvAKA=;
        b=TdcT0ao8wyzDXRR3baDL1GRF+OfLNOeR9/I2TulJt5JsUQb+LG08zQI8xbNjtusE+e
         ZdO/jwAn1gUii0A+VpoQhVYNUFJMQgMXJE0jIXa7NyqzFSDSf9NlEBwhugR1g8SDpoc9
         WbyDzdPHcQ0ZQnP1eCgS/i3+C79euoCv7/5ZQdnwdUGsntWsk896+MSq9mpka1A4mHEA
         vs7k3FEOKaHSHrV1aswiHY8M1nr6xdUi4F5NL9mP9N43DNpQ15spNDa7qSYXSuu0J48r
         HD4rcSYGHFfhnNYXnCOoC7xqqMm8oJBiw2cM+dwf16YmjI611f/6JfjH7qfpPAGQhBTV
         wzIA==
X-Google-Smtp-Source: APXvYqwjJ4gypFzj7i15z2ynBCtipPcuZRluChX/vOW8Yiaed+BIB651uMRUczuoRSPU78hl+CTC5PEO5Yuy/B61iJ4=
X-Received: by 2002:a50:ee01:: with SMTP id g1mr58636495eds.263.1558114416186;
 Fri, 17 May 2019 10:33:36 -0700 (PDT)
MIME-Version: 1.0
References: <CA+CK2bBeOJPnnyWBgj0CJ7E1z9GVWVg_EJAmDs07BSJDp3PYfQ@mail.gmail.com>
 <20190517143816.GO6836@dhcp22.suse.cz> <CA+CK2bA+2+HaV4GWNUNP04fjjTPKbEGQHSPrSrmY7HLD57au1Q@mail.gmail.com>
 <CA+CK2bDq+2qu28afO__4kzO4=cnLH1P4DcHjc62rt0UtYwLm0A@mail.gmail.com>
In-Reply-To: <CA+CK2bDq+2qu28afO__4kzO4=cnLH1P4DcHjc62rt0UtYwLm0A@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Fri, 17 May 2019 13:33:25 -0400
Message-ID: <CA+CK2bCgF7z5UHqrGCYu4JgG=5o6uXbjutTo9VSYAkqu3dqn5w@mail.gmail.com>
Subject: Re: NULL pointer dereference during memory hotremove
To: Michal Hocko <mhocko@kernel.org>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jmorris@namei.org" <jmorris@namei.org>, 
	"tiwai@suse.de" <tiwai@suse.de>, "sashal@kernel.org" <sashal@kernel.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "david@redhat.com" <david@redhat.com>, 
	"bp@suse.de" <bp@suse.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "jglisse@redhat.com" <jglisse@redhat.com>, 
	"zwisler@kernel.org" <zwisler@kernel.org>, "Jiang, Dave" <dave.jiang@intel.com>, 
	"bhelgaas@google.com" <bhelgaas@google.com>, "Busch, Keith" <keith.busch@intel.com>, 
	"thomas.lendacky@amd.com" <thomas.lendacky@amd.com>, "Huang, Ying" <ying.huang@intel.com>, 
	"Wu, Fengguang" <fengguang.wu@intel.com>, 
	"baiyaowei@cmss.chinamobile.com" <baiyaowei@cmss.chinamobile.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 1:24 PM Pavel Tatashin
<pasha.tatashin@soleen.com> wrote:
>
> On Fri, May 17, 2019 at 1:22 PM Pavel Tatashin
> <pasha.tatashin@soleen.com> wrote:
> >
> > On Fri, May 17, 2019 at 10:38 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Fri 17-05-19 10:20:38, Pavel Tatashin wrote:
> > > > This panic is unrelated to circular lock issue that I reported in a
> > > > separate thread, that also happens during memory hotremove.
> > > >
> > > > xakep ~/x/linux$ git describe
> > > > v5.1-12317-ga6a4b66bd8f4
> > >
> > > Does this happen on 5.0 as well?
> >
> > Yes, just reproduced it on 5.0 as well. Unfortunately, I do not have a
> > script, and have to do it manually, also it does not happen every
> > time, it happened on 3rd time for me.
>
> Actually, sorry, I have not tested 5.0, I compiled 5.0, but my script
> still tested v5.1-12317-ga6a4b66bd8f4 build. I will report later if I
> am able to reproduce it on 5.0.

OK, confirmed on 5.0 as well, took 4 tries to reproduce:
(qemu) [   17.104486] Offlined Pages 32768
[   17.105543] Built 1 zonelists, mobility grouping on.  Total pages: 1515892
[   17.106475] Policy zone: Normal
[   17.107029] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000698
[   17.107645] #PF error: [normal kernel read fault]
[   17.108038] PGD 0 P4D 0
[   17.108287] Oops: 0000 [#1] SMP PTI
[   17.108557] CPU: 5 PID: 313 Comm: kworker/u16:5 Not tainted 5.0.0_pt_pmem1 #2
[   17.109128] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.12.0-20181126_142135-anatol 04/01/2014
[   17.109910] Workqueue: kacpi_hotplug acpi_hotplug_work_fn
[   17.110323] RIP: 0010:__remove_pages+0x2f/0x520
[   17.110674] Code: 41 56 41 55 49 89 fd 41 54 55 53 48 89 d3 48 83
ec 68 48 89 4c 24 08 65 48 8b 04 25 28 00 00 00 48 89 44 24 60 31 c0
48 89 f8 <48> 2b 47 58 48 3d 00 19 00 00 0f 85 7f 03 00 00 48 85 c9 0f
84 df
[   17.112114] RSP: 0018:ffffb43b815f3ca8 EFLAGS: 00010246
[   17.112518] RAX: 0000000000000640 RBX: 0000000000040000 RCX: 0000000000000000
[   17.113073] RDX: 0000000000040000 RSI: 0000000000240000 RDI: 0000000000000640
[   17.113615] RBP: 0000000240000000 R08: 0000000000000000 R09: 0000000040000000
[   17.114186] R10: 0000000040000000 R11: 0000000240000000 R12: ffffe382c9000000
[   17.114743] R13: 0000000000000640 R14: 0000000000040000 R15: 0000000000240000
[   17.115288] FS:  0000000000000000(0000) GS:ffff979539b40000(0000)
knlGS:0000000000000000
[   17.115911] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   17.116356] CR2: 0000000000000698 CR3: 0000000133c22004 CR4: 0000000000360ee0
[   17.116913] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   17.117467] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   17.118016] Call Trace:
[   17.118214]  ? memblock_isolate_range+0xc4/0x139
[   17.118570]  ? firmware_map_remove+0x48/0x90
[   17.118908]  arch_remove_memory+0x7b/0xc0
[   17.119216]  __remove_memory+0x93/0xc0
[   17.119528]  acpi_memory_device_remove+0x67/0xe0
[   17.119890]  acpi_bus_trim+0x50/0x90
[   17.120167]  acpi_device_hotplug+0x2fc/0x460
[   17.120498]  acpi_hotplug_work_fn+0x15/0x20
[   17.120834]  process_one_work+0x2a0/0x650
[   17.121146]  worker_thread+0x34/0x3d0
[   17.121432]  ? process_one_work+0x650/0x650
[   17.121772]  kthread+0x118/0x130
[   17.122032]  ? kthread_create_on_node+0x60/0x60
[   17.122413]  ret_from_fork+0x3a/0x50
[   17.122727] Modules linked in:
[   17.122983] CR2: 0000000000000698
[   17.123250] ---[ end trace 389c4034f6d42e6f ]---
[   17.123618] RIP: 0010:__remove_pages+0x2f/0x520
[   17.123979] Code: 41 56 41 55 49 89 fd 41 54 55 53 48 89 d3 48 83
ec 68 48 89 4c 24 08 65 48 8b 04 25 28 00 00 00 48 89 44 24 60 31 c0
48 89 f8 <48> 2b 47 58 48 3d 00 19 00 00 0f 85 7f 03 00 00 48 85 c9 0f
84 df
[   17.125410] RSP: 0018:ffffb43b815f3ca8 EFLAGS: 00010246
[   17.125818] RAX: 0000000000000640 RBX: 0000000000040000 RCX: 0000000000000000
[   17.126359] RDX: 0000000000040000 RSI: 0000000000240000 RDI: 0000000000000640
[   17.126906] RBP: 0000000240000000 R08: 0000000000000000 R09: 0000000040000000
[   17.127453] R10: 0000000040000000 R11: 0000000240000000 R12: ffffe382c9000000
[   17.128008] R13: 0000000000000640 R14: 0000000000040000 R15: 0000000000240000
[   17.128555] FS:  0000000000000000(0000) GS:ffff979539b40000(0000)
knlGS:0000000000000000
[   17.129182] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   17.129627] CR2: 0000000000000698 CR3: 0000000133c22004 CR4: 0000000000360ee0
[   17.130182] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   17.130744] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   17.131293] BUG: sleeping function called from invalid context at
include/linux/percpu-rwsem.h:34
[   17.132050] in_atomic(): 0, irqs_disabled(): 1, pid: 313, name: kworker/u16:5
[   17.132596] INFO: lockdep is turned off.
[   17.132908] irq event stamp: 14046
[   17.133175] hardirqs last  enabled at (14045): [<ffffffffadbf3b1a>]
kfree+0xba/0x230
[   17.133777] hardirqs last disabled at (14046): [<ffffffffada01b03>]
trace_hardirqs_off_thunk+0x1a/0x1c
[   17.134497] softirqs last  enabled at (13446): [<ffffffffae2c804c>]
peernet2id+0x4c/0x70
[   17.135119] softirqs last disabled at (13444): [<ffffffffae2c802d>]
peernet2id+0x2d/0x70
[   17.135739] CPU: 5 PID: 313 Comm: kworker/u16:5 Tainted: G      D
        5.0.0_pt_pmem1 #2
[   17.136389] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.12.0-20181126_142135-anatol 04/01/2014
[   17.137169] Workqueue: kacpi_hotplug acpi_hotplug_work_fn
[   17.137589] Call Trace:
[   17.137792]  dump_stack+0x67/0x90
[   17.138160]  ___might_sleep.cold.87+0x9f/0xaf
[   17.138497]  exit_signals+0x2b/0x240
[   17.138794]  do_exit+0xab/0xc10
[   17.139055]  ? process_one_work+0x650/0x650
[   17.139406]  ? kthread+0x118/0x130
[   17.139686]  rewind_stack_do_exit+0x17/0x20


# uname -a
Linux pt 5.0.0 #2 SMP Fri May 17 13:28:36 EDT 2019 x86_64 GNU/Linux

