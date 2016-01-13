Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 83EEF6B0268
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 07:32:39 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id t15so144141963igr.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 04:32:39 -0800 (PST)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com. [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id 94si4709086iom.28.2016.01.13.04.32.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 04:32:39 -0800 (PST)
Received: by mail-ig0-x22c.google.com with SMTP id z14so149520804igp.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 04:32:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPub14_fh0vZDZ+dHP1Jihi1_x0k54p_rO4NL2TqXGXGia9qYA@mail.gmail.com>
References: <5674A5C3.1050504@oracle.com>
	<alpine.DEB.2.20.1512210656120.7119@east.gentwo.org>
	<CAPub148SiOaVQbnA0AHRRDme7nyfeDKjYHEom5kLstqaE8ibZA@mail.gmail.com>
	<alpine.DEB.2.20.1601120603250.4490@east.gentwo.org>
	<CAPub14_fh0vZDZ+dHP1Jihi1_x0k54p_rO4NL2TqXGXGia9qYA@mail.gmail.com>
Date: Wed, 13 Jan 2016 18:02:38 +0530
Message-ID: <CAPub14-rsUfP00D4J6ttwLAD-72SccYKakp2ZCncGzhPgNC21Q@mail.gmail.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
From: Shiraz Hashim <shiraz.linux.kernel@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Jan 13, 2016 at 5:06 PM, Shiraz Hashim
<shiraz.linux.kernel@gmail.com> wrote:
>
> Can you please give it a try, seems it is reproducing easily at your end.
>

Ahh!, it cannot be done as it is called with preemption disabled.

[    8.131226] Process swapper/4 (pid: 0, stack limit = 0xffffffc06fc18058)
[    8.137908] Call trace:
[    8.140344] [<ffffffc0000c19cc>] __might_sleep+0x15c/0x16c
[    8.145812] [<ffffffc0000b3d64>] flush_work+0x3c/0x190
[    8.150933] [<ffffffc0000b4450>] __cancel_work_timer+0x138/0x1e4
[    8.156922] [<ffffffc0000b45a8>] cancel_delayed_work_sync+0xc/0x18
[    8.163087] [<ffffffc0001782dc>] quiet_vmstat+0x3c/0x60
[    8.168294] [<ffffffc0000dd2f0>] cpu_startup_entry+0x2c/0x330
[    8.174024] [<ffffffc000090b24>] secondary_start_kernel+0x124/0x134

-- 
regards
Shiraz Hashim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
