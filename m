Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D9AAC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:47:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3E922084D
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:47:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3E922084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A7428E0002; Mon, 18 Feb 2019 03:47:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 104D48E0001; Mon, 18 Feb 2019 03:47:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D64988E0002; Mon, 18 Feb 2019 03:47:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4578C8E0001
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:47:15 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id a72so11325436pfj.19
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 00:47:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language;
        bh=p9aj5xJJHJGlTeXhRRrIRuoE1uYOwsK9lDh3Aamj970=;
        b=KBl5td3JaEqOQzD8lAjil5iiyN9GRq4CRZtEBItMvF0taqv4wNo+RrRTlfBhbGrwl+
         wvMXzcMTtr1q7a+LMWc6VqJ8DLC+ERWsYJNqY/6+weFU5CdshfcGEfsk9XwFXNHNh4JC
         8xzX+KeZHGfRK0vj/UyUoRF9nGV8jm6LZ6GB4pR+Le357AUidQEFSCDLfvK2nXQU6a9L
         2kb5DNAAy2KEvmBbOmYTjiL/HyPKdtku/+A0QcWE9UM0KLjIP2FHYgcl8pHz8Zzqmt5V
         CUpjCFBEL9RPyUxlu3vyEyx/U8lNKl8Hzn9wg2lJe+TuIyr6Xjh/al0DwlTzYqSqWWGv
         +EqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rong.a.chen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZeEVw8a7agX5JHkwTXAaUqqQBizBYskQymOI8LYRYJ4+yeneDb
	LbI79uwXHoP+ZOSETrTobGLfMkW00nzPjp3BHuCenBIpVBnbgauJh6GF5QDHv3G58M4/YqVNyGO
	7TQCdYx2Q4QkbiI8r8JOguwjfMlikfXLR7vJbAGVv4QCXYR5ddHIdZ6jYOqNDAmDAvg==
X-Received: by 2002:a17:902:6a3:: with SMTP id 32mr24024743plh.319.1550479634550;
        Mon, 18 Feb 2019 00:47:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IarQ4H6U8CSQUpyfjgXOxCQEBhxVORHzJP2mahdUvvj++bGD2twiweGDJrIf6ORviyQFoNm
X-Received: by 2002:a17:902:6a3:: with SMTP id 32mr24024619plh.319.1550479632218;
        Mon, 18 Feb 2019 00:47:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550479632; cv=none;
        d=google.com; s=arc-20160816;
        b=yvh/ouo7XVViFiZocONctTrattH0IBtB3yoLQHoVUSbXP0z6GJLTHSdgfKDQcclg4L
         4FF9cF8I0cUi0ChjuzKRQQxAqTRh5s6ICSWPS7LEZfREQrsS6hzUNZVsgYAdVO7IYMdt
         NZ7BdLaiZRorbuCkmWS7KlUDTiATU/jWPubAiKin5luIcxrmatVN5e0HutNsYPfUnZlW
         b+L75UnJfTc/bZQTtX9+PxufG7Y829VTza1XJF3xj2qWilyh3tCnaZphRTT8HTn2OGPB
         aDajDRrTei2wBbd3bbFBQ7hgZsrs/LVBBFsOcyFK7g0xLGRF+NTm9BWNUx21ZuFpVstU
         fNwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:in-reply-to:mime-version:user-agent:date
         :message-id:from:references:cc:to:subject;
        bh=p9aj5xJJHJGlTeXhRRrIRuoE1uYOwsK9lDh3Aamj970=;
        b=kkJCzbEgdVeQS4uNFai4M84eGvay/Nweww7Zhs+7TN8Fa2FPzXIarY0WnKRGNMNXWf
         z3Ap5FO0SGw7haDPzzY4OIPC3eDtfh4A2dlbBVNDGfhUm/4PZWSd572PCwXjH1JkTO5q
         gajz8l5imK6MShY7Qp3KBxUOq3vPa2Zgx7n7OvNOOM6MFA9TavNM2aq6/6nfm51+TZkI
         v+HSeZUOQCHKS3+8lvI771KTVKge5wsPbkHfmrvTRz4Vvuz95AV1XS2PsIeHakGb18MA
         9XKBVQszO/W8X/E6V5uxFB2+b0yQbVUV9i5LaMEOaYBch00aEHVNNmW3oWCP1Q8VRR2N
         SqyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rong.a.chen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id g3si12073923pgq.61.2019.02.18.00.47.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 00:47:12 -0800 (PST)
Received-SPF: pass (google.com: domain of rong.a.chen@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rong.a.chen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Feb 2019 00:47:11 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,384,1544515200"; 
   d="scan'208";a="321244619"
Received: from shao2-debian.sh.intel.com (HELO [10.239.13.107]) ([10.239.13.107])
  by fmsmga005.fm.intel.com with ESMTP; 18 Feb 2019 00:47:08 -0800
Subject: Re: [LKP] efad4e475c [ 40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
To: Michal Hocko <mhocko@kernel.org>
Cc: Oscar Salvador <osalvador@suse.de>,
 Andrew Morton <akpm@linux-foundation.org>,
 Linux Memory Management List <linux-mm@kvack.org>,
 linux-kernel@vger.kernel.org, LKP <lkp@01.org>
References: <20190218052823.GH29177@shao2-debian>
 <20190218070844.GC4525@dhcp22.suse.cz>
From: Rong Chen <rong.a.chen@intel.com>
Message-ID: <79a3d305-1d96-3938-dc14-617a9e475648@intel.com>
Date: Mon, 18 Feb 2019 16:47:26 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190218070844.GC4525@dhcp22.suse.cz>
Content-Type: multipart/mixed;
 boundary="------------8AA4B2326A15E0CDFA751ECC"
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------8AA4B2326A15E0CDFA751ECC
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit


On 2/18/19 3:08 PM, Michal Hocko wrote:
> On Mon 18-02-19 13:28:23, kernel test robot wrote:
>> Greetings,
>>
>> 0day kernel testing robot got the below dmesg and the first bad commit is
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>>
>> commit efad4e475c312456edb3c789d0996d12ed744c13
>> Author:     Michal Hocko <mhocko@suse.com>
>> AuthorDate: Fri Feb 1 14:20:34 2019 -0800
>> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
>> CommitDate: Fri Feb 1 15:46:23 2019 -0800
>>
>>      mm, memory_hotplug: is_mem_section_removable do not pass the end of a zone
>>      
>>      Patch series "mm, memory_hotplug: fix uninitialized pages fallouts", v2.
>>      
>>      Mikhail Zaslonko has posted fixes for the two bugs quite some time ago
>>      [1].  I have pushed back on those fixes because I believed that it is
>>      much better to plug the problem at the initialization time rather than
>>      play whack-a-mole all over the hotplug code and find all the places
>>      which expect the full memory section to be initialized.
>>      
>>      We have ended up with commit 2830bf6f05fb ("mm, memory_hotplug:
>>      initialize struct pages for the full memory section") merged and cause a
>>      regression [2][3].  The reason is that there might be memory layouts
>>      when two NUMA nodes share the same memory section so the merged fix is
>>      simply incorrect.
>>      
>>      In order to plug this hole we really have to be zone range aware in
>>      those handlers.  I have split up the original patch into two.  One is
>>      unchanged (patch 2) and I took a different approach for `removable'
>>      crash.
>>      
>>      [1] http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com
>>      [2] https://bugzilla.redhat.com/show_bug.cgi?id=1666948
>>      [3] http://lkml.kernel.org/r/20190125163938.GA20411@dhcp22.suse.cz
>>      
>>      This patch (of 2):
>>      
>>      Mikhail has reported the following VM_BUG_ON triggered when reading sysfs
>>      removable state of a memory block:
>>      
>>       page:000003d08300c000 is uninitialized and poisoned
>>       page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
>>       Call Trace:
>>         is_mem_section_removable+0xb4/0x190
>>         show_mem_removable+0x9a/0xd8
>>         dev_attr_show+0x34/0x70
>>         sysfs_kf_seq_show+0xc8/0x148
>>         seq_read+0x204/0x480
>>         __vfs_read+0x32/0x178
>>         vfs_read+0x82/0x138
>>         ksys_read+0x5a/0xb0
>>         system_call+0xdc/0x2d8
>>       Last Breaking-Event-Address:
>>         is_mem_section_removable+0xb4/0x190
>>       Kernel panic - not syncing: Fatal exception: panic_on_oops
>>      
>>      The reason is that the memory block spans the zone boundary and we are
>>      stumbling over an unitialized struct page.  Fix this by enforcing zone
>>      range in is_mem_section_removable so that we never run away from a zone.
>>      
>>      Link: http://lkml.kernel.org/r/20190128144506.15603-2-mhocko@kernel.org
>>      Signed-off-by: Michal Hocko <mhocko@suse.com>
>>      Reported-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
>>      Debugged-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
>>      Tested-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
>>      Tested-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
>>      Reviewed-by: Oscar Salvador <osalvador@suse.de>
>>      Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>>      Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>>      Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>>      Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>>      Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>>
>> 9bcdeb51bd  oom, oom_reaper: do not enqueue same task twice
>> efad4e475c  mm, memory_hotplug: is_mem_section_removable do not pass the end of a zone
>> f17b5f06cb  Linux 5.0-rc4
>> 7a92eb7cc1  Add linux-next specific files for 20190215
>> +-----------------------------------------------------+------------+------------+----------+---------------+
>> |                                                     | 9bcdeb51bd | efad4e475c | v5.0-rc4 | next-20190215 |
>> +-----------------------------------------------------+------------+------------+----------+---------------+
>> | boot_successes                                      | 31         | 2          | 21       | 0             |
>> | boot_failures                                       | 0          | 11         | 6        | 10            |
>> | Oops:#[##]                                          | 0          | 11         |          |               |
>> | RIP:page_mapping                                    | 0          | 11         |          |               |
>> | WARNING:at_kernel/locking/lockdep.c:#lock_downgrade | 0          | 3          |          |               |
>> | RIP:lock_downgrade                                  | 0          | 3          |          |               |
>> | Kernel_panic-not_syncing:Fatal_exception            | 0          | 11         | 0        | 10            |
>> | BUG:unable_to_handle_kernel                         | 0          | 6          |          |               |
>> | BUG:kernel_in_stage                                 | 0          | 0          | 6        |               |
>> | kernel_BUG_at_include/linux/mm.h                    | 0          | 0          | 0        | 10            |
>> | invalid_opcode:#[##]                                | 0          | 0          | 0        | 10            |
>> | RIP:is_mem_section_removable                        | 0          | 0          | 0        | 10            |
>> +-----------------------------------------------------+------------+------------+----------+---------------+
>>
>> udevd[311]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:v00001234d00001111sv00001AF4sd00001100bc03sc00i00': No such file or directory
>> udevd[312]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:QEMU0002:': No such file or directory
>> udevd[314]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv platform:Fixed MDIO bus': No such file or directory
>> udevd[315]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:PNP0103:': No such file or directory
>> [   40.305212] PGD 0 P4D 0
>> [   40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
>> [   40.313055] CPU: 1 PID: 239 Comm: udevd Not tainted 5.0.0-rc4-00149-gefad4e4 #1
>> [   40.321348] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
>> [   40.330813] RIP: 0010:page_mapping+0x12/0x80
>> [   40.335709] Code: 5d c3 48 89 df e8 0e ad 02 00 85 c0 75 da 89 e8 5b 5d c3 0f 1f 44 00 00 53 48 89 fb 48 8b 43 08 48 8d 50 ff a8 01 48 0f 45 da <48> 8b 53 08 48 8d 42 ff 83 e2 01 48 0f 44 c3 48 83 38 ff 74 2f 48
>> [   40.356704] RSP: 0018:ffff88801fa87cd8 EFLAGS: 00010202
>> [   40.362714] RAX: ffffffffffffffff RBX: fffffffffffffffe RCX: 000000000000000a
>> [   40.370798] RDX: fffffffffffffffe RSI: ffffffff820b9a20 RDI: ffff88801e5c0000
>> [   40.378830] RBP: 6db6db6db6db6db7 R08: ffff88801e8bb000 R09: 0000000001b64d13
>> [   40.386902] R10: ffff88801fa87cf8 R11: 0000000000000001 R12: ffff88801e640000
>> [   40.395033] R13: ffffffff820b9a20 R14: ffff88801f145258 R15: 0000000000000001
>> [   40.403138] FS:  00007fb2079817c0(0000) GS:ffff88801dd00000(0000) knlGS:0000000000000000
>> [   40.412243] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [   40.418846] CR2: 0000000000000006 CR3: 000000001fa82000 CR4: 00000000000006a0
>> [   40.426951] Call Trace:
>> [   40.429843]  __dump_page+0x14/0x2c0
>> [   40.433947]  is_mem_section_removable+0x24c/0x2c0
> This looks like we are stumbling over an unitialized struct page again.
> Something this patch should prevent from. Could you try to apply [1]
> which will make __dump_page more robust so that we do not blow up there
> and give some more details in return.


Hi Hocko,

I have applied [1] and attached the dmesg file.


>
> Btw. is this reproducible all the time? I will have a look at the memory
> layout later today.


yes, it's reproducible all the time.

Best Regards,
Rong Chen


>
> [1] http://lkml.kernel.org/r/dbbcd36ca1f045ec81f49c7657928a1cdf24872b.1550065120.git.robin.murphy@arm.com
>> [   40.439327]  removable_show+0x87/0xa0
>> [   40.443613]  dev_attr_show+0x25/0x60
>> [   40.447763]  sysfs_kf_seq_show+0xba/0x110
>> [   40.452363]  seq_read+0x196/0x3f0
>> [   40.456282]  __vfs_read+0x34/0x180
>> [   40.460233]  ? lock_acquire+0xb6/0x1e0
>> [   40.464610]  vfs_read+0xa0/0x150
>> [   40.468372]  ksys_read+0x44/0xb0
>> [   40.472129]  ? do_syscall_64+0x1f/0x4a0
>> [   40.476593]  do_syscall_64+0x5e/0x4a0
>> [   40.480809]  ? trace_hardirqs_off_thunk+0x1a/0x1c
>> [   40.486195]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
>> [   40.491961] RIP: 0033:0x7fb2070680a0
>> [   40.496078] Code: 73 01 c3 48 8b 0d a0 0d 2d 00 31 d2 48 29 c2 64 89 11 48 83 c8 ff eb ea 90 90 83 3d 3d 71 2d 00 00 75 10 b8 00 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 31 c3 48 83 ec 08 e8 3e b1 01 00 48 89 04 24
>> [   40.517047] RSP: 002b:00007ffeee09f0b8 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
>> [   40.525660] RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00007fb2070680a0
>> [   40.533780] RDX: 0000000000001000 RSI: 00007ffeee09f158 RDI: 0000000000000005
>> [   40.541853] RBP: 000056092c0f0ac3 R08: 7379732f73656369 R09: 6f6d656d2f6d6574
>> [   40.549930] R10: 726f6d656d2f7972 R11: 0000000000000246 R12: 0000000000000000
>> [   40.557982] R13: 000056092c0ef7a0 R14: 0000000000000000 R15: 00007ffeee0a4f08
>> [   40.566089] Modules linked in:
>> [   40.569651] CR2: 0000000000000006
>>
>> udevd[316]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv platform:i5k_amb': No such file or directory
>> [   40.609875] WARNING: CPU: 1 PID: 235 at kernel/locking/lockdep.c:3553 lock_downgrade+0x167/0x1b0
>> [   40.626045] Modules linked in:
>> [   40.629632] CPU: 1 PID: 235 Comm: udevd Tainted: G      D           5.0.0-rc4-00149-gefad4e4 #1
>> [   40.639486] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
>> [   40.648956] RIP: 0010:lock_downgrade+0x167/0x1b0
>> [   40.654231] Code: c9 75 a9 48 c7 c6 c7 08 0c 82 48 c7 c7 58 f9 0a 82 e8 dd e6 fa ff 0f 0b eb 92 48 c7 c7 eb 08 0c 82 48 89 04 24 e8 c9 e6 fa ff <0f> 0b 8b 54 24 0c 48 8b 04 24 e9 2e ff ff ff e8 e5 fb 1e 00 85 c0
>> [   40.675231] RSP: 0018:ffff88801fa13de8 EFLAGS: 00010096
>> [   40.681229] RAX: 0000000000000017 RBX: ffff88801fa0c000 RCX: 0000000000000000
>> [   40.689326] RDX: ffffffff811285f4 RSI: 0000000000000001 RDI: ffffffff81128610
>> [   40.697401] RBP: ffff88801f93e0f8 R08: 0000000000000000 R09: 6572206120676e69
>> [   40.705498] R10: ffff88801fa13e08 R11: 6b636f6c20646165 R12: 0000000000000246
>> [   40.713630] R13: ffffffff812145c1 R14: 0000000000000001 R15: ffff88801f16a1d0
>> [   40.721734] FS:  00007fb2079817c0(0000) GS:ffff88801dd00000(0000) knlGS:0000000000000000
>> [   40.730878] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [   40.737418] CR2: 0000000000fa8000 CR3: 000000001fa0e000 CR4: 00000000000006a0
>> [   40.745516] Call Trace:
>> [   40.748404]  downgrade_write+0x12/0x80
>> [   40.752748]  __do_munmap+0x3f1/0x430
>> [   40.756926]  __vm_munmap+0x5d/0x90
>> [   40.760854]  __x64_sys_munmap+0x25/0x30
>> [   40.765257]  do_syscall_64+0x5e/0x4a0
>> [   40.769566]  ? trace_hardirqs_off_thunk+0x1a/0x1c
>> [   40.774950]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
>> [   40.780753] RIP: 0033:0x7fb207071897
>> [   40.784895] Code: f0 ff ff 73 01 c3 48 8b 0d a6 75 2c 00 31 d2 48 29 c2 64 89 11 48 83 c8 ff eb ea 90 90 90 90 90 90 90 90 b8 0b 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 79 75 2c 00 31 d2 48 29 c2 64
>> [   40.806706] RSP: 002b:00007ffeee09c9e8 EFLAGS: 00000206 ORIG_RAX: 000000000000000b
>> [   40.816041] RAX: ffffffffffffffda RBX: 000056092c0e9720 RCX: 00007fb207071897
>> [   40.824406] RDX: 0000000000000000 RSI: 0000000000001000 RDI: 00007fb207986000
>> [   40.832697] RBP: 0000000000000000 R08: 00007fb2079817c0 R09: 00000000ffffffff
>> [   40.840871] R10: 0000000000000022 R11: 0000000000000206 R12: 0000000000000000
>> [   40.848911] R13: 0000000000000000 R14: 0000000000000000 R15: 00007ffeee09ca6e
>> [   40.857009] irq event stamp: 8258
>> [   40.860875] hardirqs last  enabled at (8257): [<ffffffff8191b0cb>] preempt_schedule_irq+0x3b/0x90
>> [   40.870941] hardirqs last disabled at (8258): [<ffffffff8191a2a9>] __schedule+0x99/0x9e0
>> [   40.880106] softirqs last  enabled at (8256): [<ffffffff81c003f4>] __do_softirq+0x3f4/0x4c1
>> [   40.889506] softirqs last disabled at (8249): [<ffffffff810d108d>] irq_exit+0xdd/0xf0
>> [   40.898329] ---[ end trace 0f9a24fdf9c73c71 ]---
>>
>>
>>                                                            # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
>> git bisect start 5bb0643c4108bb06d8766b4bd48d20215deef4af f17b5f06cb92ef2250513a1e154c47b78df07d40 --
>> git bisect  bad 8e26062e1c829f1656e91461f95a7b83bda16ffd  # 02:34  B      0    10   25   0  Merge 'tip/ras/core' into devel-hourly-2019021719
>> git bisect  bad 39b94eff9f252bd7b6f2dfe716f6b5dd894ada6f  # 02:49  B      0     4   19   0  Merge 'sunxi/sunxi/h3-h5-for-5.1' into devel-hourly-2019021719
>> git bisect  bad cce96fc008ac0e3a5f96280557b02dcb83e70eee  # 03:02  B      0    10   25   0  Merge 'linux-review/Gustavo-A-R-Silva/igc-Use-struct_size-helper/20190208-163630' into devel-hourly-2019021719
>> git bisect  bad 544d67be09fcf4054db60b0b2b6fcb7386c095fe  # 03:13  B      0     7   22   0  Merge 'linux-review/Noralf-Tr-nnes/drm-drv-Rework-drm_dev_unplug-was-Remove-drm_dev_unplug/20190208-223952' into devel-hourly-2019021719
>> git bisect good 6dfcfd278beadb8857b94c0382348625943044be  # 03:25  G     11     0    0   0  Merge 'linux-review/Qing-Xia/staging-android-ion-fix-sys-heap-pool-s-gfp_flags/20190204-124705' into devel-hourly-2019021719
>> git bisect  bad 238358184e8bfb7c34701fc858f93400ffd8207d  # 03:35  B      0    10   25   0  Merge 'linux-review/Colin-King-via-dri-devel/video-fbdev-savage-fix-indentation-issue/20190212-234031' into devel-hourly-2019021719
>> git bisect good 8833753cc966fbe02ec9dadcd73601f23da7dc2d  # 03:44  G     10     0    0   0  Merge 'linux-review/Kamalesh-Babulal/static_keys-txt-Fix-trivial-spelling-mistake/20190204-230620' into devel-hourly-2019021719
>> git bisect  bad efcb5c0b0e4e5bd29320ef5d7ef3e0654c182abf  # 03:52  B      0     8   23   0  Merge 'net/master' into devel-hourly-2019021719
>> git bisect good 9312d5340da6a6018c851d03107ae24ef1a7ccb5  # 04:08  G     11     0    0   0  Merge 'linux-review/Yuri-Benditovich/virtio_net-Introduce-extended-RSC-feature/20190204-114604' into devel-hourly-2019021719
>> git bisect  bad 680905431b9de8c7224b15b76b1826a1481cfeaf  # 04:18  B      0     9   24   0  Merge tag 'char-misc-5.0-rc6' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/char-misc
>> git bisect  bad b9de6efed25cb713c1648e71302f4af83bd14ee6  # 04:31  B      0    11   26   0  Merge branch 'akpm' (patches from Andrew)
>> git bisect good 44e56f325b7d63e8a53008956ce7b28e4272a599  # 04:39  G     11     0    0   0  Merge tag 'pci-v5.0-fixes-3' of git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci
>> git bisect good a8e911d13540487942d53137c156bd7707f66e5d  # 04:50  G     10     0    0   0  x86_64: increase stack size for KASAN_EXTRA
>> git bisect good cd984a5be21549273a3f13b52a8b7b84097b32a7  # 05:01  G     11     0    0   0  Merge tag 'xtensa-20190201' of git://github.com/jcmvbkbc/linux-xtensa
>> git bisect  bad db7ddeab3ce5d64c9696e70d61f45ea9909cd196  # 05:10  B      0     7   22   0  lib/test_kmod.c: potential double free in error handling
>> git bisect  bad 24feb47c5fa5b825efb0151f28906dfdad027e61  # 05:20  B      0     4   19   0  mm, memory_hotplug: test_pages_in_a_zone do not pass the end of zone
>> git bisect good 80409c65e2c6cd1540045ee01fc55e50d95e0983  # 05:50  G     11     0    1   1  mm: migrate: make buffer_migrate_page_norefs() actually succeed
>> git bisect  bad efad4e475c312456edb3c789d0996d12ed744c13  # 06:03  B      0     3   18   0  mm, memory_hotplug: is_mem_section_removable do not pass the end of a zone
>> git bisect good 9bcdeb51bd7d2ae9fe65ea4d60643d2aeef5bfe3  # 06:25  G     11     0    0   0  oom, oom_reaper: do not enqueue same task twice
>> # first bad commit: [efad4e475c312456edb3c789d0996d12ed744c13] mm, memory_hotplug: is_mem_section_removable do not pass the end of a zone
>> git bisect good 9bcdeb51bd7d2ae9fe65ea4d60643d2aeef5bfe3  # 06:29  G     31     0    0   0  oom, oom_reaper: do not enqueue same task twice
>> # extra tests with debug options
>> git bisect  bad efad4e475c312456edb3c789d0996d12ed744c13  # 06:50  B      0     2   17   0  mm, memory_hotplug: is_mem_section_removable do not pass the end of a zone
>> # extra tests on HEAD of linux-devel/devel-hourly-2019021719
>> git bisect  bad 5bb0643c4108bb06d8766b4bd48d20215deef4af  # 06:55  B      0    12   31   1  0day head guard for 'devel-hourly-2019021719'
>> # extra tests on tree/branch linus/master
>> git bisect good f17b5f06cb92ef2250513a1e154c47b78df07d40  # 06:56  G     10     0    0   6  Linux 5.0-rc4
>> # extra tests with first bad commit reverted
>> git bisect good cc8685c9af14503b93c6aca3330789384fcb62ac  # 07:25  G     10     0    0   0  Revert "mm, memory_hotplug: is_mem_section_removable do not pass the end of a zone"
>> # extra tests on tree/branch linux-next/master
>> git bisect  bad 7a92eb7cc1dc4c63e3a2fa9ab8e3c1049f199249  # 07:50  B      0    10   25   0  Add linux-next specific files for 20190215
>>
>> ---
>> 0-DAY kernel test infrastructure                Open Source Technology Center
>> https://lists.01.org/pipermail/lkp                          Intel Corporation
>
>> #!/bin/bash
>>
>> kernel=$1
>> initrd=quantal-trinity-x86_64.cgz
>>
>> wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/quantal/$initrd
>>
>> kvm=(
>> 	qemu-system-x86_64
>> 	-enable-kvm
>> 	-cpu kvm64
>> 	-kernel $kernel
>> 	-initrd $initrd
>> 	-m 512
>> 	-smp 2
>> 	-device e1000,netdev=net0
>> 	-netdev user,id=net0
>> 	-boot order=nc
>> 	-no-reboot
>> 	-watchdog i6300esb
>> 	-watchdog-action debug
>> 	-rtc base=localtime
>> 	-serial stdio
>> 	-display none
>> 	-monitor null
>> )
>>
>> append=(
>> 	root=/dev/ram0
>> 	hung_task_panic=1
>> 	debug
>> 	apic=debug
>> 	sysrq_always_enabled
>> 	rcupdate.rcu_cpu_stall_timeout=100
>> 	net.ifnames=0
>> 	printk.devkmsg=on
>> 	panic=-1
>> 	softlockup_panic=1
>> 	nmi_watchdog=panic
>> 	oops=panic
>> 	load_ramdisk=2
>> 	prompt_ramdisk=0
>> 	drbd.minor_count=8
>> 	systemd.log_level=err
>> 	ignore_loglevel
>> 	console=tty0
>> 	earlyprintk=ttyS0,115200
>> 	console=ttyS0,115200
>> 	vga=normal
>> 	rw
>> 	drbd.minor_count=8
>> 	rcuperf.shutdown=0
>> )
>>
>> "${kvm[@]}" -append "${append[*]}"
>> #
>> # Automatically generated file; DO NOT EDIT.
>> # Linux/x86_64 5.0.0-rc4 Kernel Configuration
>> #
>>
>> #
>> # Compiler: gcc-6 (Debian 6.5.0-2) 6.5.0 20181026
>> #
>> CONFIG_CC_IS_GCC=y
>> CONFIG_GCC_VERSION=60500
>> CONFIG_CLANG_VERSION=0
>> CONFIG_CC_HAS_ASM_GOTO=y
>> CONFIG_CONSTRUCTORS=y
>> CONFIG_IRQ_WORK=y
>> CONFIG_BUILDTIME_EXTABLE_SORT=y
>> CONFIG_THREAD_INFO_IN_TASK=y
>>
>> #
>> # General setup
>> #
>> CONFIG_INIT_ENV_ARG_LIMIT=32
>> # CONFIG_COMPILE_TEST is not set
>> CONFIG_LOCALVERSION=""
>> CONFIG_LOCALVERSION_AUTO=y
>> CONFIG_BUILD_SALT=""
>> CONFIG_HAVE_KERNEL_GZIP=y
>> CONFIG_HAVE_KERNEL_BZIP2=y
>> CONFIG_HAVE_KERNEL_LZMA=y
>> CONFIG_HAVE_KERNEL_XZ=y
>> CONFIG_HAVE_KERNEL_LZO=y
>> CONFIG_HAVE_KERNEL_LZ4=y
>> # CONFIG_KERNEL_GZIP is not set
>> CONFIG_KERNEL_BZIP2=y
>> # CONFIG_KERNEL_LZMA is not set
>> # CONFIG_KERNEL_XZ is not set
>> # CONFIG_KERNEL_LZO is not set
>> # CONFIG_KERNEL_LZ4 is not set
>> CONFIG_DEFAULT_HOSTNAME="(none)"
>> # CONFIG_SYSVIPC is not set
>> # CONFIG_POSIX_MQUEUE is not set
>> # CONFIG_CROSS_MEMORY_ATTACH is not set
>> # CONFIG_USELIB is not set
>> CONFIG_AUDIT=y
>> CONFIG_HAVE_ARCH_AUDITSYSCALL=y
>> CONFIG_AUDITSYSCALL=y
>>
>> #
>> # IRQ subsystem
>> #
>> CONFIG_GENERIC_IRQ_PROBE=y
>> CONFIG_GENERIC_IRQ_SHOW=y
>> CONFIG_GENERIC_IRQ_EFFECTIVE_AFF_MASK=y
>> CONFIG_GENERIC_PENDING_IRQ=y
>> CONFIG_GENERIC_IRQ_MIGRATION=y
>> CONFIG_GENERIC_IRQ_CHIP=y
>> CONFIG_IRQ_DOMAIN=y
>> CONFIG_IRQ_SIM=y
>> CONFIG_IRQ_DOMAIN_HIERARCHY=y
>> CONFIG_GENERIC_MSI_IRQ=y
>> CONFIG_GENERIC_MSI_IRQ_DOMAIN=y
>> CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
>> CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
>> CONFIG_IRQ_FORCED_THREADING=y
>> CONFIG_SPARSE_IRQ=y
>> # CONFIG_GENERIC_IRQ_DEBUGFS is not set
>> CONFIG_CLOCKSOURCE_WATCHDOG=y
>> CONFIG_ARCH_CLOCKSOURCE_DATA=y
>> CONFIG_ARCH_CLOCKSOURCE_INIT=y
>> CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
>> CONFIG_GENERIC_TIME_VSYSCALL=y
>> CONFIG_GENERIC_CLOCKEVENTS=y
>> CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
>> CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
>> CONFIG_GENERIC_CMOS_UPDATE=y
>>
>> #
>> # Timers subsystem
>> #
>> CONFIG_TICK_ONESHOT=y
>> CONFIG_NO_HZ_COMMON=y
>> # CONFIG_HZ_PERIODIC is not set
>> # CONFIG_NO_HZ_IDLE is not set
>> CONFIG_NO_HZ_FULL=y
>> # CONFIG_NO_HZ is not set
>> # CONFIG_HIGH_RES_TIMERS is not set
>> # CONFIG_PREEMPT_NONE is not set
>> # CONFIG_PREEMPT_VOLUNTARY is not set
>> CONFIG_PREEMPT=y
>> CONFIG_PREEMPT_COUNT=y
>>
>> #
>> # CPU/Task time and stats accounting
>> #
>> CONFIG_VIRT_CPU_ACCOUNTING=y
>> CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
>> # CONFIG_IRQ_TIME_ACCOUNTING is not set
>> # CONFIG_BSD_PROCESS_ACCT is not set
>> CONFIG_TASKSTATS=y
>> CONFIG_TASK_DELAY_ACCT=y
>> CONFIG_TASK_XACCT=y
>> # CONFIG_TASK_IO_ACCOUNTING is not set
>> # CONFIG_PSI is not set
>> CONFIG_CPU_ISOLATION=y
>>
>> #
>> # RCU Subsystem
>> #
>> CONFIG_PREEMPT_RCU=y
>> # CONFIG_RCU_EXPERT is not set
>> CONFIG_SRCU=y
>> CONFIG_TREE_SRCU=y
>> CONFIG_TASKS_RCU=y
>> CONFIG_RCU_STALL_COMMON=y
>> CONFIG_RCU_NEED_SEGCBLIST=y
>> CONFIG_CONTEXT_TRACKING=y
>> CONFIG_CONTEXT_TRACKING_FORCE=y
>> CONFIG_RCU_NOCB_CPU=y
>> CONFIG_BUILD_BIN2C=y
>> CONFIG_IKCONFIG=y
>> CONFIG_IKCONFIG_PROC=y
>> CONFIG_LOG_BUF_SHIFT=20
>> CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
>> CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
>> CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
>> CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
>> CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
>> CONFIG_ARCH_SUPPORTS_INT128=y
>> # CONFIG_NUMA_BALANCING is not set
>> CONFIG_CGROUPS=y
>> # CONFIG_MEMCG is not set
>> CONFIG_CGROUP_SCHED=y
>> # CONFIG_FAIR_GROUP_SCHED is not set
>> # CONFIG_RT_GROUP_SCHED is not set
>> # CONFIG_CGROUP_PIDS is not set
>> CONFIG_CGROUP_RDMA=y
>> CONFIG_CGROUP_FREEZER=y
>> # CONFIG_CGROUP_HUGETLB is not set
>> CONFIG_CPUSETS=y
>> CONFIG_PROC_PID_CPUSET=y
>> CONFIG_CGROUP_DEVICE=y
>> # CONFIG_CGROUP_CPUACCT is not set
>> CONFIG_CGROUP_PERF=y
>> CONFIG_CGROUP_DEBUG=y
>> CONFIG_NAMESPACES=y
>> # CONFIG_UTS_NS is not set
>> CONFIG_USER_NS=y
>> CONFIG_PID_NS=y
>> # CONFIG_NET_NS is not set
>> CONFIG_CHECKPOINT_RESTORE=y
>> # CONFIG_SCHED_AUTOGROUP is not set
>> # CONFIG_SYSFS_DEPRECATED is not set
>> # CONFIG_RELAY is not set
>> CONFIG_BLK_DEV_INITRD=y
>> CONFIG_INITRAMFS_SOURCE=""
>> CONFIG_RD_GZIP=y
>> # CONFIG_RD_BZIP2 is not set
>> # CONFIG_RD_LZMA is not set
>> CONFIG_RD_XZ=y
>> # CONFIG_RD_LZO is not set
>> # CONFIG_RD_LZ4 is not set
>> CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
>> # CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
>> CONFIG_SYSCTL=y
>> CONFIG_ANON_INODES=y
>> CONFIG_SYSCTL_EXCEPTION_TRACE=y
>> CONFIG_HAVE_PCSPKR_PLATFORM=y
>> CONFIG_BPF=y
>> CONFIG_EXPERT=y
>> CONFIG_MULTIUSER=y
>> # CONFIG_SGETMASK_SYSCALL is not set
>> CONFIG_SYSFS_SYSCALL=y
>> # CONFIG_SYSCTL_SYSCALL is not set
>> CONFIG_FHANDLE=y
>> CONFIG_POSIX_TIMERS=y
>> CONFIG_PRINTK=y
>> CONFIG_PRINTK_NMI=y
>> CONFIG_BUG=y
>> CONFIG_PCSPKR_PLATFORM=y
>> # CONFIG_BASE_FULL is not set
>> CONFIG_FUTEX=y
>> CONFIG_FUTEX_PI=y
>> CONFIG_EPOLL=y
>> CONFIG_SIGNALFD=y
>> CONFIG_TIMERFD=y
>> # CONFIG_EVENTFD is not set
>> CONFIG_SHMEM=y
>> # CONFIG_AIO is not set
>> CONFIG_ADVISE_SYSCALLS=y
>> CONFIG_MEMBARRIER=y
>> CONFIG_KALLSYMS=y
>> CONFIG_KALLSYMS_ALL=y
>> CONFIG_KALLSYMS_ABSOLUTE_PERCPU=y
>> CONFIG_KALLSYMS_BASE_RELATIVE=y
>> # CONFIG_BPF_SYSCALL is not set
>> # CONFIG_USERFAULTFD is not set
>> CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
>> # CONFIG_RSEQ is not set
>> CONFIG_EMBEDDED=y
>> CONFIG_HAVE_PERF_EVENTS=y
>> CONFIG_PERF_USE_VMALLOC=y
>> # CONFIG_PC104 is not set
>>
>> #
>> # Kernel Performance Events And Counters
>> #
>> CONFIG_PERF_EVENTS=y
>> CONFIG_DEBUG_PERF_USE_VMALLOC=y
>> # CONFIG_VM_EVENT_COUNTERS is not set
>> # CONFIG_COMPAT_BRK is not set
>> # CONFIG_SLAB is not set
>> # CONFIG_SLUB is not set
>> CONFIG_SLOB=y
>> # CONFIG_SLAB_MERGE_DEFAULT is not set
>> CONFIG_PROFILING=y
>> CONFIG_TRACEPOINTS=y
>> CONFIG_64BIT=y
>> CONFIG_X86_64=y
>> CONFIG_X86=y
>> CONFIG_INSTRUCTION_DECODER=y
>> CONFIG_OUTPUT_FORMAT="elf64-x86-64"
>> CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
>> CONFIG_LOCKDEP_SUPPORT=y
>> CONFIG_STACKTRACE_SUPPORT=y
>> CONFIG_MMU=y
>> CONFIG_ARCH_MMAP_RND_BITS_MIN=28
>> CONFIG_ARCH_MMAP_RND_BITS_MAX=32
>> CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
>> CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
>> CONFIG_GENERIC_BUG=y
>> CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
>> CONFIG_GENERIC_HWEIGHT=y
>> CONFIG_RWSEM_XCHGADD_ALGORITHM=y
>> CONFIG_GENERIC_CALIBRATE_DELAY=y
>> CONFIG_ARCH_HAS_CPU_RELAX=y
>> CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
>> CONFIG_ARCH_HAS_FILTER_PGPROT=y
>> CONFIG_HAVE_SETUP_PER_CPU_AREA=y
>> CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
>> CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
>> CONFIG_ARCH_HIBERNATION_POSSIBLE=y
>> CONFIG_ARCH_SUSPEND_POSSIBLE=y
>> CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
>> CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
>> CONFIG_ZONE_DMA32=y
>> CONFIG_AUDIT_ARCH=y
>> CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
>> CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
>> CONFIG_X86_64_SMP=y
>> CONFIG_ARCH_SUPPORTS_UPROBES=y
>> CONFIG_FIX_EARLYCON_MEM=y
>> CONFIG_PGTABLE_LEVELS=4
>> CONFIG_CC_HAS_SANE_STACKPROTECTOR=y
>>
>> #
>> # Processor type and features
>> #
>> # CONFIG_ZONE_DMA is not set
>> CONFIG_SMP=y
>> CONFIG_X86_FEATURE_NAMES=y
>> # CONFIG_X86_X2APIC is not set
>> CONFIG_X86_MPPARSE=y
>> # CONFIG_GOLDFISH is not set
>> CONFIG_RETPOLINE=y
>> # CONFIG_X86_RESCTRL is not set
>> # CONFIG_X86_EXTENDED_PLATFORM is not set
>> # CONFIG_X86_INTEL_LPSS is not set
>> # CONFIG_X86_AMD_PLATFORM_DEVICE is not set
>> CONFIG_IOSF_MBI=y
>> CONFIG_IOSF_MBI_DEBUG=y
>> # CONFIG_SCHED_OMIT_FRAME_POINTER is not set
>> CONFIG_HYPERVISOR_GUEST=y
>> CONFIG_PARAVIRT=y
>> # CONFIG_PARAVIRT_DEBUG is not set
>> # CONFIG_PARAVIRT_SPINLOCKS is not set
>> # CONFIG_XEN is not set
>> CONFIG_KVM_GUEST=y
>> # CONFIG_PVH is not set
>> # CONFIG_KVM_DEBUG_FS is not set
>> # CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
>> CONFIG_PARAVIRT_CLOCK=y
>> # CONFIG_JAILHOUSE_GUEST is not set
>> # CONFIG_MK8 is not set
>> # CONFIG_MPSC is not set
>> # CONFIG_MCORE2 is not set
>> # CONFIG_MATOM is not set
>> CONFIG_GENERIC_CPU=y
>> CONFIG_X86_INTERNODE_CACHE_SHIFT=6
>> CONFIG_X86_L1_CACHE_SHIFT=6
>> CONFIG_X86_TSC=y
>> CONFIG_X86_CMPXCHG64=y
>> CONFIG_X86_CMOV=y
>> CONFIG_X86_MINIMUM_CPU_FAMILY=64
>> CONFIG_X86_DEBUGCTLMSR=y
>> CONFIG_PROCESSOR_SELECT=y
>> CONFIG_CPU_SUP_INTEL=y
>> # CONFIG_CPU_SUP_AMD is not set
>> # CONFIG_CPU_SUP_HYGON is not set
>> # CONFIG_CPU_SUP_CENTAUR is not set
>> CONFIG_HPET_TIMER=y
>> CONFIG_HPET_EMULATE_RTC=y
>> CONFIG_DMI=y
>> CONFIG_CALGARY_IOMMU=y
>> CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT=y
>> # CONFIG_MAXSMP is not set
>> CONFIG_NR_CPUS_RANGE_BEGIN=2
>> CONFIG_NR_CPUS_RANGE_END=512
>> CONFIG_NR_CPUS_DEFAULT=64
>> CONFIG_NR_CPUS=64
>> CONFIG_SCHED_SMT=y
>> # CONFIG_SCHED_MC is not set
>> CONFIG_X86_LOCAL_APIC=y
>> CONFIG_X86_IO_APIC=y
>> CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
>> # CONFIG_X86_MCE is not set
>>
>> #
>> # Performance monitoring
>> #
>> CONFIG_PERF_EVENTS_INTEL_UNCORE=y
>> CONFIG_PERF_EVENTS_INTEL_RAPL=y
>> CONFIG_PERF_EVENTS_INTEL_CSTATE=m
>> CONFIG_X86_VSYSCALL_EMULATION=y
>> CONFIG_I8K=m
>> CONFIG_MICROCODE=y
>> CONFIG_MICROCODE_INTEL=y
>> # CONFIG_MICROCODE_AMD is not set
>> CONFIG_MICROCODE_OLD_INTERFACE=y
>> # CONFIG_X86_MSR is not set
>> CONFIG_X86_CPUID=m
>> # CONFIG_X86_5LEVEL is not set
>> CONFIG_X86_CPA_STATISTICS=y
>> CONFIG_ARCH_HAS_MEM_ENCRYPT=y
>> CONFIG_NUMA=y
>> CONFIG_AMD_NUMA=y
>> CONFIG_X86_64_ACPI_NUMA=y
>> CONFIG_NODES_SPAN_OTHER_NODES=y
>> # CONFIG_NUMA_EMU is not set
>> CONFIG_NODES_SHIFT=6
>> CONFIG_ARCH_SPARSEMEM_ENABLE=y
>> CONFIG_ARCH_SPARSEMEM_DEFAULT=y
>> CONFIG_ARCH_SELECT_MEMORY_MODEL=y
>> # CONFIG_ARCH_MEMORY_PROBE is not set
>> CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
>> CONFIG_X86_CHECK_BIOS_CORRUPTION=y
>> CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
>> CONFIG_X86_RESERVE_LOW=64
>> # CONFIG_MTRR is not set
>> # CONFIG_ARCH_RANDOM is not set
>> CONFIG_X86_SMAP=y
>> # CONFIG_X86_INTEL_UMIP is not set
>> CONFIG_X86_INTEL_MPX=y
>> CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS=y
>> # CONFIG_EFI is not set
>> CONFIG_SECCOMP=y
>> # CONFIG_HZ_100 is not set
>> # CONFIG_HZ_250 is not set
>> # CONFIG_HZ_300 is not set
>> CONFIG_HZ_1000=y
>> CONFIG_HZ=1000
>> CONFIG_KEXEC=y
>> # CONFIG_KEXEC_FILE is not set
>> CONFIG_CRASH_DUMP=y
>> CONFIG_PHYSICAL_START=0x1000000
>> # CONFIG_RELOCATABLE is not set
>> CONFIG_PHYSICAL_ALIGN=0x200000
>> CONFIG_HOTPLUG_CPU=y
>> CONFIG_BOOTPARAM_HOTPLUG_CPU0=y
>> CONFIG_DEBUG_HOTPLUG_CPU0=y
>> CONFIG_LEGACY_VSYSCALL_EMULATE=y
>> # CONFIG_LEGACY_VSYSCALL_NONE is not set
>> # CONFIG_CMDLINE_BOOL is not set
>> # CONFIG_MODIFY_LDT_SYSCALL is not set
>> CONFIG_HAVE_LIVEPATCH=y
>> CONFIG_ARCH_HAS_ADD_PAGES=y
>> CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
>> CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
>> CONFIG_USE_PERCPU_NUMA_NODE_ID=y
>> CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
>> CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
>>
>> #
>> # Power management and ACPI options
>> #
>> CONFIG_SUSPEND=y
>> CONFIG_SUSPEND_FREEZER=y
>> # CONFIG_SUSPEND_SKIP_SYNC is not set
>> CONFIG_PM_SLEEP=y
>> CONFIG_PM_SLEEP_SMP=y
>> # CONFIG_PM_AUTOSLEEP is not set
>> CONFIG_PM_WAKELOCKS=y
>> CONFIG_PM_WAKELOCKS_LIMIT=100
>> CONFIG_PM_WAKELOCKS_GC=y
>> CONFIG_PM=y
>> CONFIG_PM_DEBUG=y
>> CONFIG_PM_ADVANCED_DEBUG=y
>> CONFIG_PM_TEST_SUSPEND=y
>> CONFIG_PM_SLEEP_DEBUG=y
>> CONFIG_PM_TRACE=y
>> CONFIG_PM_TRACE_RTC=y
>> CONFIG_PM_CLK=y
>> CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
>> CONFIG_ARCH_SUPPORTS_ACPI=y
>> CONFIG_ACPI=y
>> CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
>> CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
>> CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
>> # CONFIG_ACPI_DEBUGGER is not set
>> CONFIG_ACPI_SPCR_TABLE=y
>> CONFIG_ACPI_LPIT=y
>> CONFIG_ACPI_SLEEP=y
>> # CONFIG_ACPI_PROCFS_POWER is not set
>> CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
>> # CONFIG_ACPI_EC_DEBUGFS is not set
>> CONFIG_ACPI_AC=y
>> CONFIG_ACPI_BATTERY=y
>> CONFIG_ACPI_BUTTON=y
>> # CONFIG_ACPI_VIDEO is not set
>> CONFIG_ACPI_FAN=y
>> # CONFIG_ACPI_TAD is not set
>> # CONFIG_ACPI_DOCK is not set
>> CONFIG_ACPI_CPU_FREQ_PSS=y
>> CONFIG_ACPI_PROCESSOR_CSTATE=y
>> CONFIG_ACPI_PROCESSOR_IDLE=y
>> CONFIG_ACPI_PROCESSOR=y
>> # CONFIG_ACPI_IPMI is not set
>> CONFIG_ACPI_HOTPLUG_CPU=y
>> # CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
>> CONFIG_ACPI_THERMAL=y
>> CONFIG_ACPI_NUMA=y
>> CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
>> CONFIG_ACPI_TABLE_UPGRADE=y
>> # CONFIG_ACPI_DEBUG is not set
>> # CONFIG_ACPI_PCI_SLOT is not set
>> CONFIG_ACPI_CONTAINER=y
>> # CONFIG_ACPI_HOTPLUG_MEMORY is not set
>> CONFIG_ACPI_HOTPLUG_IOAPIC=y
>> # CONFIG_ACPI_SBS is not set
>> # CONFIG_ACPI_HED is not set
>> # CONFIG_ACPI_CUSTOM_METHOD is not set
>> # CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
>> CONFIG_HAVE_ACPI_APEI=y
>> CONFIG_HAVE_ACPI_APEI_NMI=y
>> # CONFIG_ACPI_APEI is not set
>> # CONFIG_DPTF_POWER is not set
>> # CONFIG_PMIC_OPREGION is not set
>> # CONFIG_ACPI_CONFIGFS is not set
>> CONFIG_X86_PM_TIMER=y
>> # CONFIG_SFI is not set
>>
>> #
>> # CPU Frequency scaling
>> #
>> # CONFIG_CPU_FREQ is not set
>>
>> #
>> # CPU Idle
>> #
>> CONFIG_CPU_IDLE=y
>> CONFIG_CPU_IDLE_GOV_LADDER=y
>> CONFIG_CPU_IDLE_GOV_MENU=y
>> CONFIG_INTEL_IDLE=y
>>
>> #
>> # Bus options (PCI etc.)
>> #
>> CONFIG_PCI_DIRECT=y
>> CONFIG_PCI_MMCONFIG=y
>> CONFIG_MMCONF_FAM10H=y
>> # CONFIG_PCI_CNB20LE_QUIRK is not set
>> # CONFIG_ISA_BUS is not set
>> # CONFIG_ISA_DMA_API is not set
>> CONFIG_X86_SYSFB=y
>>
>> #
>> # Binary Emulations
>> #
>> # CONFIG_IA32_EMULATION is not set
>> # CONFIG_X86_X32 is not set
>> CONFIG_X86_DEV_DMA_OPS=y
>> CONFIG_HAVE_GENERIC_GUP=y
>>
>> #
>> # Firmware Drivers
>> #
>> CONFIG_EDD=y
>> # CONFIG_EDD_OFF is not set
>> # CONFIG_FIRMWARE_MEMMAP is not set
>> CONFIG_DMIID=y
>> # CONFIG_DMI_SYSFS is not set
>> CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
>> # CONFIG_ISCSI_IBFT_FIND is not set
>> # CONFIG_FW_CFG_SYSFS is not set
>> # CONFIG_GOOGLE_FIRMWARE is not set
>>
>> #
>> # Tegra firmware driver
>> #
>> CONFIG_HAVE_KVM=y
>> CONFIG_VIRTUALIZATION=y
>> CONFIG_VHOST_CROSS_ENDIAN_LEGACY=y
>>
>> #
>> # General architecture-dependent options
>> #
>> CONFIG_CRASH_CORE=y
>> CONFIG_KEXEC_CORE=y
>> CONFIG_HOTPLUG_SMT=y
>> # CONFIG_OPROFILE is not set
>> CONFIG_HAVE_OPROFILE=y
>> CONFIG_OPROFILE_NMI_TIMER=y
>> # CONFIG_KPROBES is not set
>> CONFIG_JUMP_LABEL=y
>> # CONFIG_STATIC_KEYS_SELFTEST is not set
>> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
>> CONFIG_ARCH_USE_BUILTIN_BSWAP=y
>> CONFIG_HAVE_IOREMAP_PROT=y
>> CONFIG_HAVE_KPROBES=y
>> CONFIG_HAVE_KRETPROBES=y
>> CONFIG_HAVE_OPTPROBES=y
>> CONFIG_HAVE_KPROBES_ON_FTRACE=y
>> CONFIG_HAVE_FUNCTION_ERROR_INJECTION=y
>> CONFIG_HAVE_NMI=y
>> CONFIG_HAVE_ARCH_TRACEHOOK=y
>> CONFIG_HAVE_DMA_CONTIGUOUS=y
>> CONFIG_GENERIC_SMP_IDLE_THREAD=y
>> CONFIG_ARCH_HAS_FORTIFY_SOURCE=y
>> CONFIG_ARCH_HAS_SET_MEMORY=y
>> CONFIG_HAVE_ARCH_THREAD_STRUCT_WHITELIST=y
>> CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
>> CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
>> CONFIG_HAVE_RSEQ=y
>> CONFIG_HAVE_FUNCTION_ARG_ACCESS_API=y
>> CONFIG_HAVE_CLK=y
>> CONFIG_HAVE_HW_BREAKPOINT=y
>> CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
>> CONFIG_HAVE_USER_RETURN_NOTIFIER=y
>> CONFIG_HAVE_PERF_EVENTS_NMI=y
>> CONFIG_HAVE_HARDLOCKUP_DETECTOR_PERF=y
>> CONFIG_HAVE_PERF_REGS=y
>> CONFIG_HAVE_PERF_USER_STACK_DUMP=y
>> CONFIG_HAVE_ARCH_JUMP_LABEL=y
>> CONFIG_HAVE_ARCH_JUMP_LABEL_RELATIVE=y
>> CONFIG_HAVE_RCU_TABLE_FREE=y
>> CONFIG_HAVE_RCU_TABLE_INVALIDATE=y
>> CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
>> CONFIG_HAVE_CMPXCHG_LOCAL=y
>> CONFIG_HAVE_CMPXCHG_DOUBLE=y
>> CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
>> CONFIG_SECCOMP_FILTER=y
>> CONFIG_HAVE_ARCH_STACKLEAK=y
>> CONFIG_HAVE_STACKPROTECTOR=y
>> CONFIG_CC_HAS_STACKPROTECTOR_NONE=y
>> # CONFIG_STACKPROTECTOR is not set
>> CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
>> CONFIG_HAVE_CONTEXT_TRACKING=y
>> CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
>> CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
>> CONFIG_HAVE_MOVE_PMD=y
>> CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
>> CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD=y
>> CONFIG_HAVE_ARCH_HUGE_VMAP=y
>> CONFIG_HAVE_ARCH_SOFT_DIRTY=y
>> CONFIG_HAVE_MOD_ARCH_SPECIFIC=y
>> CONFIG_MODULES_USE_ELF_RELA=y
>> CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
>> CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
>> CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
>> CONFIG_HAVE_EXIT_THREAD=y
>> CONFIG_ARCH_MMAP_RND_BITS=28
>> CONFIG_HAVE_COPY_THREAD_TLS=y
>> CONFIG_HAVE_STACK_VALIDATION=y
>> CONFIG_HAVE_RELIABLE_STACKTRACE=y
>> CONFIG_ISA_BUS_API=y
>> CONFIG_HAVE_ARCH_VMAP_STACK=y
>> # CONFIG_VMAP_STACK is not set
>> CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
>> CONFIG_STRICT_KERNEL_RWX=y
>> CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
>> CONFIG_STRICT_MODULE_RWX=y
>> CONFIG_ARCH_HAS_REFCOUNT=y
>> CONFIG_REFCOUNT_FULL=y
>> CONFIG_HAVE_ARCH_PREL32_RELOCATIONS=y
>>
>> #
>> # GCOV-based kernel profiling
>> #
>> CONFIG_GCOV_KERNEL=y
>> CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
>> # CONFIG_GCOV_PROFILE_ALL is not set
>> CONFIG_GCOV_FORMAT_4_7=y
>> CONFIG_PLUGIN_HOSTCC="g++"
>> CONFIG_HAVE_GCC_PLUGINS=y
>> CONFIG_GCC_PLUGINS=y
>> # CONFIG_GCC_PLUGIN_CYC_COMPLEXITY is not set
>> # CONFIG_GCC_PLUGIN_LATENT_ENTROPY is not set
>> # CONFIG_GCC_PLUGIN_STRUCTLEAK is not set
>> # CONFIG_GCC_PLUGIN_RANDSTRUCT is not set
>> CONFIG_GCC_PLUGIN_STACKLEAK=y
>> CONFIG_STACKLEAK_TRACK_MIN_SIZE=100
>> CONFIG_STACKLEAK_METRICS=y
>> # CONFIG_STACKLEAK_RUNTIME_DISABLE is not set
>> CONFIG_RT_MUTEXES=y
>> CONFIG_BASE_SMALL=1
>> CONFIG_MODULES=y
>> # CONFIG_MODULE_FORCE_LOAD is not set
>> # CONFIG_MODULE_UNLOAD is not set
>> # CONFIG_MODVERSIONS is not set
>> # CONFIG_MODULE_SRCVERSION_ALL is not set
>> # CONFIG_MODULE_SIG is not set
>> # CONFIG_MODULE_COMPRESS is not set
>> # CONFIG_TRIM_UNUSED_KSYMS is not set
>> CONFIG_MODULES_TREE_LOOKUP=y
>> # CONFIG_BLOCK is not set
>> CONFIG_PADATA=y
>> CONFIG_ASN1=m
>> CONFIG_UNINLINE_SPIN_UNLOCK=y
>> CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
>> CONFIG_MUTEX_SPIN_ON_OWNER=y
>> CONFIG_RWSEM_SPIN_ON_OWNER=y
>> CONFIG_LOCK_SPIN_ON_OWNER=y
>> CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
>> CONFIG_QUEUED_SPINLOCKS=y
>> CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
>> CONFIG_QUEUED_RWLOCKS=y
>> CONFIG_ARCH_HAS_SYNC_CORE_BEFORE_USERMODE=y
>> CONFIG_ARCH_HAS_SYSCALL_WRAPPER=y
>> CONFIG_FREEZER=y
>>
>> #
>> # Executable file formats
>> #
>> CONFIG_BINFMT_ELF=y
>> CONFIG_ELFCORE=y
>> CONFIG_BINFMT_SCRIPT=y
>> # CONFIG_BINFMT_MISC is not set
>> # CONFIG_COREDUMP is not set
>>
>> #
>> # Memory Management options
>> #
>> CONFIG_SELECT_MEMORY_MODEL=y
>> CONFIG_SPARSEMEM_MANUAL=y
>> CONFIG_SPARSEMEM=y
>> CONFIG_NEED_MULTIPLE_NODES=y
>> CONFIG_HAVE_MEMORY_PRESENT=y
>> CONFIG_SPARSEMEM_EXTREME=y
>> CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
>> # CONFIG_SPARSEMEM_VMEMMAP is not set
>> CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
>> CONFIG_ARCH_DISCARD_MEMBLOCK=y
>> CONFIG_MEMORY_ISOLATION=y
>> CONFIG_HAVE_BOOTMEM_INFO_NODE=y
>> CONFIG_MEMORY_HOTPLUG=y
>> CONFIG_MEMORY_HOTPLUG_SPARSE=y
>> CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE=y
>> CONFIG_MEMORY_HOTREMOVE=y
>> CONFIG_SPLIT_PTLOCK_CPUS=4
>> # CONFIG_COMPACTION is not set
>> CONFIG_MIGRATION=y
>> CONFIG_PHYS_ADDR_T_64BIT=y
>> CONFIG_VIRT_TO_BUS=y
>> # CONFIG_KSM is not set
>> CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
>> # CONFIG_TRANSPARENT_HUGEPAGE is not set
>> CONFIG_ARCH_WANTS_THP_SWAP=y
>> # CONFIG_CLEANCACHE is not set
>> CONFIG_CMA=y
>> CONFIG_CMA_DEBUG=y
>> # CONFIG_CMA_DEBUGFS is not set
>> CONFIG_CMA_AREAS=7
>> # CONFIG_MEM_SOFT_DIRTY is not set
>> CONFIG_ZPOOL=m
>> # CONFIG_ZBUD is not set
>> CONFIG_Z3FOLD=m
>> CONFIG_ZSMALLOC=m
>> # CONFIG_PGTABLE_MAPPING is not set
>> # CONFIG_ZSMALLOC_STAT is not set
>> CONFIG_GENERIC_EARLY_IOREMAP=y
>> # CONFIG_DEFERRED_STRUCT_PAGE_INIT is not set
>> # CONFIG_IDLE_PAGE_TRACKING is not set
>> CONFIG_ARCH_HAS_ZONE_DEVICE=y
>> CONFIG_FRAME_VECTOR=y
>> CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
>> CONFIG_ARCH_HAS_PKEYS=y
>> CONFIG_PERCPU_STATS=y
>> # CONFIG_GUP_BENCHMARK is not set
>> CONFIG_ARCH_HAS_PTE_SPECIAL=y
>> CONFIG_NET=y
>> CONFIG_NET_INGRESS=y
>> CONFIG_SKB_EXTENSIONS=y
>>
>> #
>> # Networking options
>> #
>> CONFIG_PACKET=y
>> CONFIG_PACKET_DIAG=m
>> CONFIG_UNIX=y
>> CONFIG_UNIX_DIAG=m
>> # CONFIG_TLS is not set
>> CONFIG_XFRM=y
>> CONFIG_XFRM_ALGO=y
>> # CONFIG_XFRM_USER is not set
>> # CONFIG_XFRM_INTERFACE is not set
>> CONFIG_XFRM_SUB_POLICY=y
>> CONFIG_XFRM_MIGRATE=y
>> # CONFIG_XFRM_STATISTICS is not set
>> CONFIG_NET_KEY=y
>> # CONFIG_NET_KEY_MIGRATE is not set
>> CONFIG_INET=y
>> # CONFIG_IP_MULTICAST is not set
>> # CONFIG_IP_ADVANCED_ROUTER is not set
>> CONFIG_IP_PNP=y
>> CONFIG_IP_PNP_DHCP=y
>> # CONFIG_IP_PNP_BOOTP is not set
>> # CONFIG_IP_PNP_RARP is not set
>> # CONFIG_NET_IPIP is not set
>> # CONFIG_NET_IPGRE_DEMUX is not set
>> CONFIG_NET_IP_TUNNEL=y
>> # CONFIG_SYN_COOKIES is not set
>> # CONFIG_NET_IPVTI is not set
>> # CONFIG_NET_FOU is not set
>> # CONFIG_NET_FOU_IP_TUNNELS is not set
>> # CONFIG_INET_AH is not set
>> # CONFIG_INET_ESP is not set
>> # CONFIG_INET_IPCOMP is not set
>> CONFIG_INET_TUNNEL=y
>> CONFIG_INET_XFRM_MODE_TRANSPORT=y
>> CONFIG_INET_XFRM_MODE_TUNNEL=y
>> CONFIG_INET_XFRM_MODE_BEET=y
>> CONFIG_INET_DIAG=y
>> CONFIG_INET_TCP_DIAG=y
>> # CONFIG_INET_UDP_DIAG is not set
>> # CONFIG_INET_RAW_DIAG is not set
>> # CONFIG_INET_DIAG_DESTROY is not set
>> # CONFIG_TCP_CONG_ADVANCED is not set
>> CONFIG_TCP_CONG_CUBIC=y
>> CONFIG_DEFAULT_TCP_CONG="cubic"
>> # CONFIG_TCP_MD5SIG is not set
>> CONFIG_IPV6=y
>> # CONFIG_IPV6_ROUTER_PREF is not set
>> # CONFIG_IPV6_OPTIMISTIC_DAD is not set
>> # CONFIG_INET6_AH is not set
>> # CONFIG_INET6_ESP is not set
>> # CONFIG_INET6_IPCOMP is not set
>> # CONFIG_IPV6_MIP6 is not set
>> # CONFIG_IPV6_ILA is not set
>> CONFIG_INET6_XFRM_MODE_TRANSPORT=y
>> CONFIG_INET6_XFRM_MODE_TUNNEL=y
>> CONFIG_INET6_XFRM_MODE_BEET=y
>> # CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
>> # CONFIG_IPV6_VTI is not set
>> CONFIG_IPV6_SIT=y
>> # CONFIG_IPV6_SIT_6RD is not set
>> CONFIG_IPV6_NDISC_NODETYPE=y
>> # CONFIG_IPV6_TUNNEL is not set
>> # CONFIG_IPV6_MULTIPLE_TABLES is not set
>> # CONFIG_IPV6_MROUTE is not set
>> # CONFIG_IPV6_SEG6_LWTUNNEL is not set
>> # CONFIG_IPV6_SEG6_HMAC is not set
>> CONFIG_NETWORK_SECMARK=y
>> CONFIG_NET_PTP_CLASSIFY=y
>> # CONFIG_NETWORK_PHY_TIMESTAMPING is not set
>> CONFIG_NETFILTER=y
>> CONFIG_NETFILTER_ADVANCED=y
>> CONFIG_BRIDGE_NETFILTER=m
>>
>> #
>> # Core Netfilter Configuration
>> #
>> CONFIG_NETFILTER_INGRESS=y
>> CONFIG_NETFILTER_FAMILY_BRIDGE=y
>> # CONFIG_NETFILTER_NETLINK_ACCT is not set
>> # CONFIG_NETFILTER_NETLINK_QUEUE is not set
>> # CONFIG_NETFILTER_NETLINK_LOG is not set
>> # CONFIG_NETFILTER_NETLINK_OSF is not set
>> # CONFIG_NF_CONNTRACK is not set
>> # CONFIG_NF_LOG_NETDEV is not set
>> # CONFIG_NF_TABLES is not set
>> # CONFIG_NETFILTER_XTABLES is not set
>> # CONFIG_IP_SET is not set
>> # CONFIG_IP_VS is not set
>>
>> #
>> # IP: Netfilter Configuration
>> #
>> # CONFIG_NF_SOCKET_IPV4 is not set
>> # CONFIG_NF_TPROXY_IPV4 is not set
>> # CONFIG_NF_DUP_IPV4 is not set
>> # CONFIG_NF_LOG_ARP is not set
>> # CONFIG_NF_LOG_IPV4 is not set
>> # CONFIG_NF_REJECT_IPV4 is not set
>> # CONFIG_IP_NF_IPTABLES is not set
>> # CONFIG_IP_NF_ARPTABLES is not set
>>
>> #
>> # IPv6: Netfilter Configuration
>> #
>> # CONFIG_NF_SOCKET_IPV6 is not set
>> # CONFIG_NF_TPROXY_IPV6 is not set
>> # CONFIG_NF_DUP_IPV6 is not set
>> # CONFIG_NF_REJECT_IPV6 is not set
>> # CONFIG_NF_LOG_IPV6 is not set
>> # CONFIG_IP6_NF_IPTABLES is not set
>> # CONFIG_BPFILTER is not set
>> # CONFIG_IP_DCCP is not set
>> # CONFIG_IP_SCTP is not set
>> # CONFIG_RDS is not set
>> # CONFIG_TIPC is not set
>> CONFIG_ATM=y
>> # CONFIG_ATM_CLIP is not set
>> CONFIG_ATM_LANE=y
>> # CONFIG_ATM_MPOA is not set
>> # CONFIG_ATM_BR2684 is not set
>> # CONFIG_L2TP is not set
>> CONFIG_STP=m
>> CONFIG_GARP=m
>> CONFIG_BRIDGE=m
>> CONFIG_BRIDGE_IGMP_SNOOPING=y
>> CONFIG_BRIDGE_VLAN_FILTERING=y
>> CONFIG_HAVE_NET_DSA=y
>> # CONFIG_NET_DSA is not set
>> CONFIG_VLAN_8021Q=m
>> CONFIG_VLAN_8021Q_GVRP=y
>> # CONFIG_VLAN_8021Q_MVRP is not set
>> # CONFIG_DECNET is not set
>> CONFIG_LLC=y
>> CONFIG_LLC2=m
>> CONFIG_ATALK=y
>> # CONFIG_DEV_APPLETALK is not set
>> CONFIG_X25=y
>> # CONFIG_LAPB is not set
>> CONFIG_PHONET=y
>> # CONFIG_6LOWPAN is not set
>> CONFIG_IEEE802154=m
>> # CONFIG_IEEE802154_NL802154_EXPERIMENTAL is not set
>> # CONFIG_IEEE802154_SOCKET is not set
>> CONFIG_MAC802154=m
>> CONFIG_NET_SCHED=y
>>
>> #
>> # Queueing/Scheduling
>> #
>> # CONFIG_NET_SCH_CBQ is not set
>> # CONFIG_NET_SCH_HTB is not set
>> CONFIG_NET_SCH_HFSC=m
>> CONFIG_NET_SCH_ATM=y
>> CONFIG_NET_SCH_PRIO=y
>> CONFIG_NET_SCH_MULTIQ=m
>> # CONFIG_NET_SCH_RED is not set
>> CONFIG_NET_SCH_SFB=m
>> # CONFIG_NET_SCH_SFQ is not set
>> # CONFIG_NET_SCH_TEQL is not set
>> CONFIG_NET_SCH_TBF=y
>> # CONFIG_NET_SCH_CBS is not set
>> CONFIG_NET_SCH_ETF=y
>> CONFIG_NET_SCH_TAPRIO=m
>> CONFIG_NET_SCH_GRED=y
>> CONFIG_NET_SCH_DSMARK=m
>> CONFIG_NET_SCH_NETEM=y
>> CONFIG_NET_SCH_DRR=m
>> # CONFIG_NET_SCH_MQPRIO is not set
>> # CONFIG_NET_SCH_SKBPRIO is not set
>> CONFIG_NET_SCH_CHOKE=m
>> # CONFIG_NET_SCH_QFQ is not set
>> CONFIG_NET_SCH_CODEL=y
>> CONFIG_NET_SCH_FQ_CODEL=m
>> # CONFIG_NET_SCH_CAKE is not set
>> CONFIG_NET_SCH_FQ=m
>> CONFIG_NET_SCH_HHF=y
>> CONFIG_NET_SCH_PIE=m
>> CONFIG_NET_SCH_PLUG=y
>> # CONFIG_NET_SCH_DEFAULT is not set
>>
>> #
>> # Classification
>> #
>> CONFIG_NET_CLS=y
>> CONFIG_NET_CLS_BASIC=m
>> CONFIG_NET_CLS_TCINDEX=m
>> # CONFIG_NET_CLS_ROUTE4 is not set
>> # CONFIG_NET_CLS_FW is not set
>> CONFIG_NET_CLS_U32=m
>> # CONFIG_CLS_U32_PERF is not set
>> CONFIG_CLS_U32_MARK=y
>> CONFIG_NET_CLS_RSVP=m
>> # CONFIG_NET_CLS_RSVP6 is not set
>> CONFIG_NET_CLS_FLOW=y
>> # CONFIG_NET_CLS_CGROUP is not set
>> CONFIG_NET_CLS_BPF=m
>> CONFIG_NET_CLS_FLOWER=m
>> CONFIG_NET_CLS_MATCHALL=y
>> CONFIG_NET_EMATCH=y
>> CONFIG_NET_EMATCH_STACK=32
>> # CONFIG_NET_EMATCH_CMP is not set
>> CONFIG_NET_EMATCH_NBYTE=m
>> CONFIG_NET_EMATCH_U32=m
>> # CONFIG_NET_EMATCH_META is not set
>> CONFIG_NET_EMATCH_TEXT=y
>> # CONFIG_NET_EMATCH_CANID is not set
>> # CONFIG_NET_CLS_ACT is not set
>> # CONFIG_NET_CLS_IND is not set
>> CONFIG_NET_SCH_FIFO=y
>> CONFIG_DCB=y
>> CONFIG_DNS_RESOLVER=m
>> # CONFIG_BATMAN_ADV is not set
>> # CONFIG_OPENVSWITCH is not set
>> CONFIG_VSOCKETS=m
>> # CONFIG_VSOCKETS_DIAG is not set
>> CONFIG_VMWARE_VMCI_VSOCKETS=m
>> CONFIG_VIRTIO_VSOCKETS=m
>> CONFIG_VIRTIO_VSOCKETS_COMMON=m
>> CONFIG_NETLINK_DIAG=y
>> CONFIG_MPLS=y
>> # CONFIG_NET_MPLS_GSO is not set
>> # CONFIG_MPLS_ROUTING is not set
>> CONFIG_NET_NSH=m
>> CONFIG_HSR=m
>> # CONFIG_NET_SWITCHDEV is not set
>> # CONFIG_NET_L3_MASTER_DEV is not set
>> # CONFIG_NET_NCSI is not set
>> CONFIG_RPS=y
>> CONFIG_RFS_ACCEL=y
>> CONFIG_XPS=y
>> # CONFIG_CGROUP_NET_PRIO is not set
>> # CONFIG_CGROUP_NET_CLASSID is not set
>> CONFIG_NET_RX_BUSY_POLL=y
>> CONFIG_BQL=y
>> CONFIG_BPF_JIT=y
>> CONFIG_NET_FLOW_LIMIT=y
>>
>> #
>> # Network testing
>> #
>> # CONFIG_NET_PKTGEN is not set
>> # CONFIG_NET_DROP_MONITOR is not set
>> # CONFIG_HAMRADIO is not set
>> CONFIG_CAN=y
>> CONFIG_CAN_RAW=m
>> CONFIG_CAN_BCM=y
>> CONFIG_CAN_GW=m
>>
>> #
>> # CAN Device Drivers
>> #
>> CONFIG_CAN_VCAN=y
>> CONFIG_CAN_VXCAN=y
>> CONFIG_CAN_SLCAN=y
>> CONFIG_CAN_DEV=y
>> # CONFIG_CAN_CALC_BITTIMING is not set
>> # CONFIG_CAN_FLEXCAN is not set
>> CONFIG_CAN_GRCAN=m
>> CONFIG_CAN_JANZ_ICAN3=m
>> CONFIG_CAN_C_CAN=y
>> CONFIG_CAN_C_CAN_PLATFORM=m
>> CONFIG_CAN_C_CAN_PCI=m
>> CONFIG_CAN_CC770=m
>> # CONFIG_CAN_CC770_ISA is not set
>> CONFIG_CAN_CC770_PLATFORM=m
>> CONFIG_CAN_IFI_CANFD=y
>> CONFIG_CAN_M_CAN=m
>> # CONFIG_CAN_PEAK_PCIEFD is not set
>> CONFIG_CAN_SJA1000=y
>> CONFIG_CAN_SJA1000_ISA=m
>> CONFIG_CAN_SJA1000_PLATFORM=m
>> # CONFIG_CAN_EMS_PCMCIA is not set
>> # CONFIG_CAN_EMS_PCI is not set
>> CONFIG_CAN_PEAK_PCMCIA=y
>> CONFIG_CAN_PEAK_PCI=y
>> # CONFIG_CAN_PEAK_PCIEC is not set
>> CONFIG_CAN_KVASER_PCI=m
>> # CONFIG_CAN_PLX_PCI is not set
>> CONFIG_CAN_SOFTING=m
>> CONFIG_CAN_SOFTING_CS=m
>> # CONFIG_CAN_DEBUG_DEVICES is not set
>> # CONFIG_BT is not set
>> # CONFIG_AF_RXRPC is not set
>> # CONFIG_AF_KCM is not set
>> CONFIG_WIRELESS=y
>> CONFIG_WIRELESS_EXT=y
>> CONFIG_WEXT_CORE=y
>> CONFIG_WEXT_PROC=y
>> CONFIG_WEXT_SPY=y
>> CONFIG_WEXT_PRIV=y
>> CONFIG_CFG80211=m
>> # CONFIG_NL80211_TESTMODE is not set
>> CONFIG_CFG80211_DEVELOPER_WARNINGS=y
>> CONFIG_CFG80211_CERTIFICATION_ONUS=y
>> # CONFIG_CFG80211_REQUIRE_SIGNED_REGDB is not set
>> # CONFIG_CFG80211_REG_CELLULAR_HINTS is not set
>> # CONFIG_CFG80211_REG_RELAX_NO_IR is not set
>> CONFIG_CFG80211_DEFAULT_PS=y
>> CONFIG_CFG80211_DEBUGFS=y
>> CONFIG_CFG80211_CRDA_SUPPORT=y
>> # CONFIG_CFG80211_WEXT is not set
>> CONFIG_MAC80211=m
>> CONFIG_MAC80211_HAS_RC=y
>> CONFIG_MAC80211_RC_MINSTREL=y
>> CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
>> CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
>> # CONFIG_MAC80211_MESH is not set
>> # CONFIG_MAC80211_LEDS is not set
>> CONFIG_MAC80211_DEBUGFS=y
>> CONFIG_MAC80211_MESSAGE_TRACING=y
>> # CONFIG_MAC80211_DEBUG_MENU is not set
>> CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
>> # CONFIG_WIMAX is not set
>> CONFIG_RFKILL=y
>> CONFIG_RFKILL_LEDS=y
>> # CONFIG_RFKILL_INPUT is not set
>> # CONFIG_RFKILL_GPIO is not set
>> CONFIG_NET_9P=y
>> CONFIG_NET_9P_VIRTIO=y
>> # CONFIG_NET_9P_DEBUG is not set
>> CONFIG_CAIF=y
>> # CONFIG_CAIF_DEBUG is not set
>> CONFIG_CAIF_NETDEV=m
>> # CONFIG_CAIF_USB is not set
>> # CONFIG_CEPH_LIB is not set
>> CONFIG_NFC=m
>> # CONFIG_NFC_DIGITAL is not set
>> # CONFIG_NFC_NCI is not set
>> # CONFIG_NFC_HCI is not set
>>
>> #
>> # Near Field Communication (NFC) devices
>> #
>> # CONFIG_NFC_PN533_I2C is not set
>> CONFIG_PSAMPLE=y
>> CONFIG_NET_IFE=y
>> # CONFIG_LWTUNNEL is not set
>> CONFIG_DST_CACHE=y
>> CONFIG_GRO_CELLS=y
>> CONFIG_NET_DEVLINK=m
>> CONFIG_MAY_USE_DEVLINK=m
>> CONFIG_FAILOVER=m
>> CONFIG_HAVE_EBPF_JIT=y
>>
>> #
>> # Device Drivers
>> #
>> CONFIG_HAVE_EISA=y
>> # CONFIG_EISA is not set
>> CONFIG_HAVE_PCI=y
>> CONFIG_PCI=y
>> CONFIG_PCI_DOMAINS=y
>> CONFIG_PCIEPORTBUS=y
>> # CONFIG_HOTPLUG_PCI_PCIE is not set
>> # CONFIG_PCIEAER is not set
>> CONFIG_PCIEASPM=y
>> # CONFIG_PCIEASPM_DEBUG is not set
>> # CONFIG_PCIEASPM_DEFAULT is not set
>> # CONFIG_PCIEASPM_POWERSAVE is not set
>> CONFIG_PCIEASPM_POWER_SUPERSAVE=y
>> # CONFIG_PCIEASPM_PERFORMANCE is not set
>> CONFIG_PCIE_PME=y
>> CONFIG_PCIE_PTM=y
>> CONFIG_PCI_MSI=y
>> CONFIG_PCI_MSI_IRQ_DOMAIN=y
>> CONFIG_PCI_QUIRKS=y
>> # CONFIG_PCI_DEBUG is not set
>> # CONFIG_PCI_STUB is not set
>> CONFIG_PCI_ATS=y
>> CONFIG_PCI_ECAM=y
>> CONFIG_PCI_LOCKLESS_CONFIG=y
>> # CONFIG_PCI_IOV is not set
>> # CONFIG_PCI_PRI is not set
>> CONFIG_PCI_PASID=y
>> CONFIG_PCI_LABEL=y
>> CONFIG_HOTPLUG_PCI=y
>> # CONFIG_HOTPLUG_PCI_ACPI is not set
>> # CONFIG_HOTPLUG_PCI_CPCI is not set
>> CONFIG_HOTPLUG_PCI_SHPC=y
>>
>> #
>> # PCI controller drivers
>> #
>>
>> #
>> # Cadence PCIe controllers support
>> #
>> CONFIG_PCIE_CADENCE=y
>> CONFIG_PCIE_CADENCE_HOST=y
>> # CONFIG_PCI_FTPCI100 is not set
>> CONFIG_PCI_HOST_COMMON=y
>> CONFIG_PCI_HOST_GENERIC=y
>> # CONFIG_PCIE_XILINX is not set
>> CONFIG_VMD=m
>>
>> #
>> # DesignWare PCI Core Support
>> #
>> CONFIG_PCIE_DW=y
>> CONFIG_PCIE_DW_HOST=y
>> CONFIG_PCIE_DW_PLAT=y
>> CONFIG_PCIE_DW_PLAT_HOST=y
>> # CONFIG_PCI_MESON is not set
>>
>> #
>> # PCI Endpoint
>> #
>> # CONFIG_PCI_ENDPOINT is not set
>>
>> #
>> # PCI switch controller drivers
>> #
>> CONFIG_PCI_SW_SWITCHTEC=y
>> CONFIG_PCCARD=y
>> CONFIG_PCMCIA=y
>> # CONFIG_PCMCIA_LOAD_CIS is not set
>> CONFIG_CARDBUS=y
>>
>> #
>> # PC-card bridges
>> #
>> CONFIG_YENTA=y
>> CONFIG_YENTA_O2=y
>> CONFIG_YENTA_RICOH=y
>> CONFIG_YENTA_TI=y
>> # CONFIG_YENTA_ENE_TUNE is not set
>> # CONFIG_YENTA_TOSHIBA is not set
>> CONFIG_PD6729=m
>> CONFIG_I82092=m
>> CONFIG_PCCARD_NONSTATIC=y
>> # CONFIG_RAPIDIO is not set
>>
>> #
>> # Generic Driver Options
>> #
>> # CONFIG_UEVENT_HELPER is not set
>> CONFIG_DEVTMPFS=y
>> # CONFIG_DEVTMPFS_MOUNT is not set
>> CONFIG_STANDALONE=y
>> CONFIG_PREVENT_FIRMWARE_BUILD=y
>>
>> #
>> # Firmware loader
>> #
>> CONFIG_FW_LOADER=y
>> CONFIG_EXTRA_FIRMWARE=""
>> CONFIG_FW_LOADER_USER_HELPER=y
>> # CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
>> CONFIG_WANT_DEV_COREDUMP=y
>> CONFIG_ALLOW_DEV_COREDUMP=y
>> CONFIG_DEV_COREDUMP=y
>> # CONFIG_DEBUG_DRIVER is not set
>> # CONFIG_DEBUG_DEVRES is not set
>> CONFIG_DEBUG_TEST_DRIVER_REMOVE=y
>> CONFIG_TEST_ASYNC_DRIVER_PROBE=m
>> CONFIG_GENERIC_CPU_AUTOPROBE=y
>> CONFIG_GENERIC_CPU_VULNERABILITIES=y
>> CONFIG_REGMAP=y
>> CONFIG_REGMAP_I2C=y
>> CONFIG_REGMAP_W1=m
>> CONFIG_REGMAP_MMIO=y
>> CONFIG_REGMAP_IRQ=y
>> CONFIG_DMA_SHARED_BUFFER=y
>> CONFIG_DMA_FENCE_TRACE=y
>> # CONFIG_DMA_CMA is not set
>>
>> #
>> # Bus devices
>> #
>> # CONFIG_SIMPLE_PM_BUS is not set
>> # CONFIG_CONNECTOR is not set
>> CONFIG_GNSS=y
>> CONFIG_MTD=m
>> CONFIG_MTD_TESTS=m
>> CONFIG_MTD_CMDLINE_PARTS=m
>> CONFIG_MTD_OF_PARTS=m
>> CONFIG_MTD_AR7_PARTS=m
>>
>> #
>> # Partition parsers
>> #
>> CONFIG_MTD_REDBOOT_PARTS=m
>> CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
>> # CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
>> # CONFIG_MTD_REDBOOT_PARTS_READONLY is not set
>>
>> #
>> # User Modules And Translation Layers
>> #
>> CONFIG_MTD_OOPS=m
>> # CONFIG_MTD_PARTITIONED_MASTER is not set
>>
>> #
>> # RAM/ROM/Flash chip drivers
>> #
>> CONFIG_MTD_CFI=m
>> CONFIG_MTD_JEDECPROBE=m
>> CONFIG_MTD_GEN_PROBE=m
>> # CONFIG_MTD_CFI_ADV_OPTIONS is not set
>> CONFIG_MTD_MAP_BANK_WIDTH_1=y
>> CONFIG_MTD_MAP_BANK_WIDTH_2=y
>> CONFIG_MTD_MAP_BANK_WIDTH_4=y
>> CONFIG_MTD_CFI_I1=y
>> CONFIG_MTD_CFI_I2=y
>> CONFIG_MTD_CFI_INTELEXT=m
>> CONFIG_MTD_CFI_AMDSTD=m
>> CONFIG_MTD_CFI_STAA=m
>> CONFIG_MTD_CFI_UTIL=m
>> CONFIG_MTD_RAM=m
>> # CONFIG_MTD_ROM is not set
>> # CONFIG_MTD_ABSENT is not set
>>
>> #
>> # Mapping drivers for chip access
>> #
>> CONFIG_MTD_COMPLEX_MAPPINGS=y
>> CONFIG_MTD_PHYSMAP=m
>> CONFIG_MTD_PHYSMAP_COMPAT=y
>> CONFIG_MTD_PHYSMAP_START=0x8000000
>> CONFIG_MTD_PHYSMAP_LEN=0
>> CONFIG_MTD_PHYSMAP_BANKWIDTH=2
>> # CONFIG_MTD_PHYSMAP_OF is not set
>> # CONFIG_MTD_PHYSMAP_GPIO_ADDR is not set
>> CONFIG_MTD_SBC_GXX=m
>> CONFIG_MTD_AMD76XROM=m
>> # CONFIG_MTD_ICHXROM is not set
>> CONFIG_MTD_ESB2ROM=m
>> CONFIG_MTD_CK804XROM=m
>> CONFIG_MTD_SCB2_FLASH=m
>> CONFIG_MTD_NETtel=m
>> CONFIG_MTD_L440GX=m
>> # CONFIG_MTD_PCI is not set
>> CONFIG_MTD_PCMCIA=m
>> # CONFIG_MTD_PCMCIA_ANONYMOUS is not set
>> CONFIG_MTD_INTEL_VR_NOR=m
>> CONFIG_MTD_PLATRAM=m
>>
>> #
>> # Self-contained MTD device drivers
>> #
>> # CONFIG_MTD_PMC551 is not set
>> # CONFIG_MTD_SLRAM is not set
>> # CONFIG_MTD_PHRAM is not set
>> CONFIG_MTD_MTDRAM=m
>> CONFIG_MTDRAM_TOTAL_SIZE=4096
>> CONFIG_MTDRAM_ERASE_SIZE=128
>>
>> #
>> # Disk-On-Chip Device Drivers
>> #
>> CONFIG_MTD_DOCG3=m
>> CONFIG_BCH_CONST_M=14
>> CONFIG_BCH_CONST_T=4
>> CONFIG_MTD_ONENAND=m
>> CONFIG_MTD_ONENAND_VERIFY_WRITE=y
>> # CONFIG_MTD_ONENAND_GENERIC is not set
>> # CONFIG_MTD_ONENAND_OTP is not set
>> # CONFIG_MTD_ONENAND_2X_PROGRAM is not set
>> # CONFIG_MTD_NAND is not set
>>
>> #
>> # LPDDR & LPDDR2 PCM memory drivers
>> #
>> CONFIG_MTD_LPDDR=m
>> CONFIG_MTD_QINFO_PROBE=m
>> # CONFIG_MTD_SPI_NOR is not set
>> CONFIG_MTD_UBI=m
>> CONFIG_MTD_UBI_WL_THRESHOLD=4096
>> CONFIG_MTD_UBI_BEB_LIMIT=20
>> CONFIG_MTD_UBI_FASTMAP=y
>> CONFIG_MTD_UBI_GLUEBI=m
>> CONFIG_DTC=y
>> CONFIG_OF=y
>> # CONFIG_OF_UNITTEST is not set
>> CONFIG_OF_FLATTREE=y
>> CONFIG_OF_KOBJ=y
>> CONFIG_OF_DYNAMIC=y
>> CONFIG_OF_ADDRESS=y
>> CONFIG_OF_IRQ=y
>> CONFIG_OF_NET=y
>> CONFIG_OF_MDIO=y
>> CONFIG_OF_RESOLVE=y
>> CONFIG_OF_OVERLAY=y
>> CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
>> # CONFIG_PARPORT is not set
>> CONFIG_PNP=y
>> CONFIG_PNP_DEBUG_MESSAGES=y
>>
>> #
>> # Protocols
>> #
>> CONFIG_PNPACPI=y
>>
>> #
>> # NVME Support
>> #
>>
>> #
>> # Misc devices
>> #
>> CONFIG_AD525X_DPOT=y
>> CONFIG_AD525X_DPOT_I2C=m
>> CONFIG_DUMMY_IRQ=y
>> # CONFIG_IBM_ASM is not set
>> CONFIG_PHANTOM=y
>> CONFIG_SGI_IOC4=m
>> CONFIG_TIFM_CORE=m
>> # CONFIG_TIFM_7XX1 is not set
>> CONFIG_ICS932S401=y
>> CONFIG_ENCLOSURE_SERVICES=y
>> # CONFIG_HP_ILO is not set
>> CONFIG_APDS9802ALS=y
>> CONFIG_ISL29003=y
>> CONFIG_ISL29020=y
>> CONFIG_SENSORS_TSL2550=y
>> CONFIG_SENSORS_BH1770=y
>> CONFIG_SENSORS_APDS990X=m
>> CONFIG_HMC6352=m
>> # CONFIG_DS1682 is not set
>> # CONFIG_VMWARE_BALLOON is not set
>> CONFIG_USB_SWITCH_FSA9480=m
>> CONFIG_SRAM=y
>> CONFIG_PCI_ENDPOINT_TEST=y
>> CONFIG_MISC_RTSX=y
>> # CONFIG_PVPANIC is not set
>> CONFIG_C2PORT=y
>> CONFIG_C2PORT_DURAMAR_2150=m
>>
>> #
>> # EEPROM support
>> #
>> # CONFIG_EEPROM_AT24 is not set
>> # CONFIG_EEPROM_LEGACY is not set
>> # CONFIG_EEPROM_MAX6875 is not set
>> CONFIG_EEPROM_93CX6=y
>> CONFIG_EEPROM_IDT_89HPESX=y
>> CONFIG_EEPROM_EE1004=y
>> CONFIG_CB710_CORE=y
>> # CONFIG_CB710_DEBUG is not set
>> CONFIG_CB710_DEBUG_ASSUMPTIONS=y
>>
>> #
>> # Texas Instruments shared transport line discipline
>> #
>> # CONFIG_TI_ST is not set
>> # CONFIG_SENSORS_LIS3_I2C is not set
>> CONFIG_ALTERA_STAPL=y
>> CONFIG_INTEL_MEI=y
>> # CONFIG_INTEL_MEI_ME is not set
>> CONFIG_INTEL_MEI_TXE=y
>> CONFIG_VMWARE_VMCI=y
>>
>> #
>> # Intel MIC & related support
>> #
>>
>> #
>> # Intel MIC Bus Driver
>> #
>> CONFIG_INTEL_MIC_BUS=m
>>
>> #
>> # SCIF Bus Driver
>> #
>> CONFIG_SCIF_BUS=y
>>
>> #
>> # VOP Bus Driver
>> #
>> CONFIG_VOP_BUS=m
>>
>> #
>> # Intel MIC Host Driver
>> #
>>
>> #
>> # Intel MIC Card Driver
>> #
>>
>> #
>> # SCIF Driver
>> #
>>
>> #
>> # Intel MIC Coprocessor State Management (COSM) Drivers
>> #
>>
>> #
>> # VOP Driver
>> #
>> CONFIG_VOP=m
>> CONFIG_VHOST_RING=m
>> # CONFIG_GENWQE is not set
>> CONFIG_ECHO=m
>> CONFIG_MISC_ALCOR_PCI=y
>> CONFIG_MISC_RTSX_PCI=y
>> CONFIG_HAVE_IDE=y
>>
>> #
>> # SCSI device support
>> #
>> CONFIG_SCSI_MOD=y
>> CONFIG_FUSION=y
>> CONFIG_FUSION_MAX_SGE=128
>> CONFIG_FUSION_LOGGING=y
>>
>> #
>> # IEEE 1394 (FireWire) support
>> #
>> # CONFIG_FIREWIRE is not set
>> # CONFIG_FIREWIRE_NOSY is not set
>> # CONFIG_MACINTOSH_DRIVERS is not set
>> CONFIG_NETDEVICES=y
>> CONFIG_MII=y
>> # CONFIG_NET_CORE is not set
>> CONFIG_ARCNET=m
>> CONFIG_ARCNET_1201=m
>> CONFIG_ARCNET_1051=m
>> # CONFIG_ARCNET_RAW is not set
>> # CONFIG_ARCNET_CAP is not set
>> CONFIG_ARCNET_COM90xx=m
>> # CONFIG_ARCNET_COM90xxIO is not set
>> CONFIG_ARCNET_RIM_I=m
>> CONFIG_ARCNET_COM20020=m
>> # CONFIG_ARCNET_COM20020_PCI is not set
>> CONFIG_ARCNET_COM20020_CS=m
>> CONFIG_ATM_DRIVERS=y
>> CONFIG_ATM_DUMMY=y
>> # CONFIG_ATM_TCP is not set
>> # CONFIG_ATM_LANAI is not set
>> CONFIG_ATM_ENI=m
>> # CONFIG_ATM_ENI_DEBUG is not set
>> # CONFIG_ATM_ENI_TUNE_BURST is not set
>> # CONFIG_ATM_FIRESTREAM is not set
>> CONFIG_ATM_ZATM=m
>> CONFIG_ATM_ZATM_DEBUG=y
>> CONFIG_ATM_NICSTAR=y
>> CONFIG_ATM_NICSTAR_USE_SUNI=y
>> CONFIG_ATM_NICSTAR_USE_IDT77105=y
>> # CONFIG_ATM_IDT77252 is not set
>> CONFIG_ATM_AMBASSADOR=y
>> # CONFIG_ATM_AMBASSADOR_DEBUG is not set
>> CONFIG_ATM_HORIZON=y
>> # CONFIG_ATM_HORIZON_DEBUG is not set
>> # CONFIG_ATM_IA is not set
>> CONFIG_ATM_FORE200E=y
>> CONFIG_ATM_FORE200E_USE_TASKLET=y
>> CONFIG_ATM_FORE200E_TX_RETRY=16
>> CONFIG_ATM_FORE200E_DEBUG=0
>> CONFIG_ATM_HE=y
>> CONFIG_ATM_HE_USE_SUNI=y
>> # CONFIG_ATM_SOLOS is not set
>>
>> #
>> # CAIF transport drivers
>> #
>> # CONFIG_CAIF_TTY is not set
>> CONFIG_CAIF_SPI_SLAVE=m
>> CONFIG_CAIF_SPI_SYNC=y
>> # CONFIG_CAIF_HSI is not set
>> CONFIG_CAIF_VIRTIO=m
>>
>> #
>> # Distributed Switch Architecture drivers
>> #
>> CONFIG_ETHERNET=y
>> CONFIG_MDIO=y
>> CONFIG_NET_VENDOR_3COM=y
>> # CONFIG_PCMCIA_3C574 is not set
>> CONFIG_PCMCIA_3C589=m
>> CONFIG_VORTEX=m
>> # CONFIG_TYPHOON is not set
>> # CONFIG_NET_VENDOR_ADAPTEC is not set
>> # CONFIG_NET_VENDOR_AGERE is not set
>> # CONFIG_NET_VENDOR_ALACRITECH is not set
>> # CONFIG_NET_VENDOR_ALTEON is not set
>> # CONFIG_ALTERA_TSE is not set
>> # CONFIG_NET_VENDOR_AMAZON is not set
>> CONFIG_NET_VENDOR_AMD=y
>> # CONFIG_AMD8111_ETH is not set
>> CONFIG_PCNET32=y
>> CONFIG_PCMCIA_NMCLAN=y
>> CONFIG_AMD_XGBE=y
>> CONFIG_AMD_XGBE_DCB=y
>> CONFIG_AMD_XGBE_HAVE_ECC=y
>> CONFIG_NET_VENDOR_AQUANTIA=y
>> # CONFIG_AQTION is not set
>> CONFIG_NET_VENDOR_ARC=y
>> CONFIG_NET_VENDOR_ATHEROS=y
>> CONFIG_ATL2=m
>> CONFIG_ATL1=m
>> # CONFIG_ATL1E is not set
>> CONFIG_ATL1C=y
>> CONFIG_ALX=y
>> CONFIG_NET_VENDOR_AURORA=y
>> # CONFIG_AURORA_NB8800 is not set
>> # CONFIG_NET_VENDOR_BROADCOM is not set
>> # CONFIG_NET_VENDOR_BROCADE is not set
>> # CONFIG_NET_VENDOR_CADENCE is not set
>> CONFIG_NET_VENDOR_CAVIUM=y
>> # CONFIG_THUNDER_NIC_PF is not set
>> CONFIG_THUNDER_NIC_VF=m
>> # CONFIG_THUNDER_NIC_BGX is not set
>> CONFIG_THUNDER_NIC_RGX=y
>> CONFIG_CAVIUM_PTP=m
>> # CONFIG_LIQUIDIO is not set
>> CONFIG_LIQUIDIO_VF=y
>> CONFIG_NET_VENDOR_CHELSIO=y
>> CONFIG_CHELSIO_T1=y
>> CONFIG_CHELSIO_T1_1G=y
>> # CONFIG_CHELSIO_T3 is not set
>> # CONFIG_CHELSIO_T4 is not set
>> # CONFIG_CHELSIO_T4VF is not set
>> CONFIG_NET_VENDOR_CISCO=y
>> CONFIG_ENIC=m
>> # CONFIG_NET_VENDOR_CORTINA is not set
>> CONFIG_CX_ECAT=m
>> # CONFIG_DNET is not set
>> CONFIG_NET_VENDOR_DEC=y
>> CONFIG_NET_TULIP=y
>> CONFIG_DE2104X=m
>> CONFIG_DE2104X_DSL=0
>> CONFIG_TULIP=y
>> CONFIG_TULIP_MWI=y
>> # CONFIG_TULIP_MMIO is not set
>> # CONFIG_TULIP_NAPI is not set
>> CONFIG_DE4X5=y
>> CONFIG_WINBOND_840=y
>> # CONFIG_DM9102 is not set
>> # CONFIG_ULI526X is not set
>> CONFIG_PCMCIA_XIRCOM=y
>> CONFIG_NET_VENDOR_DLINK=y
>> CONFIG_DL2K=y
>> CONFIG_SUNDANCE=m
>> CONFIG_SUNDANCE_MMIO=y
>> CONFIG_NET_VENDOR_EMULEX=y
>> CONFIG_BE2NET=m
>> CONFIG_BE2NET_HWMON=y
>> CONFIG_BE2NET_BE2=y
>> # CONFIG_BE2NET_BE3 is not set
>> CONFIG_BE2NET_LANCER=y
>> CONFIG_BE2NET_SKYHAWK=y
>> CONFIG_NET_VENDOR_EZCHIP=y
>> CONFIG_EZCHIP_NPS_MANAGEMENT_ENET=m
>> # CONFIG_NET_VENDOR_FUJITSU is not set
>> CONFIG_NET_VENDOR_HP=y
>> # CONFIG_HP100 is not set
>> CONFIG_NET_VENDOR_HUAWEI=y
>> CONFIG_HINIC=y
>> CONFIG_NET_VENDOR_I825XX=y
>> CONFIG_NET_VENDOR_INTEL=y
>> # CONFIG_E100 is not set
>> CONFIG_E1000=y
>> CONFIG_E1000E=m
>> CONFIG_E1000E_HWTS=y
>> CONFIG_IGB=m
>> CONFIG_IGB_HWMON=y
>> CONFIG_IGB_DCA=y
>> # CONFIG_IGBVF is not set
>> # CONFIG_IXGB is not set
>> CONFIG_IXGBE=m
>> CONFIG_IXGBE_HWMON=y
>> CONFIG_IXGBE_DCA=y
>> # CONFIG_IXGBE_DCB is not set
>> # CONFIG_IXGBEVF is not set
>> # CONFIG_I40E is not set
>> # CONFIG_I40EVF is not set
>> # CONFIG_ICE is not set
>> # CONFIG_FM10K is not set
>> # CONFIG_IGC is not set
>> # CONFIG_JME is not set
>> CONFIG_NET_VENDOR_MARVELL=y
>> CONFIG_MVMDIO=m
>> # CONFIG_SKGE is not set
>> CONFIG_SKY2=m
>> CONFIG_SKY2_DEBUG=y
>> CONFIG_NET_VENDOR_MELLANOX=y
>> # CONFIG_MLX4_EN is not set
>> # CONFIG_MLX5_CORE is not set
>> # CONFIG_MLXSW_CORE is not set
>> # CONFIG_MLXFW is not set
>> CONFIG_NET_VENDOR_MICREL=y
>> CONFIG_KS8842=y
>> CONFIG_KS8851_MLL=m
>> CONFIG_KSZ884X_PCI=y
>> CONFIG_NET_VENDOR_MICROCHIP=y
>> CONFIG_LAN743X=y
>> CONFIG_NET_VENDOR_MICROSEMI=y
>> CONFIG_NET_VENDOR_MYRI=y
>> # CONFIG_MYRI10GE is not set
>> CONFIG_FEALNX=m
>> # CONFIG_NET_VENDOR_NATSEMI is not set
>> # CONFIG_NET_VENDOR_NETERION is not set
>> CONFIG_NET_VENDOR_NETRONOME=y
>> # CONFIG_NFP is not set
>> # CONFIG_NET_VENDOR_NI is not set
>> CONFIG_NET_VENDOR_NVIDIA=y
>> CONFIG_FORCEDETH=y
>> CONFIG_NET_VENDOR_OKI=y
>> # CONFIG_ETHOC is not set
>> # CONFIG_NET_VENDOR_PACKET_ENGINES is not set
>> CONFIG_NET_VENDOR_QLOGIC=y
>> CONFIG_QLA3XXX=y
>> # CONFIG_QLCNIC is not set
>> CONFIG_QLGE=m
>> CONFIG_NETXEN_NIC=y
>> CONFIG_QED=m
>> CONFIG_QEDE=m
>> # CONFIG_NET_VENDOR_QUALCOMM is not set
>> # CONFIG_NET_VENDOR_RDC is not set
>> CONFIG_NET_VENDOR_REALTEK=y
>> CONFIG_8139CP=y
>> CONFIG_8139TOO=m
>> # CONFIG_8139TOO_PIO is not set
>> # CONFIG_8139TOO_TUNE_TWISTER is not set
>> CONFIG_8139TOO_8129=y
>> CONFIG_8139_OLD_RX_RESET=y
>> CONFIG_R8169=y
>> CONFIG_NET_VENDOR_RENESAS=y
>> # CONFIG_NET_VENDOR_ROCKER is not set
>> # CONFIG_NET_VENDOR_SAMSUNG is not set
>> # CONFIG_NET_VENDOR_SEEQ is not set
>> # CONFIG_NET_VENDOR_SOLARFLARE is not set
>> CONFIG_NET_VENDOR_SILAN=y
>> CONFIG_SC92031=m
>> CONFIG_NET_VENDOR_SIS=y
>> # CONFIG_SIS900 is not set
>> # CONFIG_SIS190 is not set
>> CONFIG_NET_VENDOR_SMSC=y
>> CONFIG_PCMCIA_SMC91C92=y
>> # CONFIG_EPIC100 is not set
>> CONFIG_SMSC911X=y
>> # CONFIG_SMSC9420 is not set
>> CONFIG_NET_VENDOR_SOCIONEXT=y
>> # CONFIG_NET_VENDOR_STMICRO is not set
>> # CONFIG_NET_VENDOR_SUN is not set
>> CONFIG_NET_VENDOR_SYNOPSYS=y
>> CONFIG_DWC_XLGMAC=y
>> # CONFIG_DWC_XLGMAC_PCI is not set
>> # CONFIG_NET_VENDOR_TEHUTI is not set
>> # CONFIG_NET_VENDOR_TI is not set
>> CONFIG_NET_VENDOR_VIA=y
>> # CONFIG_VIA_RHINE is not set
>> CONFIG_VIA_VELOCITY=y
>> CONFIG_NET_VENDOR_WIZNET=y
>> # CONFIG_WIZNET_W5100 is not set
>> CONFIG_WIZNET_W5300=m
>> # CONFIG_WIZNET_BUS_DIRECT is not set
>> # CONFIG_WIZNET_BUS_INDIRECT is not set
>> CONFIG_WIZNET_BUS_ANY=y
>> # CONFIG_NET_VENDOR_XIRCOM is not set
>> CONFIG_FDDI=y
>> CONFIG_DEFXX=y
>> # CONFIG_DEFXX_MMIO is not set
>> CONFIG_SKFP=m
>> # CONFIG_HIPPI is not set
>> # CONFIG_NET_SB1000 is not set
>> CONFIG_MDIO_DEVICE=y
>> CONFIG_MDIO_BUS=y
>> CONFIG_MDIO_BCM_UNIMAC=m
>> CONFIG_MDIO_BITBANG=m
>> CONFIG_MDIO_BUS_MUX=m
>> CONFIG_MDIO_BUS_MUX_GPIO=m
>> CONFIG_MDIO_BUS_MUX_MMIOREG=m
>> CONFIG_MDIO_CAVIUM=y
>> CONFIG_MDIO_GPIO=m
>> CONFIG_MDIO_HISI_FEMAC=m
>> # CONFIG_MDIO_MSCC_MIIM is not set
>> # CONFIG_MDIO_OCTEON is not set
>> CONFIG_MDIO_THUNDER=y
>> CONFIG_PHYLIB=y
>> CONFIG_SWPHY=y
>> # CONFIG_LED_TRIGGER_PHY is not set
>>
>> #
>> # MII PHY device drivers
>> #
>> CONFIG_AMD_PHY=m
>> CONFIG_AQUANTIA_PHY=y
>> # CONFIG_ASIX_PHY is not set
>> # CONFIG_AT803X_PHY is not set
>> CONFIG_BCM7XXX_PHY=y
>> # CONFIG_BCM87XX_PHY is not set
>> CONFIG_BCM_NET_PHYLIB=y
>> CONFIG_BROADCOM_PHY=y
>> CONFIG_CICADA_PHY=m
>> CONFIG_CORTINA_PHY=m
>> CONFIG_DAVICOM_PHY=m
>> # CONFIG_DP83822_PHY is not set
>> CONFIG_DP83TC811_PHY=m
>> CONFIG_DP83848_PHY=y
>> # CONFIG_DP83867_PHY is not set
>> CONFIG_FIXED_PHY=y
>> CONFIG_ICPLUS_PHY=y
>> CONFIG_INTEL_XWAY_PHY=y
>> CONFIG_LSI_ET1011C_PHY=y
>> CONFIG_LXT_PHY=m
>> CONFIG_MARVELL_PHY=m
>> # CONFIG_MARVELL_10G_PHY is not set
>> CONFIG_MICREL_PHY=m
>> # CONFIG_MICROCHIP_PHY is not set
>> CONFIG_MICROCHIP_T1_PHY=y
>> CONFIG_MICROSEMI_PHY=y
>> # CONFIG_NATIONAL_PHY is not set
>> # CONFIG_QSEMI_PHY is not set
>> CONFIG_REALTEK_PHY=y
>> CONFIG_RENESAS_PHY=m
>> # CONFIG_ROCKCHIP_PHY is not set
>> CONFIG_SMSC_PHY=m
>> CONFIG_STE10XP=y
>> CONFIG_TERANETICS_PHY=m
>> # CONFIG_VITESSE_PHY is not set
>> CONFIG_XILINX_GMII2RGMII=y
>> CONFIG_PPP=y
>> CONFIG_PPP_BSDCOMP=m
>> CONFIG_PPP_DEFLATE=m
>> # CONFIG_PPP_FILTER is not set
>> CONFIG_PPP_MPPE=m
>> CONFIG_PPP_MULTILINK=y
>> CONFIG_PPPOATM=m
>> # CONFIG_PPPOE is not set
>> # CONFIG_PPP_ASYNC is not set
>> # CONFIG_PPP_SYNC_TTY is not set
>> CONFIG_SLIP=m
>> CONFIG_SLHC=y
>> # CONFIG_SLIP_COMPRESSED is not set
>> CONFIG_SLIP_SMART=y
>> # CONFIG_SLIP_MODE_SLIP6 is not set
>>
>> #
>> # Host-side USB support is needed for USB Network Adapter support
>> #
>> CONFIG_WLAN=y
>> CONFIG_WIRELESS_WDS=y
>> # CONFIG_WLAN_VENDOR_ADMTEK is not set
>> # CONFIG_WLAN_VENDOR_ATH is not set
>> # CONFIG_WLAN_VENDOR_ATMEL is not set
>> # CONFIG_WLAN_VENDOR_BROADCOM is not set
>> CONFIG_WLAN_VENDOR_CISCO=y
>> CONFIG_AIRO_CS=m
>> # CONFIG_WLAN_VENDOR_INTEL is not set
>> # CONFIG_WLAN_VENDOR_INTERSIL is not set
>> # CONFIG_WLAN_VENDOR_MARVELL is not set
>> # CONFIG_WLAN_VENDOR_MEDIATEK is not set
>> # CONFIG_WLAN_VENDOR_RALINK is not set
>> # CONFIG_WLAN_VENDOR_REALTEK is not set
>> # CONFIG_WLAN_VENDOR_RSI is not set
>> CONFIG_WLAN_VENDOR_ST=y
>> # CONFIG_CW1200 is not set
>> # CONFIG_WLAN_VENDOR_TI is not set
>> # CONFIG_WLAN_VENDOR_ZYDAS is not set
>> # CONFIG_WLAN_VENDOR_QUANTENNA is not set
>> CONFIG_PCMCIA_RAYCS=m
>> CONFIG_PCMCIA_WL3501=m
>> CONFIG_MAC80211_HWSIM=m
>> # CONFIG_VIRT_WIFI is not set
>>
>> #
>> # Enable WiMAX (Networking options) to see the WiMAX drivers
>> #
>> CONFIG_WAN=y
>> CONFIG_LANMEDIA=m
>> CONFIG_HDLC=m
>> # CONFIG_HDLC_RAW is not set
>> CONFIG_HDLC_RAW_ETH=m
>> CONFIG_HDLC_CISCO=m
>> # CONFIG_HDLC_FR is not set
>> CONFIG_HDLC_PPP=m
>>
>> #
>> # X.25/LAPB support is disabled
>> #
>> CONFIG_PCI200SYN=m
>> CONFIG_WANXL=m
>> CONFIG_PC300TOO=m
>> # CONFIG_FARSYNC is not set
>> # CONFIG_DSCC4 is not set
>> CONFIG_DLCI=m
>> CONFIG_DLCI_MAX=8
>> CONFIG_SBNI=m
>> CONFIG_SBNI_MULTILINE=y
>> # CONFIG_IEEE802154_DRIVERS is not set
>> # CONFIG_VMXNET3 is not set
>> # CONFIG_FUJITSU_ES is not set
>> # CONFIG_THUNDERBOLT_NET is not set
>> CONFIG_NETDEVSIM=m
>> # CONFIG_NET_FAILOVER is not set
>> # CONFIG_ISDN is not set
>>
>> #
>> # Input device support
>> #
>> CONFIG_INPUT=y
>> # CONFIG_INPUT_LEDS is not set
>> CONFIG_INPUT_FF_MEMLESS=m
>> CONFIG_INPUT_POLLDEV=m
>> CONFIG_INPUT_SPARSEKMAP=m
>> CONFIG_INPUT_MATRIXKMAP=m
>>
>> #
>> # Userland interfaces
>> #
>> # CONFIG_INPUT_MOUSEDEV is not set
>> CONFIG_INPUT_JOYDEV=m
>> CONFIG_INPUT_EVDEV=m
>> CONFIG_INPUT_EVBUG=m
>>
>> #
>> # Input Device Drivers
>> #
>> CONFIG_INPUT_KEYBOARD=y
>> # CONFIG_KEYBOARD_ADC is not set
>> # CONFIG_KEYBOARD_ADP5588 is not set
>> # CONFIG_KEYBOARD_ADP5589 is not set
>> CONFIG_KEYBOARD_ATKBD=y
>> # CONFIG_KEYBOARD_QT1070 is not set
>> # CONFIG_KEYBOARD_QT2160 is not set
>> # CONFIG_KEYBOARD_DLINK_DIR685 is not set
>> # CONFIG_KEYBOARD_LKKBD is not set
>> # CONFIG_KEYBOARD_GPIO is not set
>> # CONFIG_KEYBOARD_GPIO_POLLED is not set
>> # CONFIG_KEYBOARD_TCA6416 is not set
>> # CONFIG_KEYBOARD_TCA8418 is not set
>> # CONFIG_KEYBOARD_MATRIX is not set
>> # CONFIG_KEYBOARD_LM8323 is not set
>> # CONFIG_KEYBOARD_LM8333 is not set
>> # CONFIG_KEYBOARD_MAX7359 is not set
>> # CONFIG_KEYBOARD_MCS is not set
>> # CONFIG_KEYBOARD_MPR121 is not set
>> # CONFIG_KEYBOARD_NEWTON is not set
>> # CONFIG_KEYBOARD_OPENCORES is not set
>> # CONFIG_KEYBOARD_SAMSUNG is not set
>> # CONFIG_KEYBOARD_STOWAWAY is not set
>> # CONFIG_KEYBOARD_SUNKBD is not set
>> # CONFIG_KEYBOARD_OMAP4 is not set
>> # CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
>> # CONFIG_KEYBOARD_XTKBD is not set
>> # CONFIG_KEYBOARD_CROS_EC is not set
>> # CONFIG_KEYBOARD_CAP11XX is not set
>> # CONFIG_KEYBOARD_BCM is not set
>> # CONFIG_KEYBOARD_MTK_PMIC is not set
>> # CONFIG_INPUT_MOUSE is not set
>> # CONFIG_INPUT_JOYSTICK is not set
>> CONFIG_INPUT_TABLET=y
>> # CONFIG_TABLET_USB_ACECAD is not set
>> # CONFIG_TABLET_USB_AIPTEK is not set
>> # CONFIG_TABLET_USB_HANWANG is not set
>> # CONFIG_TABLET_USB_KBTAB is not set
>> # CONFIG_TABLET_USB_PEGASUS is not set
>> # CONFIG_TABLET_SERIAL_WACOM4 is not set
>> CONFIG_INPUT_TOUCHSCREEN=y
>> CONFIG_TOUCHSCREEN_PROPERTIES=y
>> CONFIG_TOUCHSCREEN_AD7879=m
>> CONFIG_TOUCHSCREEN_AD7879_I2C=m
>> CONFIG_TOUCHSCREEN_ADC=m
>> # CONFIG_TOUCHSCREEN_AR1021_I2C is not set
>> CONFIG_TOUCHSCREEN_ATMEL_MXT=m
>> # CONFIG_TOUCHSCREEN_ATMEL_MXT_T37 is not set
>> CONFIG_TOUCHSCREEN_AUO_PIXCIR=m
>> CONFIG_TOUCHSCREEN_BU21013=m
>> CONFIG_TOUCHSCREEN_BU21029=m
>> CONFIG_TOUCHSCREEN_CHIPONE_ICN8318=m
>> # CONFIG_TOUCHSCREEN_CHIPONE_ICN8505 is not set
>> CONFIG_TOUCHSCREEN_CY8CTMG110=m
>> CONFIG_TOUCHSCREEN_CYTTSP_CORE=m
>> CONFIG_TOUCHSCREEN_CYTTSP_I2C=m
>> CONFIG_TOUCHSCREEN_CYTTSP4_CORE=m
>> CONFIG_TOUCHSCREEN_CYTTSP4_I2C=m
>> CONFIG_TOUCHSCREEN_DYNAPRO=m
>> # CONFIG_TOUCHSCREEN_HAMPSHIRE is not set
>> CONFIG_TOUCHSCREEN_EETI=m
>> CONFIG_TOUCHSCREEN_EGALAX=m
>> CONFIG_TOUCHSCREEN_EGALAX_SERIAL=m
>> CONFIG_TOUCHSCREEN_EXC3000=m
>> CONFIG_TOUCHSCREEN_FUJITSU=m
>> # CONFIG_TOUCHSCREEN_GOODIX is not set
>> CONFIG_TOUCHSCREEN_HIDEEP=m
>> CONFIG_TOUCHSCREEN_ILI210X=m
>> # CONFIG_TOUCHSCREEN_S6SY761 is not set
>> CONFIG_TOUCHSCREEN_GUNZE=m
>> CONFIG_TOUCHSCREEN_EKTF2127=m
>> CONFIG_TOUCHSCREEN_ELAN=m
>> # CONFIG_TOUCHSCREEN_ELO is not set
>> # CONFIG_TOUCHSCREEN_WACOM_W8001 is not set
>> # CONFIG_TOUCHSCREEN_WACOM_I2C is not set
>> CONFIG_TOUCHSCREEN_MAX11801=m
>> # CONFIG_TOUCHSCREEN_MCS5000 is not set
>> # CONFIG_TOUCHSCREEN_MMS114 is not set
>> CONFIG_TOUCHSCREEN_MELFAS_MIP4=m
>> CONFIG_TOUCHSCREEN_MTOUCH=m
>> # CONFIG_TOUCHSCREEN_IMX6UL_TSC is not set
>> CONFIG_TOUCHSCREEN_INEXIO=m
>> # CONFIG_TOUCHSCREEN_MK712 is not set
>> CONFIG_TOUCHSCREEN_PENMOUNT=m
>> # CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
>> # CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
>> CONFIG_TOUCHSCREEN_TOUCHWIN=m
>> CONFIG_TOUCHSCREEN_PIXCIR=m
>> # CONFIG_TOUCHSCREEN_WDT87XX_I2C is not set
>> CONFIG_TOUCHSCREEN_WM831X=m
>> # CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
>> CONFIG_TOUCHSCREEN_MC13783=m
>> CONFIG_TOUCHSCREEN_TOUCHIT213=m
>> CONFIG_TOUCHSCREEN_TSC_SERIO=m
>> CONFIG_TOUCHSCREEN_TSC200X_CORE=m
>> CONFIG_TOUCHSCREEN_TSC2004=m
>> CONFIG_TOUCHSCREEN_TSC2007=m
>> # CONFIG_TOUCHSCREEN_TSC2007_IIO is not set
>> # CONFIG_TOUCHSCREEN_RM_TS is not set
>> # CONFIG_TOUCHSCREEN_SILEAD is not set
>> CONFIG_TOUCHSCREEN_SIS_I2C=m
>> # CONFIG_TOUCHSCREEN_ST1232 is not set
>> CONFIG_TOUCHSCREEN_STMFTS=m
>> CONFIG_TOUCHSCREEN_SX8654=m
>> CONFIG_TOUCHSCREEN_TPS6507X=m
>> CONFIG_TOUCHSCREEN_ZET6223=m
>> # CONFIG_TOUCHSCREEN_ZFORCE is not set
>> CONFIG_TOUCHSCREEN_ROHM_BU21023=m
>> # CONFIG_INPUT_MISC is not set
>> CONFIG_RMI4_CORE=m
>> CONFIG_RMI4_I2C=m
>> # CONFIG_RMI4_SMB is not set
>> CONFIG_RMI4_F03=y
>> CONFIG_RMI4_F03_SERIO=m
>> CONFIG_RMI4_2D_SENSOR=y
>> CONFIG_RMI4_F11=y
>> CONFIG_RMI4_F12=y
>> CONFIG_RMI4_F30=y
>> # CONFIG_RMI4_F34 is not set
>> # CONFIG_RMI4_F54 is not set
>> CONFIG_RMI4_F55=y
>>
>> #
>> # Hardware I/O ports
>> #
>> CONFIG_SERIO=y
>> CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
>> CONFIG_SERIO_I8042=y
>> CONFIG_SERIO_SERPORT=m
>> CONFIG_SERIO_CT82C710=m
>> CONFIG_SERIO_PCIPS2=m
>> CONFIG_SERIO_LIBPS2=y
>> CONFIG_SERIO_RAW=m
>> # CONFIG_SERIO_ALTERA_PS2 is not set
>> # CONFIG_SERIO_PS2MULT is not set
>> CONFIG_SERIO_ARC_PS2=m
>> # CONFIG_SERIO_APBPS2 is not set
>> # CONFIG_SERIO_OLPC_APSP is not set
>> CONFIG_SERIO_GPIO_PS2=m
>> CONFIG_USERIO=m
>> # CONFIG_GAMEPORT is not set
>>
>> #
>> # Character devices
>> #
>> CONFIG_TTY=y
>> # CONFIG_VT is not set
>> CONFIG_UNIX98_PTYS=y
>> # CONFIG_LEGACY_PTYS is not set
>> # CONFIG_SERIAL_NONSTANDARD is not set
>> CONFIG_NOZOMI=y
>> CONFIG_N_GSM=m
>> CONFIG_TRACE_ROUTER=m
>> CONFIG_TRACE_SINK=m
>> CONFIG_DEVMEM=y
>> # CONFIG_DEVKMEM is not set
>>
>> #
>> # Serial drivers
>> #
>> CONFIG_SERIAL_EARLYCON=y
>> CONFIG_SERIAL_8250=y
>> CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
>> CONFIG_SERIAL_8250_PNP=y
>> CONFIG_SERIAL_8250_FINTEK=y
>> CONFIG_SERIAL_8250_CONSOLE=y
>> CONFIG_SERIAL_8250_DMA=y
>> CONFIG_SERIAL_8250_PCI=m
>> CONFIG_SERIAL_8250_EXAR=m
>> CONFIG_SERIAL_8250_CS=m
>> # CONFIG_SERIAL_8250_MEN_MCB is not set
>> CONFIG_SERIAL_8250_NR_UARTS=4
>> CONFIG_SERIAL_8250_RUNTIME_UARTS=4
>> CONFIG_SERIAL_8250_EXTENDED=y
>> # CONFIG_SERIAL_8250_MANY_PORTS is not set
>> CONFIG_SERIAL_8250_ASPEED_VUART=m
>> # CONFIG_SERIAL_8250_SHARE_IRQ is not set
>> CONFIG_SERIAL_8250_DETECT_IRQ=y
>> CONFIG_SERIAL_8250_RSA=y
>> CONFIG_SERIAL_8250_DW=m
>> CONFIG_SERIAL_8250_RT288X=y
>> CONFIG_SERIAL_8250_LPSS=m
>> CONFIG_SERIAL_8250_MID=y
>> CONFIG_SERIAL_8250_MOXA=y
>> CONFIG_SERIAL_OF_PLATFORM=m
>>
>> #
>> # Non-8250 serial port support
>> #
>> CONFIG_SERIAL_UARTLITE=m
>> CONFIG_SERIAL_UARTLITE_NR_UARTS=1
>> CONFIG_SERIAL_CORE=y
>> CONFIG_SERIAL_CORE_CONSOLE=y
>> CONFIG_SERIAL_JSM=m
>> CONFIG_SERIAL_SCCNXP=m
>> CONFIG_SERIAL_SC16IS7XX=m
>> # CONFIG_SERIAL_SC16IS7XX_I2C is not set
>> CONFIG_SERIAL_ALTERA_JTAGUART=y
>> # CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE is not set
>> CONFIG_SERIAL_ALTERA_UART=m
>> CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
>> CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
>> # CONFIG_SERIAL_XILINX_PS_UART is not set
>> # CONFIG_SERIAL_ARC is not set
>> CONFIG_SERIAL_RP2=y
>> CONFIG_SERIAL_RP2_NR_UARTS=32
>> # CONFIG_SERIAL_FSL_LPUART is not set
>> CONFIG_SERIAL_CONEXANT_DIGICOLOR=y
>> CONFIG_SERIAL_CONEXANT_DIGICOLOR_CONSOLE=y
>> CONFIG_SERIAL_MEN_Z135=m
>> # CONFIG_SERIAL_DEV_BUS is not set
>> CONFIG_TTY_PRINTK=y
>> CONFIG_TTY_PRINTK_LEVEL=6
>> CONFIG_HVC_DRIVER=y
>> CONFIG_VIRTIO_CONSOLE=m
>> CONFIG_IPMI_HANDLER=m
>> CONFIG_IPMI_DMI_DECODE=y
>> CONFIG_IPMI_PANIC_EVENT=y
>> CONFIG_IPMI_PANIC_STRING=y
>> CONFIG_IPMI_DEVICE_INTERFACE=m
>> CONFIG_IPMI_SI=m
>> # CONFIG_IPMI_SSIF is not set
>> # CONFIG_IPMI_WATCHDOG is not set
>> # CONFIG_IPMI_POWEROFF is not set
>> # CONFIG_HW_RANDOM is not set
>> # CONFIG_NVRAM is not set
>> # CONFIG_R3964 is not set
>> # CONFIG_APPLICOM is not set
>>
>> #
>> # PCMCIA character devices
>> #
>> CONFIG_SYNCLINK_CS=m
>> # CONFIG_CARDMAN_4000 is not set
>> CONFIG_CARDMAN_4040=m
>> CONFIG_SCR24X=y
>> CONFIG_IPWIRELESS=y
>> CONFIG_MWAVE=m
>> # CONFIG_HPET is not set
>> # CONFIG_HANGCHECK_TIMER is not set
>> CONFIG_TCG_TPM=y
>> CONFIG_TCG_TIS_CORE=m
>> CONFIG_TCG_TIS=m
>> CONFIG_TCG_TIS_I2C_ATMEL=y
>> # CONFIG_TCG_TIS_I2C_INFINEON is not set
>> # CONFIG_TCG_TIS_I2C_NUVOTON is not set
>> CONFIG_TCG_NSC=y
>> # CONFIG_TCG_ATMEL is not set
>> # CONFIG_TCG_INFINEON is not set
>> # CONFIG_TCG_CRB is not set
>> CONFIG_TCG_VTPM_PROXY=m
>> CONFIG_TCG_TIS_ST33ZP24=y
>> CONFIG_TCG_TIS_ST33ZP24_I2C=y
>> # CONFIG_TELCLOCK is not set
>> CONFIG_DEVPORT=y
>> CONFIG_XILLYBUS=m
>> CONFIG_XILLYBUS_PCIE=m
>> # CONFIG_XILLYBUS_OF is not set
>> CONFIG_RANDOM_TRUST_CPU=y
>>
>> #
>> # I2C support
>> #
>> CONFIG_I2C=y
>> CONFIG_ACPI_I2C_OPREGION=y
>> CONFIG_I2C_BOARDINFO=y
>> CONFIG_I2C_COMPAT=y
>> CONFIG_I2C_CHARDEV=m
>> CONFIG_I2C_MUX=y
>>
>> #
>> # Multiplexer I2C Chip support
>> #
>> CONFIG_I2C_ARB_GPIO_CHALLENGE=m
>> CONFIG_I2C_MUX_GPIO=m
>> CONFIG_I2C_MUX_GPMUX=m
>> CONFIG_I2C_MUX_LTC4306=m
>> CONFIG_I2C_MUX_PCA9541=y
>> CONFIG_I2C_MUX_PCA954x=y
>> CONFIG_I2C_MUX_PINCTRL=y
>> CONFIG_I2C_MUX_REG=y
>> # CONFIG_I2C_DEMUX_PINCTRL is not set
>> CONFIG_I2C_MUX_MLXCPLD=m
>> # CONFIG_I2C_HELPER_AUTO is not set
>> CONFIG_I2C_SMBUS=y
>>
>> #
>> # I2C Algorithms
>> #
>> CONFIG_I2C_ALGOBIT=y
>> CONFIG_I2C_ALGOPCF=y
>> CONFIG_I2C_ALGOPCA=y
>>
>> #
>> # I2C Hardware Bus support
>> #
>>
>> #
>> # PC SMBus host controller drivers
>> #
>> CONFIG_I2C_ALI1535=m
>> CONFIG_I2C_ALI1563=y
>> CONFIG_I2C_ALI15X3=m
>> CONFIG_I2C_AMD756=m
>> CONFIG_I2C_AMD756_S4882=m
>> # CONFIG_I2C_AMD8111 is not set
>> # CONFIG_I2C_I801 is not set
>> CONFIG_I2C_ISCH=m
>> # CONFIG_I2C_ISMT is not set
>> CONFIG_I2C_PIIX4=y
>> CONFIG_I2C_NFORCE2=m
>> # CONFIG_I2C_NFORCE2_S4985 is not set
>> CONFIG_I2C_NVIDIA_GPU=m
>> CONFIG_I2C_SIS5595=y
>> CONFIG_I2C_SIS630=m
>> CONFIG_I2C_SIS96X=y
>> CONFIG_I2C_VIA=y
>> CONFIG_I2C_VIAPRO=m
>>
>> #
>> # ACPI drivers
>> #
>> # CONFIG_I2C_SCMI is not set
>>
>> #
>> # I2C system bus drivers (mostly embedded / system-on-chip)
>> #
>> CONFIG_I2C_CBUS_GPIO=y
>> CONFIG_I2C_DESIGNWARE_CORE=m
>> # CONFIG_I2C_DESIGNWARE_PLATFORM is not set
>> CONFIG_I2C_DESIGNWARE_PCI=m
>> # CONFIG_I2C_EMEV2 is not set
>> CONFIG_I2C_GPIO=y
>> CONFIG_I2C_GPIO_FAULT_INJECTOR=y
>> CONFIG_I2C_KEMPLD=m
>> CONFIG_I2C_OCORES=m
>> CONFIG_I2C_PCA_PLATFORM=y
>> # CONFIG_I2C_RK3X is not set
>> # CONFIG_I2C_SIMTEC is not set
>> CONFIG_I2C_XILINX=m
>>
>> #
>> # External I2C/SMBus adapter drivers
>> #
>> CONFIG_I2C_PARPORT_LIGHT=m
>> CONFIG_I2C_TAOS_EVM=m
>>
>> #
>> # Other I2C/SMBus bus drivers
>> #
>> CONFIG_I2C_MLXCPLD=m
>> CONFIG_I2C_CROS_EC_TUNNEL=m
>> # CONFIG_I2C_FSI is not set
>> # CONFIG_I2C_STUB is not set
>> CONFIG_I2C_SLAVE=y
>> CONFIG_I2C_SLAVE_EEPROM=m
>> # CONFIG_I2C_DEBUG_CORE is not set
>> # CONFIG_I2C_DEBUG_ALGO is not set
>> # CONFIG_I2C_DEBUG_BUS is not set
>> # CONFIG_I3C is not set
>> # CONFIG_SPI is not set
>> # CONFIG_SPMI is not set
>> CONFIG_HSI=y
>> CONFIG_HSI_BOARDINFO=y
>>
>> #
>> # HSI controllers
>> #
>>
>> #
>> # HSI clients
>> #
>> CONFIG_HSI_CHAR=m
>> CONFIG_PPS=y
>> # CONFIG_PPS_DEBUG is not set
>>
>> #
>> # PPS clients support
>> #
>> CONFIG_PPS_CLIENT_KTIMER=y
>> CONFIG_PPS_CLIENT_LDISC=m
>> # CONFIG_PPS_CLIENT_GPIO is not set
>>
>> #
>> # PPS generators support
>> #
>>
>> #
>> # PTP clock support
>> #
>> CONFIG_PTP_1588_CLOCK=y
>>
>> #
>> # Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
>> #
>> CONFIG_PTP_1588_CLOCK_KVM=y
>> CONFIG_PINCTRL=y
>> CONFIG_GENERIC_PINCTRL_GROUPS=y
>> CONFIG_PINMUX=y
>> CONFIG_GENERIC_PINMUX_FUNCTIONS=y
>> CONFIG_PINCONF=y
>> CONFIG_GENERIC_PINCONF=y
>> # CONFIG_DEBUG_PINCTRL is not set
>> # CONFIG_PINCTRL_AS3722 is not set
>> CONFIG_PINCTRL_AXP209=m
>> CONFIG_PINCTRL_AMD=m
>> CONFIG_PINCTRL_MCP23S08=y
>> CONFIG_PINCTRL_SINGLE=y
>> # CONFIG_PINCTRL_SX150X is not set
>> CONFIG_PINCTRL_RK805=m
>> # CONFIG_PINCTRL_OCELOT is not set
>> # CONFIG_PINCTRL_BAYTRAIL is not set
>> # CONFIG_PINCTRL_CHERRYVIEW is not set
>> # CONFIG_PINCTRL_BROXTON is not set
>> # CONFIG_PINCTRL_CANNONLAKE is not set
>> # CONFIG_PINCTRL_CEDARFORK is not set
>> # CONFIG_PINCTRL_DENVERTON is not set
>> # CONFIG_PINCTRL_GEMINILAKE is not set
>> # CONFIG_PINCTRL_ICELAKE is not set
>> # CONFIG_PINCTRL_LEWISBURG is not set
>> # CONFIG_PINCTRL_SUNRISEPOINT is not set
>> CONFIG_PINCTRL_MADERA=y
>> CONFIG_PINCTRL_CS47L85=y
>> CONFIG_PINCTRL_CS47L90=y
>> CONFIG_GPIOLIB=y
>> CONFIG_GPIOLIB_FASTPATH_LIMIT=512
>> CONFIG_OF_GPIO=y
>> CONFIG_GPIO_ACPI=y
>> CONFIG_GPIOLIB_IRQCHIP=y
>> # CONFIG_DEBUG_GPIO is not set
>> CONFIG_GPIO_SYSFS=y
>> CONFIG_GPIO_GENERIC=y
>> CONFIG_GPIO_MAX730X=m
>>
>> #
>> # Memory mapped GPIO drivers
>> #
>> # CONFIG_GPIO_74XX_MMIO is not set
>> CONFIG_GPIO_ALTERA=m
>> # CONFIG_GPIO_AMDPT is not set
>> # CONFIG_GPIO_CADENCE is not set
>> # CONFIG_GPIO_DWAPB is not set
>> CONFIG_GPIO_EXAR=m
>> CONFIG_GPIO_FTGPIO010=y
>> CONFIG_GPIO_GENERIC_PLATFORM=m
>> CONFIG_GPIO_GRGPIO=m
>> CONFIG_GPIO_HLWD=y
>> CONFIG_GPIO_ICH=m
>> # CONFIG_GPIO_LYNXPOINT is not set
>> CONFIG_GPIO_MB86S7X=y
>> CONFIG_GPIO_MENZ127=m
>> CONFIG_GPIO_MOCKUP=m
>> # CONFIG_GPIO_SAMA5D2_PIOBU is not set
>> CONFIG_GPIO_SIOX=m
>> CONFIG_GPIO_SYSCON=y
>> CONFIG_GPIO_VX855=y
>> CONFIG_GPIO_XILINX=y
>>
>> #
>> # Port-mapped I/O GPIO drivers
>> #
>> # CONFIG_GPIO_F7188X is not set
>> CONFIG_GPIO_IT87=y
>> # CONFIG_GPIO_SCH is not set
>> CONFIG_GPIO_SCH311X=m
>> CONFIG_GPIO_WINBOND=y
>> # CONFIG_GPIO_WS16C48 is not set
>>
>> #
>> # I2C GPIO expanders
>> #
>> # CONFIG_GPIO_ADP5588 is not set
>> CONFIG_GPIO_ADNP=y
>> CONFIG_GPIO_MAX7300=m
>> CONFIG_GPIO_MAX732X=y
>> CONFIG_GPIO_MAX732X_IRQ=y
>> # CONFIG_GPIO_PCA953X is not set
>> CONFIG_GPIO_PCF857X=y
>> # CONFIG_GPIO_TPIC2810 is not set
>>
>> #
>> # MFD GPIO expanders
>> #
>> CONFIG_GPIO_ARIZONA=y
>> CONFIG_GPIO_BD9571MWV=y
>> CONFIG_GPIO_JANZ_TTL=m
>> CONFIG_GPIO_KEMPLD=y
>> # CONFIG_GPIO_LP3943 is not set
>> CONFIG_GPIO_MADERA=y
>> # CONFIG_GPIO_RC5T583 is not set
>> CONFIG_GPIO_TPS65086=m
>> CONFIG_GPIO_TPS65218=m
>> CONFIG_GPIO_TPS6586X=y
>> # CONFIG_GPIO_TPS65912 is not set
>> CONFIG_GPIO_TWL6040=m
>> CONFIG_GPIO_WM831X=y
>> CONFIG_GPIO_WM8994=m
>>
>> #
>> # PCI GPIO expanders
>> #
>> CONFIG_GPIO_AMD8111=m
>> CONFIG_GPIO_BT8XX=y
>> CONFIG_GPIO_ML_IOH=m
>> # CONFIG_GPIO_PCI_IDIO_16 is not set
>> CONFIG_GPIO_PCIE_IDIO_24=y
>> CONFIG_GPIO_RDC321X=m
>> # CONFIG_GPIO_SODAVILLE is not set
>> CONFIG_W1=y
>>
>> #
>> # 1-wire Bus Masters
>> #
>> CONFIG_W1_MASTER_MATROX=y
>> # CONFIG_W1_MASTER_DS2482 is not set
>> CONFIG_W1_MASTER_DS1WM=m
>> CONFIG_W1_MASTER_GPIO=y
>>
>> #
>> # 1-wire Slaves
>> #
>> # CONFIG_W1_SLAVE_THERM is not set
>> CONFIG_W1_SLAVE_SMEM=m
>> CONFIG_W1_SLAVE_DS2405=y
>> CONFIG_W1_SLAVE_DS2408=y
>> # CONFIG_W1_SLAVE_DS2408_READBACK is not set
>> CONFIG_W1_SLAVE_DS2413=y
>> # CONFIG_W1_SLAVE_DS2406 is not set
>> CONFIG_W1_SLAVE_DS2423=y
>> CONFIG_W1_SLAVE_DS2805=y
>> CONFIG_W1_SLAVE_DS2431=y
>> CONFIG_W1_SLAVE_DS2433=y
>> # CONFIG_W1_SLAVE_DS2433_CRC is not set
>> # CONFIG_W1_SLAVE_DS2438 is not set
>> CONFIG_W1_SLAVE_DS2780=y
>> CONFIG_W1_SLAVE_DS2781=m
>> # CONFIG_W1_SLAVE_DS28E04 is not set
>> CONFIG_W1_SLAVE_DS28E17=m
>> CONFIG_POWER_AVS=y
>> CONFIG_POWER_RESET=y
>> CONFIG_POWER_RESET_AS3722=y
>> CONFIG_POWER_RESET_GPIO=y
>> # CONFIG_POWER_RESET_GPIO_RESTART is not set
>> # CONFIG_POWER_RESET_LTC2952 is not set
>> CONFIG_POWER_RESET_RESTART=y
>> # CONFIG_POWER_RESET_SYSCON is not set
>> CONFIG_POWER_RESET_SYSCON_POWEROFF=y
>> # CONFIG_SYSCON_REBOOT_MODE is not set
>> CONFIG_POWER_SUPPLY=y
>> # CONFIG_POWER_SUPPLY_DEBUG is not set
>> CONFIG_PDA_POWER=y
>> # CONFIG_GENERIC_ADC_BATTERY is not set
>> # CONFIG_MAX8925_POWER is not set
>> CONFIG_WM831X_BACKUP=y
>> CONFIG_WM831X_POWER=m
>> # CONFIG_TEST_POWER is not set
>> CONFIG_CHARGER_ADP5061=y
>> CONFIG_BATTERY_ACT8945A=m
>> CONFIG_BATTERY_DS2760=y
>> CONFIG_BATTERY_DS2780=y
>> CONFIG_BATTERY_DS2781=m
>> CONFIG_BATTERY_DS2782=m
>> # CONFIG_BATTERY_LEGO_EV3 is not set
>> # CONFIG_BATTERY_SBS is not set
>> # CONFIG_CHARGER_SBS is not set
>> CONFIG_MANAGER_SBS=y
>> CONFIG_BATTERY_BQ27XXX=m
>> CONFIG_BATTERY_BQ27XXX_I2C=m
>> CONFIG_BATTERY_BQ27XXX_HDQ=m
>> CONFIG_BATTERY_BQ27XXX_DT_UPDATES_NVM=y
>> CONFIG_BATTERY_DA9150=m
>> # CONFIG_CHARGER_AXP20X is not set
>> CONFIG_BATTERY_AXP20X=y
>> CONFIG_AXP20X_POWER=m
>> CONFIG_AXP288_FUEL_GAUGE=m
>> CONFIG_BATTERY_MAX17040=y
>> CONFIG_BATTERY_MAX17042=y
>> CONFIG_BATTERY_MAX1721X=m
>> CONFIG_CHARGER_PCF50633=m
>> # CONFIG_CHARGER_MAX8903 is not set
>> CONFIG_CHARGER_LP8727=m
>> CONFIG_CHARGER_LP8788=m
>> CONFIG_CHARGER_GPIO=m
>> # CONFIG_CHARGER_MANAGER is not set
>> CONFIG_CHARGER_LTC3651=y
>> CONFIG_CHARGER_DETECTOR_MAX14656=m
>> CONFIG_CHARGER_MAX8997=m
>> # CONFIG_CHARGER_BQ2415X is not set
>> CONFIG_CHARGER_BQ24190=m
>> # CONFIG_CHARGER_BQ24257 is not set
>> CONFIG_CHARGER_BQ24735=m
>> CONFIG_CHARGER_BQ25890=m
>> CONFIG_CHARGER_SMB347=m
>> CONFIG_BATTERY_GAUGE_LTC2941=y
>> # CONFIG_BATTERY_RT5033 is not set
>> CONFIG_CHARGER_RT9455=y
>> CONFIG_CHARGER_CROS_USBPD=m
>> CONFIG_HWMON=y
>> CONFIG_HWMON_VID=y
>> CONFIG_HWMON_DEBUG_CHIP=y
>>
>> #
>> # Native drivers
>> #
>> CONFIG_SENSORS_ABITUGURU=y
>> CONFIG_SENSORS_ABITUGURU3=m
>> CONFIG_SENSORS_AD7414=m
>> CONFIG_SENSORS_AD7418=m
>> # CONFIG_SENSORS_ADM1021 is not set
>> CONFIG_SENSORS_ADM1025=m
>> CONFIG_SENSORS_ADM1026=m
>> CONFIG_SENSORS_ADM1029=m
>> CONFIG_SENSORS_ADM1031=y
>> CONFIG_SENSORS_ADM9240=m
>> CONFIG_SENSORS_ADT7X10=m
>> CONFIG_SENSORS_ADT7410=m
>> CONFIG_SENSORS_ADT7411=m
>> # CONFIG_SENSORS_ADT7462 is not set
>> CONFIG_SENSORS_ADT7470=m
>> CONFIG_SENSORS_ADT7475=m
>> CONFIG_SENSORS_ASC7621=m
>> # CONFIG_SENSORS_K8TEMP is not set
>> CONFIG_SENSORS_APPLESMC=m
>> CONFIG_SENSORS_ASB100=y
>> CONFIG_SENSORS_ASPEED=m
>> # CONFIG_SENSORS_ATXP1 is not set
>> CONFIG_SENSORS_DS620=y
>> # CONFIG_SENSORS_DS1621 is not set
>> CONFIG_SENSORS_DELL_SMM=m
>> CONFIG_SENSORS_I5K_AMB=y
>> # CONFIG_SENSORS_F71805F is not set
>> CONFIG_SENSORS_F71882FG=y
>> CONFIG_SENSORS_F75375S=m
>> CONFIG_SENSORS_MC13783_ADC=m
>> # CONFIG_SENSORS_FSCHMD is not set
>> CONFIG_SENSORS_FTSTEUTATES=m
>> # CONFIG_SENSORS_GL518SM is not set
>> # CONFIG_SENSORS_GL520SM is not set
>> CONFIG_SENSORS_G760A=m
>> CONFIG_SENSORS_G762=y
>> CONFIG_SENSORS_GPIO_FAN=m
>> CONFIG_SENSORS_HIH6130=y
>> CONFIG_SENSORS_IBMAEM=m
>> CONFIG_SENSORS_IBMPEX=m
>> # CONFIG_SENSORS_IIO_HWMON is not set
>> # CONFIG_SENSORS_I5500 is not set
>> CONFIG_SENSORS_CORETEMP=m
>> # CONFIG_SENSORS_IT87 is not set
>> CONFIG_SENSORS_JC42=m
>> # CONFIG_SENSORS_POWR1220 is not set
>> CONFIG_SENSORS_LINEAGE=m
>> CONFIG_SENSORS_LTC2945=y
>> CONFIG_SENSORS_LTC2990=m
>> # CONFIG_SENSORS_LTC4151 is not set
>> # CONFIG_SENSORS_LTC4215 is not set
>> CONFIG_SENSORS_LTC4222=y
>> CONFIG_SENSORS_LTC4245=y
>> CONFIG_SENSORS_LTC4260=m
>> CONFIG_SENSORS_LTC4261=m
>> CONFIG_SENSORS_MAX16065=m
>> # CONFIG_SENSORS_MAX1619 is not set
>> # CONFIG_SENSORS_MAX1668 is not set
>> CONFIG_SENSORS_MAX197=m
>> # CONFIG_SENSORS_MAX6621 is not set
>> CONFIG_SENSORS_MAX6639=m
>> CONFIG_SENSORS_MAX6642=m
>> CONFIG_SENSORS_MAX6650=m
>> CONFIG_SENSORS_MAX6697=m
>> CONFIG_SENSORS_MAX31790=y
>> # CONFIG_SENSORS_MCP3021 is not set
>> CONFIG_SENSORS_TC654=y
>> # CONFIG_SENSORS_MENF21BMC_HWMON is not set
>> CONFIG_SENSORS_LM63=y
>> CONFIG_SENSORS_LM73=m
>> CONFIG_SENSORS_LM75=m
>> CONFIG_SENSORS_LM77=m
>> CONFIG_SENSORS_LM78=y
>> # CONFIG_SENSORS_LM80 is not set
>> CONFIG_SENSORS_LM83=y
>> CONFIG_SENSORS_LM85=y
>> # CONFIG_SENSORS_LM87 is not set
>> CONFIG_SENSORS_LM90=y
>> CONFIG_SENSORS_LM92=m
>> CONFIG_SENSORS_LM93=y
>> CONFIG_SENSORS_LM95234=m
>> # CONFIG_SENSORS_LM95241 is not set
>> # CONFIG_SENSORS_LM95245 is not set
>> CONFIG_SENSORS_PC87360=y
>> CONFIG_SENSORS_PC87427=y
>> CONFIG_SENSORS_NTC_THERMISTOR=y
>> # CONFIG_SENSORS_NCT6683 is not set
>> CONFIG_SENSORS_NCT6775=y
>> CONFIG_SENSORS_NCT7802=y
>> CONFIG_SENSORS_NCT7904=y
>> # CONFIG_SENSORS_NPCM7XX is not set
>> # CONFIG_SENSORS_OCC_P8_I2C is not set
>> CONFIG_SENSORS_OCC_P9_SBE=m
>> CONFIG_SENSORS_OCC=y
>> CONFIG_SENSORS_PCF8591=m
>> # CONFIG_PMBUS is not set
>> CONFIG_SENSORS_PWM_FAN=y
>> CONFIG_SENSORS_SHT15=m
>> CONFIG_SENSORS_SHT21=y
>> # CONFIG_SENSORS_SHT3x is not set
>> CONFIG_SENSORS_SHTC1=m
>> CONFIG_SENSORS_SIS5595=m
>> CONFIG_SENSORS_DME1737=y
>> # CONFIG_SENSORS_EMC1403 is not set
>> # CONFIG_SENSORS_EMC2103 is not set
>> CONFIG_SENSORS_EMC6W201=m
>> CONFIG_SENSORS_SMSC47M1=y
>> CONFIG_SENSORS_SMSC47M192=y
>> CONFIG_SENSORS_SMSC47B397=y
>> CONFIG_SENSORS_SCH56XX_COMMON=y
>> CONFIG_SENSORS_SCH5627=y
>> CONFIG_SENSORS_SCH5636=y
>> CONFIG_SENSORS_STTS751=m
>> CONFIG_SENSORS_SMM665=y
>> CONFIG_SENSORS_ADC128D818=m
>> # CONFIG_SENSORS_ADS1015 is not set
>> CONFIG_SENSORS_ADS7828=m
>> # CONFIG_SENSORS_AMC6821 is not set
>> CONFIG_SENSORS_INA209=y
>> # CONFIG_SENSORS_INA2XX is not set
>> # CONFIG_SENSORS_INA3221 is not set
>> CONFIG_SENSORS_TC74=m
>> CONFIG_SENSORS_THMC50=m
>> CONFIG_SENSORS_TMP102=y
>> # CONFIG_SENSORS_TMP103 is not set
>> CONFIG_SENSORS_TMP108=y
>> # CONFIG_SENSORS_TMP401 is not set
>> CONFIG_SENSORS_TMP421=m
>> CONFIG_SENSORS_VIA_CPUTEMP=y
>> # CONFIG_SENSORS_VIA686A is not set
>> # CONFIG_SENSORS_VT1211 is not set
>> # CONFIG_SENSORS_VT8231 is not set
>> CONFIG_SENSORS_W83773G=y
>> CONFIG_SENSORS_W83781D=m
>> CONFIG_SENSORS_W83791D=y
>> CONFIG_SENSORS_W83792D=m
>> CONFIG_SENSORS_W83793=m
>> CONFIG_SENSORS_W83795=y
>> # CONFIG_SENSORS_W83795_FANCTRL is not set
>> # CONFIG_SENSORS_W83L785TS is not set
>> CONFIG_SENSORS_W83L786NG=y
>> CONFIG_SENSORS_W83627HF=m
>> # CONFIG_SENSORS_W83627EHF is not set
>> # CONFIG_SENSORS_WM831X is not set
>>
>> #
>> # ACPI drivers
>> #
>> # CONFIG_SENSORS_ACPI_POWER is not set
>> # CONFIG_SENSORS_ATK0110 is not set
>> CONFIG_THERMAL=y
>> # CONFIG_THERMAL_STATISTICS is not set
>> CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
>> CONFIG_THERMAL_HWMON=y
>> CONFIG_THERMAL_OF=y
>> # CONFIG_THERMAL_WRITABLE_TRIPS is not set
>> CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
>> # CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
>> # CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
>> # CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
>> # CONFIG_THERMAL_GOV_FAIR_SHARE is not set
>> CONFIG_THERMAL_GOV_STEP_WISE=y
>> # CONFIG_THERMAL_GOV_BANG_BANG is not set
>> # CONFIG_THERMAL_GOV_USER_SPACE is not set
>> # CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
>> # CONFIG_THERMAL_EMULATION is not set
>> # CONFIG_QORIQ_THERMAL is not set
>> # CONFIG_DA9062_THERMAL is not set
>>
>> #
>> # Intel thermal drivers
>> #
>> # CONFIG_INTEL_POWERCLAMP is not set
>> # CONFIG_INTEL_SOC_DTS_THERMAL is not set
>>
>> #
>> # ACPI INT340X thermal drivers
>> #
>> # CONFIG_INT340X_THERMAL is not set
>> # CONFIG_INTEL_PCH_THERMAL is not set
>> # CONFIG_GENERIC_ADC_THERMAL is not set
>> CONFIG_WATCHDOG=y
>> CONFIG_WATCHDOG_CORE=y
>> # CONFIG_WATCHDOG_NOWAYOUT is not set
>> # CONFIG_WATCHDOG_HANDLE_BOOT_ENABLED is not set
>> CONFIG_WATCHDOG_SYSFS=y
>>
>> #
>> # Watchdog Device Drivers
>> #
>> CONFIG_SOFT_WATCHDOG=m
>> # CONFIG_SOFT_WATCHDOG_PRETIMEOUT is not set
>> # CONFIG_DA9063_WATCHDOG is not set
>> CONFIG_DA9062_WATCHDOG=m
>> CONFIG_GPIO_WATCHDOG=m
>> CONFIG_MENF21BMC_WATCHDOG=m
>> # CONFIG_MENZ069_WATCHDOG is not set
>> # CONFIG_WDAT_WDT is not set
>> CONFIG_WM831X_WATCHDOG=y
>> # CONFIG_XILINX_WATCHDOG is not set
>> CONFIG_ZIIRAVE_WATCHDOG=m
>> CONFIG_CADENCE_WATCHDOG=m
>> CONFIG_DW_WATCHDOG=m
>> # CONFIG_RN5T618_WATCHDOG is not set
>> CONFIG_MAX63XX_WATCHDOG=m
>> CONFIG_ACQUIRE_WDT=m
>> CONFIG_ADVANTECH_WDT=y
>> CONFIG_ALIM1535_WDT=y
>> CONFIG_ALIM7101_WDT=y
>> # CONFIG_EBC_C384_WDT is not set
>> CONFIG_F71808E_WDT=m
>> CONFIG_SP5100_TCO=y
>> CONFIG_SBC_FITPC2_WATCHDOG=y
>> # CONFIG_EUROTECH_WDT is not set
>> CONFIG_IB700_WDT=y
>> CONFIG_IBMASR=y
>> CONFIG_WAFER_WDT=y
>> CONFIG_I6300ESB_WDT=y
>> CONFIG_IE6XX_WDT=y
>> CONFIG_ITCO_WDT=y
>> # CONFIG_ITCO_VENDOR_SUPPORT is not set
>> CONFIG_IT8712F_WDT=y
>> CONFIG_IT87_WDT=m
>> CONFIG_HP_WATCHDOG=m
>> CONFIG_KEMPLD_WDT=m
>> # CONFIG_HPWDT_NMI_DECODING is not set
>> CONFIG_SC1200_WDT=m
>> # CONFIG_PC87413_WDT is not set
>> CONFIG_NV_TCO=m
>> CONFIG_60XX_WDT=m
>> # CONFIG_CPU5_WDT is not set
>> # CONFIG_SMSC_SCH311X_WDT is not set
>> CONFIG_SMSC37B787_WDT=m
>> CONFIG_TQMX86_WDT=y
>> CONFIG_VIA_WDT=y
>> CONFIG_W83627HF_WDT=m
>> CONFIG_W83877F_WDT=y
>> CONFIG_W83977F_WDT=y
>> CONFIG_MACHZ_WDT=m
>> # CONFIG_SBC_EPX_C3_WATCHDOG is not set
>> CONFIG_INTEL_MEI_WDT=y
>> # CONFIG_NI903X_WDT is not set
>> # CONFIG_NIC7018_WDT is not set
>> CONFIG_MEN_A21_WDT=m
>>
>> #
>> # PCI-based Watchdog Cards
>> #
>> CONFIG_PCIPCWATCHDOG=y
>> CONFIG_WDTPCI=y
>>
>> #
>> # Watchdog Pretimeout Governors
>> #
>> CONFIG_WATCHDOG_PRETIMEOUT_GOV=y
>> # CONFIG_WATCHDOG_PRETIMEOUT_DEFAULT_GOV_NOOP is not set
>> CONFIG_WATCHDOG_PRETIMEOUT_DEFAULT_GOV_PANIC=y
>> CONFIG_WATCHDOG_PRETIMEOUT_GOV_NOOP=m
>> CONFIG_WATCHDOG_PRETIMEOUT_GOV_PANIC=y
>> CONFIG_SSB_POSSIBLE=y
>> # CONFIG_SSB is not set
>> CONFIG_BCMA_POSSIBLE=y
>> CONFIG_BCMA=y
>> CONFIG_BCMA_HOST_PCI_POSSIBLE=y
>> CONFIG_BCMA_HOST_PCI=y
>> CONFIG_BCMA_HOST_SOC=y
>> CONFIG_BCMA_DRIVER_PCI=y
>> CONFIG_BCMA_SFLASH=y
>> CONFIG_BCMA_DRIVER_GMAC_CMN=y
>> CONFIG_BCMA_DRIVER_GPIO=y
>> # CONFIG_BCMA_DEBUG is not set
>>
>> #
>> # Multifunction device drivers
>> #
>> CONFIG_MFD_CORE=y
>> CONFIG_MFD_ACT8945A=y
>> CONFIG_MFD_AS3711=y
>> CONFIG_MFD_AS3722=m
>> # CONFIG_PMIC_ADP5520 is not set
>> CONFIG_MFD_AAT2870_CORE=y
>> CONFIG_MFD_ATMEL_FLEXCOM=m
>> # CONFIG_MFD_ATMEL_HLCDC is not set
>> # CONFIG_MFD_BCM590XX is not set
>> CONFIG_MFD_BD9571MWV=y
>> CONFIG_MFD_AXP20X=y
>> CONFIG_MFD_AXP20X_I2C=y
>> CONFIG_MFD_CROS_EC=m
>> CONFIG_MFD_CROS_EC_CHARDEV=m
>> CONFIG_MFD_MADERA=y
>> CONFIG_MFD_MADERA_I2C=y
>> # CONFIG_MFD_CS47L35 is not set
>> CONFIG_MFD_CS47L85=y
>> CONFIG_MFD_CS47L90=y
>> # CONFIG_PMIC_DA903X is not set
>> # CONFIG_MFD_DA9052_I2C is not set
>> # CONFIG_MFD_DA9055 is not set
>> CONFIG_MFD_DA9062=m
>> CONFIG_MFD_DA9063=m
>> CONFIG_MFD_DA9150=y
>> CONFIG_MFD_MC13XXX=m
>> CONFIG_MFD_MC13XXX_I2C=m
>> CONFIG_MFD_HI6421_PMIC=y
>> # CONFIG_HTC_PASIC3 is not set
>> # CONFIG_HTC_I2CPLD is not set
>> CONFIG_MFD_INTEL_QUARK_I2C_GPIO=m
>> CONFIG_LPC_ICH=y
>> CONFIG_LPC_SCH=y
>> # CONFIG_INTEL_SOC_PMIC is not set
>> # CONFIG_INTEL_SOC_PMIC_CHTWC is not set
>> # CONFIG_INTEL_SOC_PMIC_CHTDC_TI is not set
>> # CONFIG_MFD_INTEL_LPSS_ACPI is not set
>> # CONFIG_MFD_INTEL_LPSS_PCI is not set
>> CONFIG_MFD_JANZ_CMODIO=m
>> CONFIG_MFD_KEMPLD=y
>> CONFIG_MFD_88PM800=y
>> CONFIG_MFD_88PM805=y
>> # CONFIG_MFD_88PM860X is not set
>> # CONFIG_MFD_MAX14577 is not set
>> # CONFIG_MFD_MAX77620 is not set
>> CONFIG_MFD_MAX77686=y
>> # CONFIG_MFD_MAX77693 is not set
>> CONFIG_MFD_MAX77843=y
>> CONFIG_MFD_MAX8907=m
>> CONFIG_MFD_MAX8925=y
>> CONFIG_MFD_MAX8997=y
>> # CONFIG_MFD_MAX8998 is not set
>> CONFIG_MFD_MT6397=y
>> CONFIG_MFD_MENF21BMC=m
>> # CONFIG_MFD_RETU is not set
>> CONFIG_MFD_PCF50633=y
>> CONFIG_PCF50633_ADC=m
>> CONFIG_PCF50633_GPIO=y
>> CONFIG_MFD_RDC321X=m
>> CONFIG_MFD_RT5033=m
>> CONFIG_MFD_RC5T583=y
>> CONFIG_MFD_RK808=m
>> CONFIG_MFD_RN5T618=m
>> CONFIG_MFD_SEC_CORE=m
>> CONFIG_MFD_SI476X_CORE=y
>> CONFIG_MFD_SM501=m
>> CONFIG_MFD_SM501_GPIO=y
>> CONFIG_MFD_SKY81452=y
>> # CONFIG_MFD_SMSC is not set
>> # CONFIG_ABX500_CORE is not set
>> # CONFIG_MFD_STMPE is not set
>> CONFIG_MFD_SYSCON=y
>> # CONFIG_MFD_TI_AM335X_TSCADC is not set
>> CONFIG_MFD_LP3943=y
>> CONFIG_MFD_LP8788=y
>> # CONFIG_MFD_TI_LMU is not set
>> # CONFIG_MFD_PALMAS is not set
>> CONFIG_TPS6105X=y
>> # CONFIG_TPS65010 is not set
>> # CONFIG_TPS6507X is not set
>> CONFIG_MFD_TPS65086=m
>> # CONFIG_MFD_TPS65090 is not set
>> # CONFIG_MFD_TPS65217 is not set
>> # CONFIG_MFD_TPS68470 is not set
>> # CONFIG_MFD_TI_LP873X is not set
>> # CONFIG_MFD_TI_LP87565 is not set
>> CONFIG_MFD_TPS65218=m
>> CONFIG_MFD_TPS6586X=y
>> # CONFIG_MFD_TPS65910 is not set
>> CONFIG_MFD_TPS65912=m
>> CONFIG_MFD_TPS65912_I2C=m
>> # CONFIG_MFD_TPS80031 is not set
>> # CONFIG_TWL4030_CORE is not set
>> CONFIG_TWL6040_CORE=y
>> CONFIG_MFD_WL1273_CORE=y
>> # CONFIG_MFD_LM3533 is not set
>> # CONFIG_MFD_TC3589X is not set
>> CONFIG_MFD_VX855=y
>> CONFIG_MFD_ARIZONA=y
>> CONFIG_MFD_ARIZONA_I2C=m
>> CONFIG_MFD_CS47L24=y
>> CONFIG_MFD_WM5102=y
>> CONFIG_MFD_WM5110=y
>> # CONFIG_MFD_WM8997 is not set
>> CONFIG_MFD_WM8998=y
>> CONFIG_MFD_WM8400=y
>> CONFIG_MFD_WM831X=y
>> CONFIG_MFD_WM831X_I2C=y
>> # CONFIG_MFD_WM8350_I2C is not set
>> CONFIG_MFD_WM8994=m
>> # CONFIG_MFD_ROHM_BD718XX is not set
>> CONFIG_REGULATOR=y
>> CONFIG_REGULATOR_DEBUG=y
>> CONFIG_REGULATOR_FIXED_VOLTAGE=y
>> CONFIG_REGULATOR_VIRTUAL_CONSUMER=m
>> CONFIG_REGULATOR_USERSPACE_CONSUMER=y
>> CONFIG_REGULATOR_88PG86X=m
>> CONFIG_REGULATOR_88PM800=m
>> CONFIG_REGULATOR_ACT8865=y
>> CONFIG_REGULATOR_ACT8945A=m
>> # CONFIG_REGULATOR_AD5398 is not set
>> CONFIG_REGULATOR_ANATOP=y
>> CONFIG_REGULATOR_AAT2870=y
>> CONFIG_REGULATOR_AS3711=y
>> CONFIG_REGULATOR_AS3722=m
>> # CONFIG_REGULATOR_AXP20X is not set
>> CONFIG_REGULATOR_BD9571MWV=m
>> CONFIG_REGULATOR_DA9062=m
>> # CONFIG_REGULATOR_DA9063 is not set
>> CONFIG_REGULATOR_DA9210=m
>> # CONFIG_REGULATOR_DA9211 is not set
>> # CONFIG_REGULATOR_FAN53555 is not set
>> CONFIG_REGULATOR_GPIO=y
>> # CONFIG_REGULATOR_HI6421 is not set
>> # CONFIG_REGULATOR_HI6421V530 is not set
>> # CONFIG_REGULATOR_ISL9305 is not set
>> # CONFIG_REGULATOR_ISL6271A is not set
>> CONFIG_REGULATOR_LP3971=m
>> CONFIG_REGULATOR_LP3972=y
>> CONFIG_REGULATOR_LP872X=m
>> CONFIG_REGULATOR_LP8755=y
>> CONFIG_REGULATOR_LP8788=m
>> # CONFIG_REGULATOR_LTC3589 is not set
>> CONFIG_REGULATOR_LTC3676=y
>> # CONFIG_REGULATOR_MAX1586 is not set
>> # CONFIG_REGULATOR_MAX8649 is not set
>> # CONFIG_REGULATOR_MAX8660 is not set
>> # CONFIG_REGULATOR_MAX8907 is not set
>> CONFIG_REGULATOR_MAX8925=y
>> CONFIG_REGULATOR_MAX8952=m
>> # CONFIG_REGULATOR_MAX8973 is not set
>> CONFIG_REGULATOR_MAX8997=m
>> CONFIG_REGULATOR_MAX77686=y
>> # CONFIG_REGULATOR_MAX77693 is not set
>> CONFIG_REGULATOR_MAX77802=m
>> CONFIG_REGULATOR_MC13XXX_CORE=m
>> # CONFIG_REGULATOR_MC13783 is not set
>> CONFIG_REGULATOR_MC13892=m
>> # CONFIG_REGULATOR_MCP16502 is not set
>> CONFIG_REGULATOR_MT6311=m
>> CONFIG_REGULATOR_MT6323=y
>> CONFIG_REGULATOR_MT6397=m
>> CONFIG_REGULATOR_PCF50633=y
>> CONFIG_REGULATOR_PFUZE100=m
>> CONFIG_REGULATOR_PV88060=y
>> # CONFIG_REGULATOR_PV88080 is not set
>> CONFIG_REGULATOR_PV88090=m
>> # CONFIG_REGULATOR_PWM is not set
>> CONFIG_REGULATOR_RC5T583=y
>> CONFIG_REGULATOR_RK808=m
>> CONFIG_REGULATOR_RN5T618=m
>> # CONFIG_REGULATOR_RT5033 is not set
>> CONFIG_REGULATOR_S2MPA01=m
>> # CONFIG_REGULATOR_S2MPS11 is not set
>> # CONFIG_REGULATOR_S5M8767 is not set
>> CONFIG_REGULATOR_SKY81452=y
>> # CONFIG_REGULATOR_SY8106A is not set
>> # CONFIG_REGULATOR_TPS51632 is not set
>> # CONFIG_REGULATOR_TPS6105X is not set
>> CONFIG_REGULATOR_TPS62360=m
>> CONFIG_REGULATOR_TPS65023=y
>> CONFIG_REGULATOR_TPS6507X=m
>> CONFIG_REGULATOR_TPS65086=m
>> CONFIG_REGULATOR_TPS65132=m
>> CONFIG_REGULATOR_TPS65218=m
>> # CONFIG_REGULATOR_TPS6586X is not set
>> CONFIG_REGULATOR_TPS65912=m
>> CONFIG_REGULATOR_VCTRL=y
>> # CONFIG_REGULATOR_WM831X is not set
>> CONFIG_REGULATOR_WM8400=y
>> # CONFIG_REGULATOR_WM8994 is not set
>> CONFIG_CEC_CORE=m
>> CONFIG_CEC_NOTIFIER=y
>> CONFIG_RC_CORE=m
>> CONFIG_RC_MAP=m
>> # CONFIG_LIRC is not set
>> # CONFIG_RC_DECODERS is not set
>> # CONFIG_RC_DEVICES is not set
>> CONFIG_MEDIA_SUPPORT=y
>>
>> #
>> # Multimedia core support
>> #
>> CONFIG_MEDIA_CAMERA_SUPPORT=y
>> CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
>> CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
>> # CONFIG_MEDIA_RADIO_SUPPORT is not set
>> CONFIG_MEDIA_SDR_SUPPORT=y
>> CONFIG_MEDIA_CEC_SUPPORT=y
>> # CONFIG_MEDIA_CEC_RC is not set
>> # CONFIG_MEDIA_CONTROLLER is not set
>> CONFIG_VIDEO_DEV=y
>> CONFIG_VIDEO_V4L2=y
>> # CONFIG_VIDEO_ADV_DEBUG is not set
>> # CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
>> CONFIG_VIDEO_TUNER=y
>> CONFIG_VIDEOBUF_GEN=y
>> CONFIG_VIDEOBUF_DMA_SG=y
>> CONFIG_VIDEOBUF_VMALLOC=m
>> CONFIG_DVB_CORE=y
>> # CONFIG_DVB_MMAP is not set
>> CONFIG_DVB_NET=y
>> CONFIG_TTPCI_EEPROM=m
>> CONFIG_DVB_MAX_ADAPTERS=16
>> # CONFIG_DVB_DYNAMIC_MINORS is not set
>> CONFIG_DVB_DEMUX_SECTION_LOSS_LOG=y
>> CONFIG_DVB_ULE_DEBUG=y
>>
>> #
>> # Media drivers
>> #
>> CONFIG_MEDIA_PCI_SUPPORT=y
>>
>> #
>> # Media capture support
>> #
>> CONFIG_VIDEO_TW5864=y
>> # CONFIG_VIDEO_TW68 is not set
>>
>> #
>> # Media capture/analog TV support
>> #
>> # CONFIG_VIDEO_IVTV is not set
>> CONFIG_VIDEO_HEXIUM_GEMINI=m
>> CONFIG_VIDEO_HEXIUM_ORION=y
>> CONFIG_VIDEO_MXB=y
>> CONFIG_VIDEO_DT3155=m
>>
>> #
>> # Media capture/analog/hybrid TV support
>> #
>> CONFIG_VIDEO_CX18=m
>> CONFIG_VIDEO_CX25821=y
>> CONFIG_VIDEO_CX88=m
>> # CONFIG_VIDEO_CX88_BLACKBIRD is not set
>> CONFIG_VIDEO_CX88_DVB=m
>> CONFIG_VIDEO_CX88_ENABLE_VP3054=y
>> CONFIG_VIDEO_CX88_VP3054=m
>> CONFIG_VIDEO_CX88_MPEG=m
>> CONFIG_VIDEO_SAA7134=m
>> CONFIG_VIDEO_SAA7134_RC=y
>> CONFIG_VIDEO_SAA7134_DVB=m
>> CONFIG_VIDEO_SAA7164=m
>>
>> #
>> # Media digital TV PCI Adapters
>> #
>> CONFIG_DVB_AV7110_IR=y
>> CONFIG_DVB_AV7110=m
>> CONFIG_DVB_AV7110_OSD=y
>> # CONFIG_DVB_BUDGET_CORE is not set
>> CONFIG_DVB_B2C2_FLEXCOP_PCI=y
>> CONFIG_DVB_B2C2_FLEXCOP_PCI_DEBUG=y
>> CONFIG_DVB_PLUTO2=m
>> CONFIG_DVB_DM1105=m
>> CONFIG_DVB_PT1=m
>> CONFIG_DVB_PT3=y
>> # CONFIG_MANTIS_CORE is not set
>> CONFIG_DVB_NGENE=y
>> CONFIG_DVB_DDBRIDGE=m
>> # CONFIG_DVB_DDBRIDGE_MSIENABLE is not set
>> CONFIG_DVB_SMIPCIE=m
>> # CONFIG_V4L_PLATFORM_DRIVERS is not set
>> # CONFIG_V4L_MEM2MEM_DRIVERS is not set
>> # CONFIG_V4L_TEST_DRIVERS is not set
>> # CONFIG_DVB_PLATFORM_DRIVERS is not set
>> CONFIG_CEC_PLATFORM_DRIVERS=y
>> CONFIG_VIDEO_CROS_EC_CEC=m
>> # CONFIG_CEC_GPIO is not set
>> # CONFIG_VIDEO_SECO_CEC is not set
>> # CONFIG_SDR_PLATFORM_DRIVERS is not set
>>
>> #
>> # Supported MMC/SDIO adapters
>> #
>> # CONFIG_SMS_SDIO_DRV is not set
>> CONFIG_VIDEO_CX2341X=m
>> CONFIG_VIDEO_TVEEPROM=m
>> CONFIG_VIDEOBUF2_CORE=y
>> CONFIG_VIDEOBUF2_V4L2=y
>> CONFIG_VIDEOBUF2_MEMOPS=y
>> CONFIG_VIDEOBUF2_DMA_CONTIG=y
>> CONFIG_VIDEOBUF2_DMA_SG=y
>> CONFIG_VIDEOBUF2_DVB=m
>> CONFIG_DVB_B2C2_FLEXCOP=y
>> CONFIG_DVB_B2C2_FLEXCOP_DEBUG=y
>> CONFIG_VIDEO_SAA7146=y
>> CONFIG_VIDEO_SAA7146_VV=y
>>
>> #
>> # Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
>> #
>> CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
>> CONFIG_MEDIA_ATTACH=y
>> CONFIG_VIDEO_IR_I2C=m
>>
>> #
>> # Audio decoders, processors and mixers
>> #
>> CONFIG_VIDEO_TDA9840=y
>> CONFIG_VIDEO_TEA6415C=y
>> CONFIG_VIDEO_TEA6420=y
>> CONFIG_VIDEO_CS5345=m
>> CONFIG_VIDEO_WM8775=m
>>
>> #
>> # RDS decoders
>> #
>> CONFIG_VIDEO_SAA6588=m
>>
>> #
>> # Video decoders
>> #
>> CONFIG_VIDEO_SAA7110=m
>> CONFIG_VIDEO_SAA711X=y
>> CONFIG_VIDEO_VPX3220=m
>>
>> #
>> # Video and audio decoders
>> #
>>
>> #
>> # Video encoders
>> #
>> CONFIG_VIDEO_SAA7185=m
>> CONFIG_VIDEO_ADV7170=m
>> CONFIG_VIDEO_ADV7175=m
>>
>> #
>> # Camera sensor devices
>> #
>>
>> #
>> # Flash devices
>> #
>>
>> #
>> # Video improvement chips
>> #
>>
>> #
>> # Audio/Video compression chips
>> #
>> CONFIG_VIDEO_SAA6752HS=m
>>
>> #
>> # SDR tuner chips
>> #
>>
>> #
>> # Miscellaneous helper chips
>> #
>>
>> #
>> # Sensors used on soc_camera driver
>> #
>> CONFIG_MEDIA_TUNER=y
>> CONFIG_MEDIA_TUNER_SIMPLE=y
>> CONFIG_MEDIA_TUNER_TDA8290=y
>> CONFIG_MEDIA_TUNER_TDA827X=y
>> CONFIG_MEDIA_TUNER_TDA18271=y
>> CONFIG_MEDIA_TUNER_TDA9887=y
>> CONFIG_MEDIA_TUNER_MT20XX=y
>> CONFIG_MEDIA_TUNER_MT2131=y
>> CONFIG_MEDIA_TUNER_XC2028=y
>> CONFIG_MEDIA_TUNER_XC5000=y
>> CONFIG_MEDIA_TUNER_XC4000=y
>> CONFIG_MEDIA_TUNER_MXL5005S=m
>> CONFIG_MEDIA_TUNER_MC44S803=y
>> CONFIG_MEDIA_TUNER_TDA18212=y
>> CONFIG_MEDIA_TUNER_M88RS6000T=m
>> CONFIG_MEDIA_TUNER_SI2157=m
>> CONFIG_MEDIA_TUNER_MXL301RF=y
>> CONFIG_MEDIA_TUNER_QM1D1C0042=y
>> CONFIG_MEDIA_TUNER_QM1D1B0004=m
>>
>> #
>> # Multistandard (satellite) frontends
>> #
>> CONFIG_DVB_STB6100=m
>> CONFIG_DVB_STV090x=y
>> CONFIG_DVB_STV0910=y
>> CONFIG_DVB_STV6110x=y
>> CONFIG_DVB_STV6111=y
>> CONFIG_DVB_MXL5XX=m
>> CONFIG_DVB_M88DS3103=m
>>
>> #
>> # Multistandard (cable + terrestrial) frontends
>> #
>> CONFIG_DVB_DRXK=y
>> CONFIG_DVB_TDA18271C2DD=y
>>
>> #
>> # DVB-S (satellite) frontends
>> #
>> CONFIG_DVB_CX24123=y
>> CONFIG_DVB_MT312=y
>> CONFIG_DVB_ZL10036=m
>> CONFIG_DVB_ZL10039=m
>> CONFIG_DVB_S5H1420=y
>> CONFIG_DVB_STV0288=m
>> CONFIG_DVB_STB6000=m
>> CONFIG_DVB_STV0299=y
>> CONFIG_DVB_STV0900=m
>> CONFIG_DVB_TDA8083=m
>> CONFIG_DVB_TDA10086=m
>> CONFIG_DVB_VES1X93=m
>> CONFIG_DVB_TUNER_ITD1000=y
>> CONFIG_DVB_TUNER_CX24113=y
>> CONFIG_DVB_TDA826X=m
>> CONFIG_DVB_CX24116=m
>> CONFIG_DVB_CX24120=y
>> CONFIG_DVB_SI21XX=m
>> CONFIG_DVB_TS2020=m
>> CONFIG_DVB_DS3000=m
>>
>> #
>> # DVB-T (terrestrial) frontends
>> #
>> CONFIG_DVB_SP8870=m
>> CONFIG_DVB_CX22702=m
>> CONFIG_DVB_L64781=m
>> CONFIG_DVB_TDA1004X=m
>> CONFIG_DVB_MT352=y
>> CONFIG_DVB_ZL10353=m
>> CONFIG_DVB_TDA10048=m
>> CONFIG_DVB_STV0367=y
>> CONFIG_DVB_CXD2841ER=y
>> CONFIG_DVB_SI2168=m
>>
>> #
>> # DVB-C (cable) frontends
>> #
>> CONFIG_DVB_VES1820=m
>> CONFIG_DVB_STV0297=y
>>
>> #
>> # ATSC (North American/Korean Terrestrial/Cable DTV) frontends
>> #
>> CONFIG_DVB_NXT200X=y
>> CONFIG_DVB_OR51132=m
>> CONFIG_DVB_BCM3510=y
>> CONFIG_DVB_LGDT330X=y
>> CONFIG_DVB_LGDT3305=m
>> CONFIG_DVB_S5H1409=m
>> CONFIG_DVB_S5H1411=m
>>
>> #
>> # ISDB-T (terrestrial) frontends
>> #
>>
>> #
>> # ISDB-S (satellite) & ISDB-T (terrestrial) frontends
>> #
>> CONFIG_DVB_TC90522=y
>>
>> #
>> # Digital terrestrial only tuners/PLL
>> #
>> CONFIG_DVB_PLL=y
>>
>> #
>> # SEC control devices for DVB-S
>> #
>> CONFIG_DVB_LNBH25=y
>> CONFIG_DVB_LNBP21=y
>> CONFIG_DVB_ISL6405=m
>> CONFIG_DVB_ISL6421=y
>>
>> #
>> # Common Interface (EN50221) controller drivers
>> #
>> CONFIG_DVB_CXD2099=y
>>
>> #
>> # Tools to develop new frontends
>> #
>> CONFIG_DVB_DUMMY_FE=m
>>
>> #
>> # Graphics support
>> #
>> CONFIG_AGP=y
>> CONFIG_AGP_INTEL=m
>> CONFIG_AGP_SIS=y
>> CONFIG_AGP_VIA=m
>> CONFIG_INTEL_GTT=m
>> CONFIG_VGA_ARB=y
>> CONFIG_VGA_ARB_MAX_GPUS=16
>> # CONFIG_VGA_SWITCHEROO is not set
>> # CONFIG_DRM is not set
>> # CONFIG_DRM_DP_CEC is not set
>>
>> #
>> # ACP (Audio CoProcessor) Configuration
>> #
>>
>> #
>> # AMD Library routines
>> #
>>
>> #
>> # Frame buffer Devices
>> #
>> CONFIG_FB_CMDLINE=y
>> CONFIG_FB_NOTIFY=y
>> CONFIG_FB=m
>> CONFIG_FIRMWARE_EDID=y
>> CONFIG_FB_DDC=m
>> CONFIG_FB_CFB_FILLRECT=m
>> CONFIG_FB_CFB_COPYAREA=m
>> CONFIG_FB_CFB_IMAGEBLIT=m
>> CONFIG_FB_SYS_FILLRECT=m
>> CONFIG_FB_SYS_COPYAREA=m
>> CONFIG_FB_SYS_IMAGEBLIT=m
>> # CONFIG_FB_FOREIGN_ENDIAN is not set
>> CONFIG_FB_SYS_FOPS=m
>> CONFIG_FB_DEFERRED_IO=y
>> CONFIG_FB_HECUBA=m
>> CONFIG_FB_SVGALIB=m
>> CONFIG_FB_BACKLIGHT=m
>> CONFIG_FB_MODE_HELPERS=y
>> CONFIG_FB_TILEBLITTING=y
>>
>> #
>> # Frame buffer hardware drivers
>> #
>> CONFIG_FB_CIRRUS=m
>> CONFIG_FB_PM2=m
>> CONFIG_FB_PM2_FIFO_DISCONNECT=y
>> # CONFIG_FB_CYBER2000 is not set
>> CONFIG_FB_ARC=m
>> # CONFIG_FB_VGA16 is not set
>> CONFIG_FB_N411=m
>> CONFIG_FB_HGA=m
>> CONFIG_FB_OPENCORES=m
>> # CONFIG_FB_S1D13XXX is not set
>> CONFIG_FB_NVIDIA=m
>> CONFIG_FB_NVIDIA_I2C=y
>> CONFIG_FB_NVIDIA_DEBUG=y
>> # CONFIG_FB_NVIDIA_BACKLIGHT is not set
>> # CONFIG_FB_RIVA is not set
>> CONFIG_FB_I740=m
>> CONFIG_FB_LE80578=m
>> CONFIG_FB_CARILLO_RANCH=m
>> CONFIG_FB_INTEL=m
>> CONFIG_FB_INTEL_DEBUG=y
>> # CONFIG_FB_INTEL_I2C is not set
>> CONFIG_FB_MATROX=m
>> CONFIG_FB_MATROX_MILLENIUM=y
>> # CONFIG_FB_MATROX_MYSTIQUE is not set
>> CONFIG_FB_MATROX_G=y
>> CONFIG_FB_MATROX_I2C=m
>> # CONFIG_FB_MATROX_MAVEN is not set
>> CONFIG_FB_RADEON=m
>> CONFIG_FB_RADEON_I2C=y
>> CONFIG_FB_RADEON_BACKLIGHT=y
>> CONFIG_FB_RADEON_DEBUG=y
>> CONFIG_FB_ATY128=m
>> # CONFIG_FB_ATY128_BACKLIGHT is not set
>> CONFIG_FB_ATY=m
>> # CONFIG_FB_ATY_CT is not set
>> CONFIG_FB_ATY_GX=y
>> # CONFIG_FB_ATY_BACKLIGHT is not set
>> CONFIG_FB_S3=m
>> CONFIG_FB_S3_DDC=y
>> CONFIG_FB_SAVAGE=m
>> CONFIG_FB_SAVAGE_I2C=y
>> # CONFIG_FB_SAVAGE_ACCEL is not set
>> CONFIG_FB_SIS=m
>> CONFIG_FB_SIS_300=y
>> # CONFIG_FB_SIS_315 is not set
>> CONFIG_FB_VIA=m
>> CONFIG_FB_VIA_DIRECT_PROCFS=y
>> CONFIG_FB_VIA_X_COMPATIBILITY=y
>> # CONFIG_FB_NEOMAGIC is not set
>> CONFIG_FB_KYRO=m
>> CONFIG_FB_3DFX=m
>> # CONFIG_FB_3DFX_ACCEL is not set
>> CONFIG_FB_3DFX_I2C=y
>> CONFIG_FB_VOODOO1=m
>> CONFIG_FB_VT8623=m
>> CONFIG_FB_TRIDENT=m
>> CONFIG_FB_ARK=m
>> CONFIG_FB_PM3=m
>> CONFIG_FB_CARMINE=m
>> # CONFIG_FB_CARMINE_DRAM_EVAL is not set
>> CONFIG_CARMINE_DRAM_CUSTOM=y
>> CONFIG_FB_SM501=m
>> CONFIG_FB_IBM_GXT4500=m
>> # CONFIG_FB_VIRTUAL is not set
>> # CONFIG_FB_METRONOME is not set
>> # CONFIG_FB_MB862XX is not set
>> # CONFIG_FB_SSD1307 is not set
>> # CONFIG_FB_SM712 is not set
>> CONFIG_BACKLIGHT_LCD_SUPPORT=y
>> CONFIG_LCD_CLASS_DEVICE=y
>> CONFIG_LCD_PLATFORM=y
>> CONFIG_BACKLIGHT_CLASS_DEVICE=y
>> CONFIG_BACKLIGHT_GENERIC=m
>> CONFIG_BACKLIGHT_CARILLO_RANCH=m
>> # CONFIG_BACKLIGHT_PWM is not set
>> CONFIG_BACKLIGHT_MAX8925=m
>> # CONFIG_BACKLIGHT_APPLE is not set
>> CONFIG_BACKLIGHT_PM8941_WLED=m
>> CONFIG_BACKLIGHT_SAHARA=m
>> CONFIG_BACKLIGHT_WM831X=m
>> CONFIG_BACKLIGHT_ADP8860=y
>> CONFIG_BACKLIGHT_ADP8870=m
>> CONFIG_BACKLIGHT_PCF50633=m
>> CONFIG_BACKLIGHT_AAT2870=y
>> CONFIG_BACKLIGHT_LM3630A=y
>> CONFIG_BACKLIGHT_LM3639=m
>> CONFIG_BACKLIGHT_LP855X=y
>> CONFIG_BACKLIGHT_LP8788=y
>> CONFIG_BACKLIGHT_SKY81452=m
>> # CONFIG_BACKLIGHT_AS3711 is not set
>> CONFIG_BACKLIGHT_GPIO=y
>> CONFIG_BACKLIGHT_LV5207LP=y
>> CONFIG_BACKLIGHT_BD6107=m
>> # CONFIG_BACKLIGHT_ARCXCNN is not set
>> CONFIG_VGASTATE=m
>> # CONFIG_LOGO is not set
>> CONFIG_SOUND=y
>> # CONFIG_SND is not set
>>
>> #
>> # HID support
>> #
>> CONFIG_HID=m
>> # CONFIG_HID_BATTERY_STRENGTH is not set
>> # CONFIG_HIDRAW is not set
>> # CONFIG_UHID is not set
>> # CONFIG_HID_GENERIC is not set
>>
>> #
>> # Special HID drivers
>> #
>> # CONFIG_HID_A4TECH is not set
>> CONFIG_HID_ACRUX=m
>> # CONFIG_HID_ACRUX_FF is not set
>> CONFIG_HID_APPLE=m
>> CONFIG_HID_ASUS=m
>> CONFIG_HID_AUREAL=m
>> CONFIG_HID_BELKIN=m
>> CONFIG_HID_CHERRY=m
>> CONFIG_HID_CHICONY=m
>> CONFIG_HID_COUGAR=m
>> # CONFIG_HID_CMEDIA is not set
>> CONFIG_HID_CYPRESS=m
>> CONFIG_HID_DRAGONRISE=m
>> CONFIG_DRAGONRISE_FF=y
>> CONFIG_HID_EMS_FF=m
>> CONFIG_HID_ELECOM=m
>> # CONFIG_HID_EZKEY is not set
>> CONFIG_HID_GEMBIRD=m
>> CONFIG_HID_GFRM=m
>> # CONFIG_HID_KEYTOUCH is not set
>> CONFIG_HID_KYE=m
>> CONFIG_HID_WALTOP=m
>> CONFIG_HID_GYRATION=m
>> CONFIG_HID_ICADE=m
>> CONFIG_HID_ITE=m
>> CONFIG_HID_JABRA=m
>> # CONFIG_HID_TWINHAN is not set
>> # CONFIG_HID_KENSINGTON is not set
>> CONFIG_HID_LCPOWER=m
>> CONFIG_HID_LED=m
>> # CONFIG_HID_LENOVO is not set
>> CONFIG_HID_LOGITECH=m
>> # CONFIG_HID_LOGITECH_HIDPP is not set
>> CONFIG_LOGITECH_FF=y
>> # CONFIG_LOGIRUMBLEPAD2_FF is not set
>> # CONFIG_LOGIG940_FF is not set
>> # CONFIG_LOGIWHEELS_FF is not set
>> # CONFIG_HID_MAGICMOUSE is not set
>> CONFIG_HID_MAYFLASH=m
>> CONFIG_HID_REDRAGON=m
>> CONFIG_HID_MICROSOFT=m
>> CONFIG_HID_MONTEREY=m
>> # CONFIG_HID_MULTITOUCH is not set
>> CONFIG_HID_NTI=m
>> CONFIG_HID_ORTEK=m
>> CONFIG_HID_PANTHERLORD=m
>> CONFIG_PANTHERLORD_FF=y
>> # CONFIG_HID_PETALYNX is not set
>> CONFIG_HID_PICOLCD=m
>> # CONFIG_HID_PICOLCD_FB is not set
>> # CONFIG_HID_PICOLCD_BACKLIGHT is not set
>> CONFIG_HID_PICOLCD_LCD=y
>> CONFIG_HID_PICOLCD_LEDS=y
>> CONFIG_HID_PICOLCD_CIR=y
>> CONFIG_HID_PLANTRONICS=m
>> # CONFIG_HID_PRIMAX is not set
>> CONFIG_HID_SAITEK=m
>> # CONFIG_HID_SAMSUNG is not set
>> CONFIG_HID_SPEEDLINK=m
>> # CONFIG_HID_STEAM is not set
>> # CONFIG_HID_STEELSERIES is not set
>> # CONFIG_HID_SUNPLUS is not set
>> CONFIG_HID_RMI=m
>> CONFIG_HID_GREENASIA=m
>> CONFIG_GREENASIA_FF=y
>> CONFIG_HID_SMARTJOYPLUS=m
>> CONFIG_SMARTJOYPLUS_FF=y
>> # CONFIG_HID_TIVO is not set
>> CONFIG_HID_TOPSEED=m
>> CONFIG_HID_THINGM=m
>> CONFIG_HID_THRUSTMASTER=m
>> CONFIG_THRUSTMASTER_FF=y
>> CONFIG_HID_UDRAW_PS3=m
>> CONFIG_HID_WIIMOTE=m
>> CONFIG_HID_XINMO=m
>> CONFIG_HID_ZEROPLUS=m
>> # CONFIG_ZEROPLUS_FF is not set
>> # CONFIG_HID_ZYDACRON is not set
>> # CONFIG_HID_SENSOR_HUB is not set
>> CONFIG_HID_ALPS=m
>>
>> #
>> # I2C HID support
>> #
>> # CONFIG_I2C_HID is not set
>>
>> #
>> # Intel ISH HID support
>> #
>> CONFIG_INTEL_ISH_HID=m
>> CONFIG_USB_OHCI_LITTLE_ENDIAN=y
>> CONFIG_USB_SUPPORT=y
>> CONFIG_USB_ARCH_HAS_HCD=y
>> # CONFIG_USB is not set
>> CONFIG_USB_PCI=y
>>
>> #
>> # USB port drivers
>> #
>>
>> #
>> # USB Physical Layer drivers
>> #
>> # CONFIG_NOP_USB_XCEIV is not set
>> # CONFIG_USB_GPIO_VBUS is not set
>> # CONFIG_USB_GADGET is not set
>> # CONFIG_TYPEC is not set
>> # CONFIG_USB_ROLE_SWITCH is not set
>> # CONFIG_USB_LED_TRIG is not set
>> # CONFIG_USB_ULPI_BUS is not set
>> CONFIG_UWB=m
>> CONFIG_UWB_WHCI=m
>> CONFIG_MMC=m
>> # CONFIG_PWRSEQ_EMMC is not set
>> CONFIG_PWRSEQ_SIMPLE=m
>> # CONFIG_SDIO_UART is not set
>> CONFIG_MMC_TEST=m
>>
>> #
>> # MMC/SD/SDIO Host Controller Drivers
>> #
>> CONFIG_MMC_DEBUG=y
>> CONFIG_MMC_SDHCI=m
>> CONFIG_MMC_SDHCI_PCI=m
>> # CONFIG_MMC_RICOH_MMC is not set
>> # CONFIG_MMC_SDHCI_ACPI is not set
>> # CONFIG_MMC_SDHCI_PLTFM is not set
>> CONFIG_MMC_ALCOR=m
>> CONFIG_MMC_TIFM_SD=m
>> CONFIG_MMC_SDRICOH_CS=m
>> CONFIG_MMC_CB710=m
>> # CONFIG_MMC_VIA_SDMMC is not set
>> CONFIG_MMC_USDHI6ROL0=m
>> # CONFIG_MMC_REALTEK_PCI is not set
>> CONFIG_MMC_CQHCI=m
>> CONFIG_MMC_TOSHIBA_PCI=m
>> CONFIG_MMC_MTK=m
>> # CONFIG_MEMSTICK is not set
>> CONFIG_NEW_LEDS=y
>> CONFIG_LEDS_CLASS=y
>> CONFIG_LEDS_CLASS_FLASH=y
>> CONFIG_LEDS_BRIGHTNESS_HW_CHANGED=y
>>
>> #
>> # LED drivers
>> #
>> # CONFIG_LEDS_AAT1290 is not set
>> # CONFIG_LEDS_AN30259A is not set
>> CONFIG_LEDS_APU=m
>> CONFIG_LEDS_AS3645A=m
>> CONFIG_LEDS_BCM6328=y
>> CONFIG_LEDS_BCM6358=m
>> # CONFIG_LEDS_LM3530 is not set
>> CONFIG_LEDS_LM3642=y
>> # CONFIG_LEDS_LM3692X is not set
>> CONFIG_LEDS_LM3601X=m
>> CONFIG_LEDS_MT6323=y
>> CONFIG_LEDS_PCA9532=m
>> CONFIG_LEDS_PCA9532_GPIO=y
>> # CONFIG_LEDS_GPIO is not set
>> # CONFIG_LEDS_LP3944 is not set
>> # CONFIG_LEDS_LP3952 is not set
>> CONFIG_LEDS_LP55XX_COMMON=y
>> # CONFIG_LEDS_LP5521 is not set
>> CONFIG_LEDS_LP5523=m
>> CONFIG_LEDS_LP5562=y
>> CONFIG_LEDS_LP8501=y
>> # CONFIG_LEDS_LP8788 is not set
>> # CONFIG_LEDS_LP8860 is not set
>> CONFIG_LEDS_CLEVO_MAIL=m
>> # CONFIG_LEDS_PCA955X is not set
>> # CONFIG_LEDS_PCA963X is not set
>> CONFIG_LEDS_WM831X_STATUS=m
>> CONFIG_LEDS_PWM=y
>> # CONFIG_LEDS_REGULATOR is not set
>> # CONFIG_LEDS_BD2802 is not set
>> CONFIG_LEDS_INTEL_SS4200=y
>> CONFIG_LEDS_LT3593=m
>> # CONFIG_LEDS_MC13783 is not set
>> CONFIG_LEDS_TCA6507=y
>> CONFIG_LEDS_TLC591XX=y
>> CONFIG_LEDS_MAX8997=m
>> CONFIG_LEDS_LM355x=y
>> # CONFIG_LEDS_MENF21BMC is not set
>> CONFIG_LEDS_KTD2692=y
>> CONFIG_LEDS_IS31FL319X=m
>> CONFIG_LEDS_IS31FL32XX=y
>>
>> #
>> # LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
>> #
>> # CONFIG_LEDS_BLINKM is not set
>> CONFIG_LEDS_SYSCON=y
>> CONFIG_LEDS_MLXCPLD=y
>> CONFIG_LEDS_MLXREG=y
>> CONFIG_LEDS_USER=y
>> # CONFIG_LEDS_NIC78BX is not set
>>
>> #
>> # LED Triggers
>> #
>> CONFIG_LEDS_TRIGGERS=y
>> CONFIG_LEDS_TRIGGER_TIMER=m
>> CONFIG_LEDS_TRIGGER_ONESHOT=y
>> CONFIG_LEDS_TRIGGER_MTD=y
>> CONFIG_LEDS_TRIGGER_HEARTBEAT=m
>> CONFIG_LEDS_TRIGGER_BACKLIGHT=y
>> # CONFIG_LEDS_TRIGGER_CPU is not set
>> CONFIG_LEDS_TRIGGER_ACTIVITY=m
>> CONFIG_LEDS_TRIGGER_GPIO=m
>> CONFIG_LEDS_TRIGGER_DEFAULT_ON=m
>>
>> #
>> # iptables trigger is under Netfilter config (LED target)
>> #
>> CONFIG_LEDS_TRIGGER_TRANSIENT=m
>> # CONFIG_LEDS_TRIGGER_CAMERA is not set
>> CONFIG_LEDS_TRIGGER_PANIC=y
>> CONFIG_LEDS_TRIGGER_NETDEV=m
>> CONFIG_LEDS_TRIGGER_PATTERN=m
>> CONFIG_LEDS_TRIGGER_AUDIO=m
>> # CONFIG_ACCESSIBILITY is not set
>> # CONFIG_INFINIBAND is not set
>> CONFIG_EDAC_ATOMIC_SCRUB=y
>> CONFIG_EDAC_SUPPORT=y
>> # CONFIG_EDAC is not set
>> CONFIG_RTC_LIB=y
>> CONFIG_RTC_MC146818_LIB=y
>> CONFIG_RTC_CLASS=y
>> # CONFIG_RTC_HCTOSYS is not set
>> # CONFIG_RTC_SYSTOHC is not set
>> # CONFIG_RTC_DEBUG is not set
>> # CONFIG_RTC_NVMEM is not set
>>
>> #
>> # RTC interfaces
>> #
>> CONFIG_RTC_INTF_SYSFS=y
>> # CONFIG_RTC_INTF_PROC is not set
>> CONFIG_RTC_INTF_DEV=y
>> # CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
>> CONFIG_RTC_DRV_TEST=y
>>
>> #
>> # I2C RTC drivers
>> #
>> CONFIG_RTC_DRV_88PM80X=m
>> CONFIG_RTC_DRV_ABB5ZES3=y
>> # CONFIG_RTC_DRV_ABX80X is not set
>> CONFIG_RTC_DRV_AS3722=m
>> CONFIG_RTC_DRV_DS1307=y
>> CONFIG_RTC_DRV_DS1307_CENTURY=y
>> # CONFIG_RTC_DRV_DS1374 is not set
>> CONFIG_RTC_DRV_DS1672=y
>> # CONFIG_RTC_DRV_HYM8563 is not set
>> # CONFIG_RTC_DRV_LP8788 is not set
>> CONFIG_RTC_DRV_MAX6900=m
>> CONFIG_RTC_DRV_MAX8907=m
>> # CONFIG_RTC_DRV_MAX8925 is not set
>> CONFIG_RTC_DRV_MAX8997=m
>> CONFIG_RTC_DRV_MAX77686=y
>> CONFIG_RTC_DRV_RK808=m
>> CONFIG_RTC_DRV_RS5C372=y
>> CONFIG_RTC_DRV_ISL1208=m
>> # CONFIG_RTC_DRV_ISL12022 is not set
>> CONFIG_RTC_DRV_ISL12026=y
>> # CONFIG_RTC_DRV_X1205 is not set
>> CONFIG_RTC_DRV_PCF8523=m
>> CONFIG_RTC_DRV_PCF85063=y
>> # CONFIG_RTC_DRV_PCF85363 is not set
>> # CONFIG_RTC_DRV_PCF8563 is not set
>> CONFIG_RTC_DRV_PCF8583=m
>> # CONFIG_RTC_DRV_M41T80 is not set
>> CONFIG_RTC_DRV_BQ32K=m
>> CONFIG_RTC_DRV_TPS6586X=m
>> CONFIG_RTC_DRV_RC5T583=y
>> CONFIG_RTC_DRV_S35390A=y
>> CONFIG_RTC_DRV_FM3130=m
>> CONFIG_RTC_DRV_RX8010=m
>> CONFIG_RTC_DRV_RX8581=y
>> CONFIG_RTC_DRV_RX8025=m
>> CONFIG_RTC_DRV_EM3027=m
>> # CONFIG_RTC_DRV_RV8803 is not set
>> CONFIG_RTC_DRV_S5M=m
>>
>> #
>> # SPI RTC drivers
>> #
>> CONFIG_RTC_I2C_AND_SPI=y
>>
>> #
>> # SPI and I2C RTC drivers
>> #
>> # CONFIG_RTC_DRV_DS3232 is not set
>> CONFIG_RTC_DRV_PCF2127=m
>> CONFIG_RTC_DRV_RV3029C2=m
>> CONFIG_RTC_DRV_RV3029_HWMON=y
>>
>> #
>> # Platform RTC drivers
>> #
>> CONFIG_RTC_DRV_CMOS=m
>> CONFIG_RTC_DRV_DS1286=y
>> CONFIG_RTC_DRV_DS1511=m
>> CONFIG_RTC_DRV_DS1553=y
>> CONFIG_RTC_DRV_DS1685_FAMILY=m
>> # CONFIG_RTC_DRV_DS1685 is not set
>> CONFIG_RTC_DRV_DS1689=y
>> # CONFIG_RTC_DRV_DS17285 is not set
>> # CONFIG_RTC_DRV_DS17485 is not set
>> # CONFIG_RTC_DRV_DS17885 is not set
>> # CONFIG_RTC_DRV_DS1742 is not set
>> CONFIG_RTC_DRV_DS2404=m
>> # CONFIG_RTC_DRV_DA9063 is not set
>> CONFIG_RTC_DRV_STK17TA8=y
>> CONFIG_RTC_DRV_M48T86=y
>> # CONFIG_RTC_DRV_M48T35 is not set
>> CONFIG_RTC_DRV_M48T59=m
>> # CONFIG_RTC_DRV_MSM6242 is not set
>> # CONFIG_RTC_DRV_BQ4802 is not set
>> # CONFIG_RTC_DRV_RP5C01 is not set
>> CONFIG_RTC_DRV_V3020=y
>> CONFIG_RTC_DRV_WM831X=m
>> # CONFIG_RTC_DRV_PCF50633 is not set
>> CONFIG_RTC_DRV_ZYNQMP=y
>> # CONFIG_RTC_DRV_CROS_EC is not set
>>
>> #
>> # on-CPU RTC drivers
>> #
>> # CONFIG_RTC_DRV_FTRTC010 is not set
>> CONFIG_RTC_DRV_MC13XXX=m
>> # CONFIG_RTC_DRV_SNVS is not set
>> CONFIG_RTC_DRV_MT6397=m
>> CONFIG_RTC_DRV_R7301=m
>>
>> #
>> # HID Sensor RTC drivers
>> #
>> CONFIG_DMADEVICES=y
>> # CONFIG_DMADEVICES_DEBUG is not set
>>
>> #
>> # DMA Devices
>> #
>> CONFIG_DMA_ENGINE=y
>> CONFIG_DMA_VIRTUAL_CHANNELS=y
>> CONFIG_DMA_ACPI=y
>> CONFIG_DMA_OF=y
>> CONFIG_ALTERA_MSGDMA=y
>> CONFIG_DW_AXI_DMAC=y
>> CONFIG_FSL_EDMA=y
>> # CONFIG_INTEL_IDMA64 is not set
>> CONFIG_INTEL_IOATDMA=y
>> # CONFIG_INTEL_MIC_X100_DMA is not set
>> CONFIG_QCOM_HIDMA_MGMT=m
>> CONFIG_QCOM_HIDMA=y
>> CONFIG_DW_DMAC_CORE=y
>> CONFIG_DW_DMAC=m
>> CONFIG_DW_DMAC_PCI=y
>> CONFIG_HSU_DMA=y
>>
>> #
>> # DMA Clients
>> #
>> CONFIG_ASYNC_TX_DMA=y
>> CONFIG_DMATEST=y
>> CONFIG_DMA_ENGINE_RAID=y
>>
>> #
>> # DMABUF options
>> #
>> CONFIG_SYNC_FILE=y
>> CONFIG_SW_SYNC=y
>> CONFIG_UDMABUF=y
>> CONFIG_DCA=y
>> CONFIG_AUXDISPLAY=y
>> # CONFIG_HD44780 is not set
>> CONFIG_IMG_ASCII_LCD=y
>> CONFIG_HT16K33=m
>> # CONFIG_UIO is not set
>> CONFIG_VIRT_DRIVERS=y
>> CONFIG_VBOXGUEST=m
>> CONFIG_VIRTIO=y
>> CONFIG_VIRTIO_MENU=y
>> CONFIG_VIRTIO_PCI=y
>> CONFIG_VIRTIO_PCI_LEGACY=y
>> # CONFIG_VIRTIO_BALLOON is not set
>> CONFIG_VIRTIO_INPUT=m
>> # CONFIG_VIRTIO_MMIO is not set
>>
>> #
>> # Microsoft Hyper-V guest support
>> #
>> # CONFIG_HYPERV is not set
>> CONFIG_STAGING=y
>> # CONFIG_COMEDI is not set
>> # CONFIG_RTLLIB is not set
>> CONFIG_RTL8723BS=m
>> CONFIG_R8822BE=m
>> CONFIG_RTLWIFI_DEBUG_ST=y
>> CONFIG_VT6655=m
>>
>> #
>> # IIO staging drivers
>> #
>>
>> #
>> # Accelerometers
>> #
>>
>> #
>> # Analog to digital converters
>> #
>> CONFIG_AD7606=y
>> # CONFIG_AD7606_IFACE_PARALLEL is not set
>>
>> #
>> # Analog digital bi-direction converters
>> #
>> # CONFIG_ADT7316 is not set
>>
>> #
>> # Capacitance to digital converters
>> #
>> CONFIG_AD7150=y
>> # CONFIG_AD7152 is not set
>> CONFIG_AD7746=y
>>
>> #
>> # Direct Digital Synthesis
>> #
>>
>> #
>> # Network Analyzer, Impedance Converters
>> #
>> CONFIG_AD5933=m
>>
>> #
>> # Active energy metering IC
>> #
>> # CONFIG_ADE7854 is not set
>>
>> #
>> # Resolver to digital converters
>> #
>> # CONFIG_FB_SM750 is not set
>> # CONFIG_FB_XGI is not set
>>
>> #
>> # Speakup console speech
>> #
>> CONFIG_STAGING_MEDIA=y
>> CONFIG_VIDEO_ZORAN=m
>> CONFIG_VIDEO_ZORAN_DC30=m
>> CONFIG_VIDEO_ZORAN_ZR36060=m
>> CONFIG_VIDEO_ZORAN_BUZ=m
>> CONFIG_VIDEO_ZORAN_DC10=m
>> # CONFIG_VIDEO_ZORAN_LML33 is not set
>> CONFIG_VIDEO_ZORAN_LML33R10=m
>> # CONFIG_VIDEO_ZORAN_AVS6EYES is not set
>>
>> #
>> # Android
>> #
>> CONFIG_ASHMEM=y
>> CONFIG_ANDROID_VSOC=y
>> # CONFIG_ION is not set
>> # CONFIG_STAGING_BOARD is not set
>> CONFIG_GS_FPGABOOT=m
>> # CONFIG_UNISYSSPAR is not set
>> CONFIG_COMMON_CLK_XLNX_CLKWZRD=y
>> # CONFIG_WILC1000_SDIO is not set
>> CONFIG_MOST=m
>> CONFIG_MOST_CDEV=m
>> CONFIG_MOST_NET=m
>> # CONFIG_MOST_VIDEO is not set
>> # CONFIG_MOST_DIM2 is not set
>> CONFIG_MOST_I2C=m
>> # CONFIG_KS7010 is not set
>> CONFIG_GREYBUS=m
>> CONFIG_GREYBUS_AUDIO=m
>> CONFIG_GREYBUS_BOOTROM=m
>> CONFIG_GREYBUS_HID=m
>> CONFIG_GREYBUS_LIGHT=m
>> CONFIG_GREYBUS_LOG=m
>> # CONFIG_GREYBUS_LOOPBACK is not set
>> # CONFIG_GREYBUS_POWER is not set
>> CONFIG_GREYBUS_RAW=m
>> # CONFIG_GREYBUS_VIBRATOR is not set
>> CONFIG_GREYBUS_BRIDGED_PHY=m
>> # CONFIG_GREYBUS_GPIO is not set
>> # CONFIG_GREYBUS_I2C is not set
>> CONFIG_GREYBUS_PWM=m
>> CONFIG_GREYBUS_SDIO=m
>> CONFIG_GREYBUS_UART=m
>> CONFIG_MTK_MMC=m
>> # CONFIG_MTK_AEE_KDUMP is not set
>> CONFIG_MTK_MMC_CD_POLL=y
>>
>> #
>> # Gasket devices
>> #
>> CONFIG_STAGING_GASKET_FRAMEWORK=y
>> # CONFIG_STAGING_APEX_DRIVER is not set
>> CONFIG_XIL_AXIS_FIFO=y
>> CONFIG_X86_PLATFORM_DEVICES=y
>> # CONFIG_ACER_WIRELESS is not set
>> # CONFIG_ACERHDF is not set
>> # CONFIG_ASUS_LAPTOP is not set
>> CONFIG_DCDBAS=m
>> CONFIG_DELL_SMBIOS=m
>> CONFIG_DELL_SMBIOS_SMM=y
>> CONFIG_DELL_LAPTOP=m
>> # CONFIG_DELL_SMO8800 is not set
>> # CONFIG_DELL_RBTN is not set
>> # CONFIG_DELL_RBU is not set
>> # CONFIG_FUJITSU_LAPTOP is not set
>> # CONFIG_FUJITSU_TABLET is not set
>> CONFIG_AMILO_RFKILL=m
>> # CONFIG_GPD_POCKET_FAN is not set
>> # CONFIG_HP_ACCEL is not set
>> # CONFIG_HP_WIRELESS is not set
>> # CONFIG_MSI_LAPTOP is not set
>> # CONFIG_PANASONIC_LAPTOP is not set
>> # CONFIG_COMPAL_LAPTOP is not set
>> # CONFIG_SONY_LAPTOP is not set
>> # CONFIG_IDEAPAD_LAPTOP is not set
>> # CONFIG_THINKPAD_ACPI is not set
>> CONFIG_SENSORS_HDAPS=m
>> # CONFIG_INTEL_MENLOW is not set
>> # CONFIG_EEEPC_LAPTOP is not set
>> # CONFIG_ASUS_WIRELESS is not set
>> # CONFIG_ACPI_WMI is not set
>> # CONFIG_TOPSTAR_LAPTOP is not set
>> # CONFIG_TOSHIBA_BT_RFKILL is not set
>> # CONFIG_TOSHIBA_HAPS is not set
>> # CONFIG_ACPI_CMPC is not set
>> # CONFIG_INTEL_INT0002_VGPIO is not set
>> # CONFIG_INTEL_HID_EVENT is not set
>> # CONFIG_INTEL_VBTN is not set
>> # CONFIG_INTEL_IPS is not set
>> CONFIG_INTEL_PMC_CORE=m
>> CONFIG_IBM_RTL=m
>> # CONFIG_SAMSUNG_LAPTOP is not set
>> # CONFIG_INTEL_OAKTRAIL is not set
>> # CONFIG_SAMSUNG_Q10 is not set
>> # CONFIG_APPLE_GMUX is not set
>> # CONFIG_INTEL_RST is not set
>> # CONFIG_INTEL_SMARTCONNECT is not set
>> # CONFIG_INTEL_PMC_IPC is not set
>> # CONFIG_SURFACE_PRO3_BUTTON is not set
>> CONFIG_INTEL_PUNIT_IPC=y
>> # CONFIG_MLX_PLATFORM is not set
>> # CONFIG_I2C_MULTI_INSTANTIATE is not set
>> CONFIG_INTEL_ATOMISP2_PM=m
>> CONFIG_PMC_ATOM=y
>> CONFIG_CHROME_PLATFORMS=y
>> # CONFIG_CHROMEOS_LAPTOP is not set
>> CONFIG_CHROMEOS_PSTORE=m
>> # CONFIG_CHROMEOS_TBMC is not set
>> CONFIG_CROS_EC_CTL=m
>> CONFIG_CROS_EC_I2C=m
>> # CONFIG_CROS_EC_LPC is not set
>> CONFIG_CROS_EC_PROTO=y
>> # CONFIG_CROS_KBD_LED_BACKLIGHT is not set
>> # CONFIG_MELLANOX_PLATFORM is not set
>> CONFIG_CLKDEV_LOOKUP=y
>> CONFIG_HAVE_CLK_PREPARE=y
>> CONFIG_COMMON_CLK=y
>>
>> #
>> # Common Clock Framework
>> #
>> CONFIG_COMMON_CLK_WM831X=m
>> CONFIG_CLK_HSDK=y
>> CONFIG_COMMON_CLK_MAX77686=y
>> # CONFIG_COMMON_CLK_MAX9485 is not set
>> CONFIG_COMMON_CLK_RK808=m
>> CONFIG_COMMON_CLK_SI5351=m
>> CONFIG_COMMON_CLK_SI514=m
>> CONFIG_COMMON_CLK_SI544=y
>> # CONFIG_COMMON_CLK_SI570 is not set
>> CONFIG_COMMON_CLK_CDCE706=y
>> # CONFIG_COMMON_CLK_CDCE925 is not set
>> CONFIG_COMMON_CLK_CS2000_CP=m
>> CONFIG_COMMON_CLK_S2MPS11=m
>> CONFIG_CLK_TWL6040=y
>> CONFIG_COMMON_CLK_PWM=m
>> # CONFIG_COMMON_CLK_VC5 is not set
>> CONFIG_HWSPINLOCK=y
>>
>> #
>> # Clock Source drivers
>> #
>> CONFIG_CLKEVT_I8253=y
>> CONFIG_I8253_LOCK=y
>> CONFIG_CLKBLD_I8253=y
>> CONFIG_MAILBOX=y
>> CONFIG_PLATFORM_MHU=y
>> # CONFIG_PCC is not set
>> CONFIG_ALTERA_MBOX=m
>> # CONFIG_MAILBOX_TEST is not set
>> # CONFIG_IOMMU_SUPPORT is not set
>>
>> #
>> # Remoteproc drivers
>> #
>> CONFIG_REMOTEPROC=m
>>
>> #
>> # Rpmsg drivers
>> #
>> CONFIG_RPMSG=m
>> CONFIG_RPMSG_CHAR=m
>> CONFIG_RPMSG_QCOM_GLINK_NATIVE=m
>> CONFIG_RPMSG_QCOM_GLINK_RPM=m
>> # CONFIG_RPMSG_VIRTIO is not set
>> CONFIG_SOUNDWIRE=y
>>
>> #
>> # SoundWire Devices
>> #
>>
>> #
>> # SOC (System On Chip) specific Drivers
>> #
>>
>> #
>> # Amlogic SoC drivers
>> #
>>
>> #
>> # Broadcom SoC drivers
>> #
>>
>> #
>> # NXP/Freescale QorIQ SoC drivers
>> #
>>
>> #
>> # i.MX SoC drivers
>> #
>>
>> #
>> # Qualcomm SoC drivers
>> #
>> CONFIG_SOC_TI=y
>>
>> #
>> # Xilinx SoC drivers
>> #
>> CONFIG_XILINX_VCU=m
>> # CONFIG_PM_DEVFREQ is not set
>> CONFIG_EXTCON=y
>>
>> #
>> # Extcon Device Drivers
>> #
>> # CONFIG_EXTCON_ADC_JACK is not set
>> # CONFIG_EXTCON_AXP288 is not set
>> # CONFIG_EXTCON_GPIO is not set
>> # CONFIG_EXTCON_INTEL_INT3496 is not set
>> CONFIG_EXTCON_MAX3355=y
>> # CONFIG_EXTCON_MAX77843 is not set
>> CONFIG_EXTCON_MAX8997=y
>> CONFIG_EXTCON_RT8973A=m
>> CONFIG_EXTCON_SM5502=y
>> CONFIG_EXTCON_USB_GPIO=y
>> # CONFIG_EXTCON_USBC_CROS_EC is not set
>> # CONFIG_MEMORY is not set
>> CONFIG_IIO=y
>> CONFIG_IIO_BUFFER=y
>> CONFIG_IIO_BUFFER_CB=y
>> CONFIG_IIO_BUFFER_HW_CONSUMER=y
>> CONFIG_IIO_KFIFO_BUF=y
>> CONFIG_IIO_TRIGGERED_BUFFER=y
>> CONFIG_IIO_CONFIGFS=m
>> CONFIG_IIO_TRIGGER=y
>> CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
>> CONFIG_IIO_SW_DEVICE=m
>> CONFIG_IIO_SW_TRIGGER=m
>>
>> #
>> # Accelerometers
>> #
>> CONFIG_ADXL345=y
>> CONFIG_ADXL345_I2C=y
>> CONFIG_ADXL372=m
>> CONFIG_ADXL372_I2C=m
>> CONFIG_BMA180=y
>> CONFIG_BMC150_ACCEL=y
>> CONFIG_BMC150_ACCEL_I2C=y
>> # CONFIG_DA280 is not set
>> CONFIG_DA311=m
>> CONFIG_DMARD06=y
>> CONFIG_DMARD09=m
>> # CONFIG_DMARD10 is not set
>> # CONFIG_IIO_CROS_EC_ACCEL_LEGACY is not set
>> CONFIG_IIO_ST_ACCEL_3AXIS=m
>> CONFIG_IIO_ST_ACCEL_I2C_3AXIS=m
>> CONFIG_KXSD9=y
>> CONFIG_KXSD9_I2C=y
>> CONFIG_KXCJK1013=y
>> CONFIG_MC3230=m
>> CONFIG_MMA7455=y
>> CONFIG_MMA7455_I2C=y
>> # CONFIG_MMA7660 is not set
>> CONFIG_MMA8452=m
>> CONFIG_MMA9551_CORE=m
>> # CONFIG_MMA9551 is not set
>> CONFIG_MMA9553=m
>> # CONFIG_MXC4005 is not set
>> # CONFIG_MXC6255 is not set
>> CONFIG_STK8312=y
>> # CONFIG_STK8BA50 is not set
>>
>> #
>> # Analog to digital converters
>> #
>> # CONFIG_AD7291 is not set
>> # CONFIG_AD799X is not set
>> CONFIG_AXP20X_ADC=y
>> CONFIG_AXP288_ADC=y
>> CONFIG_CC10001_ADC=m
>> # CONFIG_DA9150_GPADC is not set
>> CONFIG_ENVELOPE_DETECTOR=y
>> # CONFIG_HX711 is not set
>> # CONFIG_INA2XX_ADC is not set
>> CONFIG_LP8788_ADC=m
>> CONFIG_LTC2471=m
>> # CONFIG_LTC2485 is not set
>> # CONFIG_LTC2497 is not set
>> # CONFIG_MAX1363 is not set
>> # CONFIG_MAX9611 is not set
>> CONFIG_MCP3422=m
>> CONFIG_MEN_Z188_ADC=m
>> # CONFIG_NAU7802 is not set
>> # CONFIG_SD_ADC_MODULATOR is not set
>> CONFIG_TI_ADC081C=m
>> CONFIG_TI_ADS1015=y
>> # CONFIG_VF610_ADC is not set
>>
>> #
>> # Analog Front Ends
>> #
>> CONFIG_IIO_RESCALE=y
>>
>> #
>> # Amplifiers
>> #
>>
>> #
>> # Chemical Sensors
>> #
>> # CONFIG_ATLAS_PH_SENSOR is not set
>> CONFIG_BME680=m
>> CONFIG_BME680_I2C=m
>> CONFIG_CCS811=y
>> CONFIG_IAQCORE=m
>> # CONFIG_VZ89X is not set
>> # CONFIG_IIO_CROS_EC_SENSORS_CORE is not set
>>
>> #
>> # Hid Sensor IIO Common
>> #
>> CONFIG_IIO_MS_SENSORS_I2C=m
>>
>> #
>> # SSP Sensor Common
>> #
>> CONFIG_IIO_ST_SENSORS_I2C=y
>> CONFIG_IIO_ST_SENSORS_CORE=y
>>
>> #
>> # Counters
>> #
>>
>> #
>> # Digital to analog converters
>> #
>> # CONFIG_AD5064 is not set
>> CONFIG_AD5380=y
>> CONFIG_AD5446=y
>> CONFIG_AD5592R_BASE=m
>> CONFIG_AD5593R=m
>> CONFIG_AD5686=y
>> CONFIG_AD5696_I2C=y
>> CONFIG_DPOT_DAC=m
>> CONFIG_DS4424=m
>> CONFIG_M62332=y
>> # CONFIG_MAX517 is not set
>> # CONFIG_MAX5821 is not set
>> # CONFIG_MCP4725 is not set
>> CONFIG_TI_DAC5571=y
>> CONFIG_VF610_DAC=y
>>
>> #
>> # IIO dummy driver
>> #
>> CONFIG_IIO_SIMPLE_DUMMY=m
>> # CONFIG_IIO_SIMPLE_DUMMY_EVENTS is not set
>> # CONFIG_IIO_SIMPLE_DUMMY_BUFFER is not set
>>
>> #
>> # Frequency Synthesizers DDS/PLL
>> #
>>
>> #
>> # Clock Generator/Distribution
>> #
>>
>> #
>> # Phase-Locked Loop (PLL) frequency synthesizers
>> #
>>
>> #
>> # Digital gyroscope sensors
>> #
>> CONFIG_BMG160=m
>> CONFIG_BMG160_I2C=m
>> # CONFIG_MPU3050_I2C is not set
>> # CONFIG_IIO_ST_GYRO_3AXIS is not set
>> CONFIG_ITG3200=m
>>
>> #
>> # Health Sensors
>> #
>>
>> #
>> # Heart Rate Monitors
>> #
>> CONFIG_AFE4404=y
>> CONFIG_MAX30100=m
>> CONFIG_MAX30102=y
>>
>> #
>> # Humidity sensors
>> #
>> CONFIG_AM2315=y
>> CONFIG_DHT11=m
>> # CONFIG_HDC100X is not set
>> CONFIG_HTS221=y
>> CONFIG_HTS221_I2C=y
>> # CONFIG_HTU21 is not set
>> CONFIG_SI7005=m
>> CONFIG_SI7020=m
>>
>> #
>> # Inertial measurement units
>> #
>> # CONFIG_BMI160_I2C is not set
>> CONFIG_KMX61=y
>> CONFIG_INV_MPU6050_IIO=m
>> CONFIG_INV_MPU6050_I2C=m
>> CONFIG_IIO_ST_LSM6DSX=m
>> CONFIG_IIO_ST_LSM6DSX_I2C=m
>>
>> #
>> # Light sensors
>> #
>> # CONFIG_ACPI_ALS is not set
>> # CONFIG_ADJD_S311 is not set
>> # CONFIG_AL3320A is not set
>> CONFIG_APDS9300=m
>> CONFIG_APDS9960=y
>> # CONFIG_BH1750 is not set
>> CONFIG_BH1780=m
>> CONFIG_CM32181=m
>> CONFIG_CM3232=m
>> CONFIG_CM3323=m
>> # CONFIG_CM3605 is not set
>> CONFIG_CM36651=y
>> CONFIG_GP2AP020A00F=y
>> CONFIG_SENSORS_ISL29018=y
>> CONFIG_SENSORS_ISL29028=m
>> CONFIG_ISL29125=m
>> CONFIG_JSA1212=y
>> CONFIG_RPR0521=y
>> # CONFIG_LTR501 is not set
>> # CONFIG_LV0104CS is not set
>> CONFIG_MAX44000=y
>> CONFIG_OPT3001=y
>> CONFIG_PA12203001=m
>> # CONFIG_SI1133 is not set
>> # CONFIG_SI1145 is not set
>> # CONFIG_STK3310 is not set
>> CONFIG_ST_UVIS25=y
>> CONFIG_ST_UVIS25_I2C=y
>> CONFIG_TCS3414=y
>> CONFIG_TCS3472=y
>> CONFIG_SENSORS_TSL2563=m
>> CONFIG_TSL2583=m
>> # CONFIG_TSL2772 is not set
>> # CONFIG_TSL4531 is not set
>> CONFIG_US5182D=m
>> CONFIG_VCNL4000=m
>> CONFIG_VCNL4035=m
>> # CONFIG_VEML6070 is not set
>> CONFIG_VL6180=y
>> CONFIG_ZOPT2201=y
>>
>> #
>> # Magnetometer sensors
>> #
>> # CONFIG_AK8974 is not set
>> CONFIG_AK8975=y
>> CONFIG_AK09911=y
>> CONFIG_BMC150_MAGN=y
>> CONFIG_BMC150_MAGN_I2C=y
>> CONFIG_MAG3110=m
>> CONFIG_MMC35240=y
>> # CONFIG_IIO_ST_MAGN_3AXIS is not set
>> CONFIG_SENSORS_HMC5843=m
>> CONFIG_SENSORS_HMC5843_I2C=m
>> # CONFIG_SENSORS_RM3100_I2C is not set
>>
>> #
>> # Multiplexers
>> #
>> CONFIG_IIO_MUX=m
>>
>> #
>> # Inclinometer sensors
>> #
>>
>> #
>> # Triggers - standalone
>> #
>> CONFIG_IIO_HRTIMER_TRIGGER=m
>> CONFIG_IIO_INTERRUPT_TRIGGER=m
>> CONFIG_IIO_TIGHTLOOP_TRIGGER=m
>> CONFIG_IIO_SYSFS_TRIGGER=y
>>
>> #
>> # Digital potentiometers
>> #
>> CONFIG_AD5272=y
>> # CONFIG_DS1803 is not set
>> # CONFIG_MCP4018 is not set
>> CONFIG_MCP4531=m
>> CONFIG_TPL0102=y
>>
>> #
>> # Digital potentiostats
>> #
>> CONFIG_LMP91000=y
>>
>> #
>> # Pressure sensors
>> #
>> CONFIG_ABP060MG=m
>> CONFIG_BMP280=m
>> CONFIG_BMP280_I2C=m
>> CONFIG_HP03=m
>> CONFIG_MPL115=m
>> CONFIG_MPL115_I2C=m
>> CONFIG_MPL3115=m
>> CONFIG_MS5611=m
>> CONFIG_MS5611_I2C=m
>> # CONFIG_MS5637 is not set
>> CONFIG_IIO_ST_PRESS=y
>> CONFIG_IIO_ST_PRESS_I2C=y
>> # CONFIG_T5403 is not set
>> # CONFIG_HP206C is not set
>> # CONFIG_ZPA2326 is not set
>>
>> #
>> # Lightning sensors
>> #
>>
>> #
>> # Proximity and distance sensors
>> #
>> CONFIG_ISL29501=m
>> # CONFIG_LIDAR_LITE_V2 is not set
>> CONFIG_RFD77402=m
>> CONFIG_SRF04=m
>> CONFIG_SX9500=y
>> # CONFIG_SRF08 is not set
>> CONFIG_VL53L0X_I2C=m
>>
>> #
>> # Resolver to digital converters
>> #
>>
>> #
>> # Temperature sensors
>> #
>> CONFIG_MLX90614=y
>> # CONFIG_MLX90632 is not set
>> CONFIG_TMP006=m
>> CONFIG_TMP007=y
>> CONFIG_TSYS01=m
>> # CONFIG_TSYS02D is not set
>> CONFIG_NTB=y
>> # CONFIG_NTB_AMD is not set
>> CONFIG_NTB_IDT=m
>> CONFIG_NTB_INTEL=y
>> CONFIG_NTB_SWITCHTEC=y
>> # CONFIG_NTB_PINGPONG is not set
>> CONFIG_NTB_TOOL=y
>> # CONFIG_NTB_PERF is not set
>> # CONFIG_NTB_TRANSPORT is not set
>> CONFIG_VME_BUS=y
>>
>> #
>> # VME Bridge Drivers
>> #
>> CONFIG_VME_CA91CX42=y
>> CONFIG_VME_TSI148=m
>> # CONFIG_VME_FAKE is not set
>>
>> #
>> # VME Board Drivers
>> #
>> # CONFIG_VMIVME_7805 is not set
>>
>> #
>> # VME Device Drivers
>> #
>> # CONFIG_VME_USER is not set
>> CONFIG_PWM=y
>> CONFIG_PWM_SYSFS=y
>> # CONFIG_PWM_CROS_EC is not set
>> CONFIG_PWM_FSL_FTM=y
>> CONFIG_PWM_LP3943=m
>> CONFIG_PWM_LPSS=y
>> CONFIG_PWM_LPSS_PCI=y
>> # CONFIG_PWM_LPSS_PLATFORM is not set
>> # CONFIG_PWM_PCA9685 is not set
>>
>> #
>> # IRQ chip support
>> #
>> CONFIG_IRQCHIP=y
>> CONFIG_ARM_GIC_MAX_NR=1
>> CONFIG_MADERA_IRQ=y
>> CONFIG_IPACK_BUS=m
>> # CONFIG_BOARD_TPCI200 is not set
>> # CONFIG_SERIAL_IPOCTAL is not set
>> CONFIG_RESET_CONTROLLER=y
>> CONFIG_RESET_TI_SYSCON=y
>> # CONFIG_FMC is not set
>>
>> #
>> # PHY Subsystem
>> #
>> CONFIG_GENERIC_PHY=y
>> # CONFIG_BCM_KONA_USB2_PHY is not set
>> CONFIG_PHY_CADENCE_DP=y
>> # CONFIG_PHY_CADENCE_SIERRA is not set
>> # CONFIG_PHY_FSL_IMX8MQ_USB is not set
>> CONFIG_PHY_PXA_28NM_HSIC=y
>> # CONFIG_PHY_PXA_28NM_USB2 is not set
>> # CONFIG_PHY_CPCAP_USB is not set
>> # CONFIG_PHY_MAPPHONE_MDM6600 is not set
>> CONFIG_PHY_OCELOT_SERDES=m
>> # CONFIG_POWERCAP is not set
>> CONFIG_MCB=m
>> CONFIG_MCB_PCI=m
>> CONFIG_MCB_LPC=m
>>
>> #
>> # Performance monitor support
>> #
>> CONFIG_RAS=y
>> CONFIG_THUNDERBOLT=m
>>
>> #
>> # Android
>> #
>> CONFIG_ANDROID=y
>> # CONFIG_ANDROID_BINDER_IPC is not set
>> # CONFIG_DAX is not set
>> CONFIG_NVMEM=y
>>
>> #
>> # HW tracing support
>> #
>> CONFIG_STM=y
>> # CONFIG_STM_PROTO_BASIC is not set
>> # CONFIG_STM_PROTO_SYS_T is not set
>> # CONFIG_STM_DUMMY is not set
>> # CONFIG_STM_SOURCE_CONSOLE is not set
>> CONFIG_STM_SOURCE_HEARTBEAT=m
>> CONFIG_INTEL_TH=y
>> # CONFIG_INTEL_TH_PCI is not set
>> # CONFIG_INTEL_TH_ACPI is not set
>> # CONFIG_INTEL_TH_GTH is not set
>> # CONFIG_INTEL_TH_STH is not set
>> # CONFIG_INTEL_TH_MSU is not set
>> # CONFIG_INTEL_TH_PTI is not set
>> CONFIG_INTEL_TH_DEBUG=y
>> CONFIG_FPGA=m
>> CONFIG_ALTERA_PR_IP_CORE=m
>> # CONFIG_ALTERA_PR_IP_CORE_PLAT is not set
>> # CONFIG_FPGA_MGR_ALTERA_CVP is not set
>> CONFIG_FPGA_BRIDGE=m
>> # CONFIG_XILINX_PR_DECOUPLER is not set
>> CONFIG_FPGA_REGION=m
>> # CONFIG_OF_FPGA_REGION is not set
>> CONFIG_FPGA_DFL=m
>> CONFIG_FPGA_DFL_FME=m
>> CONFIG_FPGA_DFL_FME_MGR=m
>> CONFIG_FPGA_DFL_FME_BRIDGE=m
>> # CONFIG_FPGA_DFL_FME_REGION is not set
>> CONFIG_FPGA_DFL_AFU=m
>> CONFIG_FPGA_DFL_PCI=m
>> CONFIG_FSI=y
>> CONFIG_FSI_NEW_DEV_NODE=y
>> CONFIG_FSI_MASTER_GPIO=y
>> CONFIG_FSI_MASTER_HUB=y
>> CONFIG_FSI_SCOM=m
>> CONFIG_FSI_SBEFIFO=m
>> CONFIG_FSI_OCC=m
>> CONFIG_MULTIPLEXER=m
>>
>> #
>> # Multiplexer drivers
>> #
>> CONFIG_MUX_ADG792A=m
>> # CONFIG_MUX_GPIO is not set
>> # CONFIG_MUX_MMIO is not set
>> # CONFIG_UNISYS_VISORBUS is not set
>> CONFIG_SIOX=y
>> CONFIG_SIOX_BUS_GPIO=m
>> CONFIG_SLIMBUS=m
>> # CONFIG_SLIM_QCOM_CTRL is not set
>>
>> #
>> # File systems
>> #
>> CONFIG_DCACHE_WORD_ACCESS=y
>> CONFIG_FS_POSIX_ACL=y
>> CONFIG_EXPORTFS=y
>> # CONFIG_EXPORTFS_BLOCK_OPS is not set
>> CONFIG_FILE_LOCKING=y
>> CONFIG_MANDATORY_FILE_LOCKING=y
>> CONFIG_FS_ENCRYPTION=y
>> CONFIG_FSNOTIFY=y
>> CONFIG_DNOTIFY=y
>> CONFIG_INOTIFY_USER=y
>> # CONFIG_FANOTIFY is not set
>> CONFIG_QUOTA=y
>> # CONFIG_QUOTA_NETLINK_INTERFACE is not set
>> # CONFIG_PRINT_QUOTA_WARNING is not set
>> # CONFIG_QUOTA_DEBUG is not set
>> CONFIG_QUOTA_TREE=m
>> CONFIG_QFMT_V1=y
>> CONFIG_QFMT_V2=m
>> CONFIG_QUOTACTL=y
>> CONFIG_AUTOFS4_FS=m
>> CONFIG_AUTOFS_FS=m
>> # CONFIG_FUSE_FS is not set
>> CONFIG_OVERLAY_FS=y
>> CONFIG_OVERLAY_FS_REDIRECT_DIR=y
>> # CONFIG_OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW is not set
>> CONFIG_OVERLAY_FS_INDEX=y
>> # CONFIG_OVERLAY_FS_XINO_AUTO is not set
>> CONFIG_OVERLAY_FS_METACOPY=y
>>
>> #
>> # Caches
>> #
>> # CONFIG_FSCACHE is not set
>>
>> #
>> # Pseudo filesystems
>> #
>> CONFIG_PROC_FS=y
>> # CONFIG_PROC_KCORE is not set
>> # CONFIG_PROC_VMCORE is not set
>> CONFIG_PROC_SYSCTL=y
>> # CONFIG_PROC_PAGE_MONITOR is not set
>> CONFIG_PROC_CHILDREN=y
>> CONFIG_KERNFS=y
>> CONFIG_SYSFS=y
>> CONFIG_TMPFS=y
>> CONFIG_TMPFS_POSIX_ACL=y
>> CONFIG_TMPFS_XATTR=y
>> CONFIG_HUGETLBFS=y
>> CONFIG_HUGETLB_PAGE=y
>> CONFIG_MEMFD_CREATE=y
>> CONFIG_ARCH_HAS_GIGANTIC_PAGE=y
>> CONFIG_CONFIGFS_FS=y
>> CONFIG_MISC_FILESYSTEMS=y
>> CONFIG_ORANGEFS_FS=y
>> # CONFIG_ECRYPT_FS is not set
>> CONFIG_JFFS2_FS=m
>> CONFIG_JFFS2_FS_DEBUG=0
>> CONFIG_JFFS2_FS_WRITEBUFFER=y
>> # CONFIG_JFFS2_FS_WBUF_VERIFY is not set
>> CONFIG_JFFS2_SUMMARY=y
>> # CONFIG_JFFS2_FS_XATTR is not set
>> CONFIG_JFFS2_COMPRESSION_OPTIONS=y
>> CONFIG_JFFS2_ZLIB=y
>> # CONFIG_JFFS2_LZO is not set
>> CONFIG_JFFS2_RTIME=y
>> # CONFIG_JFFS2_RUBIN is not set
>> # CONFIG_JFFS2_CMODE_NONE is not set
>> CONFIG_JFFS2_CMODE_PRIORITY=y
>> # CONFIG_JFFS2_CMODE_SIZE is not set
>> # CONFIG_JFFS2_CMODE_FAVOURLZO is not set
>> # CONFIG_UBIFS_FS is not set
>> CONFIG_CRAMFS=m
>> CONFIG_CRAMFS_MTD=y
>> CONFIG_ROMFS_FS=m
>> CONFIG_ROMFS_BACKED_BY_MTD=y
>> CONFIG_ROMFS_ON_MTD=y
>> # CONFIG_PSTORE is not set
>> # CONFIG_NETWORK_FILESYSTEMS is not set
>> CONFIG_NLS=y
>> CONFIG_NLS_DEFAULT="iso8859-1"
>> CONFIG_NLS_CODEPAGE_437=y
>> CONFIG_NLS_CODEPAGE_737=y
>> CONFIG_NLS_CODEPAGE_775=m
>> CONFIG_NLS_CODEPAGE_850=y
>> # CONFIG_NLS_CODEPAGE_852 is not set
>> CONFIG_NLS_CODEPAGE_855=y
>> CONFIG_NLS_CODEPAGE_857=y
>> CONFIG_NLS_CODEPAGE_860=m
>> CONFIG_NLS_CODEPAGE_861=m
>> # CONFIG_NLS_CODEPAGE_862 is not set
>> # CONFIG_NLS_CODEPAGE_863 is not set
>> # CONFIG_NLS_CODEPAGE_864 is not set
>> CONFIG_NLS_CODEPAGE_865=y
>> # CONFIG_NLS_CODEPAGE_866 is not set
>> CONFIG_NLS_CODEPAGE_869=m
>> # CONFIG_NLS_CODEPAGE_936 is not set
>> CONFIG_NLS_CODEPAGE_950=m
>> # CONFIG_NLS_CODEPAGE_932 is not set
>> # CONFIG_NLS_CODEPAGE_949 is not set
>> # CONFIG_NLS_CODEPAGE_874 is not set
>> CONFIG_NLS_ISO8859_8=m
>> # CONFIG_NLS_CODEPAGE_1250 is not set
>> CONFIG_NLS_CODEPAGE_1251=y
>> CONFIG_NLS_ASCII=y
>> CONFIG_NLS_ISO8859_1=m
>> CONFIG_NLS_ISO8859_2=m
>> CONFIG_NLS_ISO8859_3=y
>> CONFIG_NLS_ISO8859_4=y
>> CONFIG_NLS_ISO8859_5=m
>> # CONFIG_NLS_ISO8859_6 is not set
>> # CONFIG_NLS_ISO8859_7 is not set
>> # CONFIG_NLS_ISO8859_9 is not set
>> # CONFIG_NLS_ISO8859_13 is not set
>> CONFIG_NLS_ISO8859_14=y
>> CONFIG_NLS_ISO8859_15=m
>> CONFIG_NLS_KOI8_R=m
>> CONFIG_NLS_KOI8_U=y
>> CONFIG_NLS_MAC_ROMAN=y
>> CONFIG_NLS_MAC_CELTIC=m
>> CONFIG_NLS_MAC_CENTEURO=y
>> CONFIG_NLS_MAC_CROATIAN=y
>> CONFIG_NLS_MAC_CYRILLIC=m
>> # CONFIG_NLS_MAC_GAELIC is not set
>> # CONFIG_NLS_MAC_GREEK is not set
>> CONFIG_NLS_MAC_ICELAND=m
>> CONFIG_NLS_MAC_INUIT=m
>> CONFIG_NLS_MAC_ROMANIAN=m
>> CONFIG_NLS_MAC_TURKISH=m
>> CONFIG_NLS_UTF8=m
>> # CONFIG_DLM is not set
>>
>> #
>> # Security options
>> #
>> CONFIG_KEYS=y
>> CONFIG_PERSISTENT_KEYRINGS=y
>> CONFIG_BIG_KEYS=y
>> # CONFIG_TRUSTED_KEYS is not set
>> CONFIG_ENCRYPTED_KEYS=y
>> CONFIG_KEY_DH_OPERATIONS=y
>> CONFIG_SECURITY_DMESG_RESTRICT=y
>> # CONFIG_SECURITY is not set
>> CONFIG_SECURITYFS=y
>> CONFIG_PAGE_TABLE_ISOLATION=y
>> # CONFIG_FORTIFY_SOURCE is not set
>> # CONFIG_STATIC_USERMODEHELPER is not set
>> CONFIG_DEFAULT_SECURITY_DAC=y
>> CONFIG_DEFAULT_SECURITY=""
>> CONFIG_CRYPTO=y
>>
>> #
>> # Crypto core or helper
>> #
>> CONFIG_CRYPTO_ALGAPI=y
>> CONFIG_CRYPTO_ALGAPI2=y
>> CONFIG_CRYPTO_AEAD=y
>> CONFIG_CRYPTO_AEAD2=y
>> CONFIG_CRYPTO_BLKCIPHER=y
>> CONFIG_CRYPTO_BLKCIPHER2=y
>> CONFIG_CRYPTO_HASH=y
>> CONFIG_CRYPTO_HASH2=y
>> CONFIG_CRYPTO_RNG=y
>> CONFIG_CRYPTO_RNG2=y
>> CONFIG_CRYPTO_RNG_DEFAULT=y
>> CONFIG_CRYPTO_AKCIPHER2=y
>> CONFIG_CRYPTO_AKCIPHER=m
>> CONFIG_CRYPTO_KPP2=y
>> CONFIG_CRYPTO_KPP=y
>> CONFIG_CRYPTO_ACOMP2=y
>> # CONFIG_CRYPTO_RSA is not set
>> CONFIG_CRYPTO_DH=y
>> CONFIG_CRYPTO_ECDH=y
>> CONFIG_CRYPTO_MANAGER=y
>> CONFIG_CRYPTO_MANAGER2=y
>> # CONFIG_CRYPTO_USER is not set
>> CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
>> CONFIG_CRYPTO_GF128MUL=y
>> CONFIG_CRYPTO_NULL=y
>> CONFIG_CRYPTO_NULL2=y
>> CONFIG_CRYPTO_PCRYPT=y
>> CONFIG_CRYPTO_WORKQUEUE=y
>> CONFIG_CRYPTO_CRYPTD=y
>> CONFIG_CRYPTO_AUTHENC=y
>> CONFIG_CRYPTO_TEST=m
>> CONFIG_CRYPTO_SIMD=y
>> CONFIG_CRYPTO_GLUE_HELPER_X86=y
>>
>> #
>> # Authenticated Encryption with Associated Data
>> #
>> CONFIG_CRYPTO_CCM=y
>> CONFIG_CRYPTO_GCM=y
>> # CONFIG_CRYPTO_CHACHA20POLY1305 is not set
>> # CONFIG_CRYPTO_AEGIS128 is not set
>> CONFIG_CRYPTO_AEGIS128L=y
>> # CONFIG_CRYPTO_AEGIS256 is not set
>> CONFIG_CRYPTO_AEGIS128_AESNI_SSE2=m
>> # CONFIG_CRYPTO_AEGIS128L_AESNI_SSE2 is not set
>> CONFIG_CRYPTO_AEGIS256_AESNI_SSE2=m
>> # CONFIG_CRYPTO_MORUS640 is not set
>> # CONFIG_CRYPTO_MORUS640_SSE2 is not set
>> CONFIG_CRYPTO_MORUS1280=m
>> CONFIG_CRYPTO_MORUS1280_GLUE=m
>> # CONFIG_CRYPTO_MORUS1280_SSE2 is not set
>> CONFIG_CRYPTO_MORUS1280_AVX2=m
>> CONFIG_CRYPTO_SEQIV=y
>> # CONFIG_CRYPTO_ECHAINIV is not set
>>
>> #
>> # Block modes
>> #
>> CONFIG_CRYPTO_CBC=y
>> # CONFIG_CRYPTO_CFB is not set
>> CONFIG_CRYPTO_CTR=y
>> CONFIG_CRYPTO_CTS=y
>> CONFIG_CRYPTO_ECB=y
>> # CONFIG_CRYPTO_LRW is not set
>> # CONFIG_CRYPTO_OFB is not set
>> CONFIG_CRYPTO_PCBC=m
>> CONFIG_CRYPTO_XTS=y
>> CONFIG_CRYPTO_KEYWRAP=y
>> CONFIG_CRYPTO_NHPOLY1305=m
>> CONFIG_CRYPTO_NHPOLY1305_SSE2=m
>> CONFIG_CRYPTO_NHPOLY1305_AVX2=m
>> # CONFIG_CRYPTO_ADIANTUM is not set
>>
>> #
>> # Hash modes
>> #
>> CONFIG_CRYPTO_CMAC=y
>> CONFIG_CRYPTO_HMAC=y
>> CONFIG_CRYPTO_XCBC=y
>> CONFIG_CRYPTO_VMAC=y
>>
>> #
>> # Digest
>> #
>> CONFIG_CRYPTO_CRC32C=m
>> CONFIG_CRYPTO_CRC32C_INTEL=y
>> CONFIG_CRYPTO_CRC32=m
>> CONFIG_CRYPTO_CRC32_PCLMUL=m
>> CONFIG_CRYPTO_CRCT10DIF=y
>> CONFIG_CRYPTO_CRCT10DIF_PCLMUL=m
>> CONFIG_CRYPTO_GHASH=y
>> CONFIG_CRYPTO_POLY1305=m
>> CONFIG_CRYPTO_POLY1305_X86_64=m
>> CONFIG_CRYPTO_MD4=y
>> # CONFIG_CRYPTO_MD5 is not set
>> CONFIG_CRYPTO_MICHAEL_MIC=y
>> # CONFIG_CRYPTO_RMD128 is not set
>> CONFIG_CRYPTO_RMD160=y
>> CONFIG_CRYPTO_RMD256=y
>> # CONFIG_CRYPTO_RMD320 is not set
>> CONFIG_CRYPTO_SHA1=m
>> CONFIG_CRYPTO_SHA1_SSSE3=m
>> CONFIG_CRYPTO_SHA256_SSSE3=m
>> # CONFIG_CRYPTO_SHA512_SSSE3 is not set
>> CONFIG_CRYPTO_SHA256=y
>> CONFIG_CRYPTO_SHA512=y
>> CONFIG_CRYPTO_SHA3=m
>> CONFIG_CRYPTO_SM3=m
>> # CONFIG_CRYPTO_STREEBOG is not set
>> # CONFIG_CRYPTO_TGR192 is not set
>> # CONFIG_CRYPTO_WP512 is not set
>> CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y
>>
>> #
>> # Ciphers
>> #
>> CONFIG_CRYPTO_AES=y
>> # CONFIG_CRYPTO_AES_TI is not set
>> CONFIG_CRYPTO_AES_X86_64=y
>> CONFIG_CRYPTO_AES_NI_INTEL=y
>> CONFIG_CRYPTO_ANUBIS=m
>> CONFIG_CRYPTO_ARC4=m
>> # CONFIG_CRYPTO_BLOWFISH is not set
>> CONFIG_CRYPTO_BLOWFISH_COMMON=y
>> CONFIG_CRYPTO_BLOWFISH_X86_64=y
>> # CONFIG_CRYPTO_CAMELLIA is not set
>> CONFIG_CRYPTO_CAMELLIA_X86_64=m
>> CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=m
>> CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=m
>> CONFIG_CRYPTO_CAST_COMMON=y
>> CONFIG_CRYPTO_CAST5=y
>> CONFIG_CRYPTO_CAST5_AVX_X86_64=y
>> CONFIG_CRYPTO_CAST6=y
>> # CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
>> CONFIG_CRYPTO_DES=y
>> CONFIG_CRYPTO_DES3_EDE_X86_64=y
>> # CONFIG_CRYPTO_FCRYPT is not set
>> # CONFIG_CRYPTO_KHAZAD is not set
>> # CONFIG_CRYPTO_SALSA20 is not set
>> CONFIG_CRYPTO_CHACHA20=m
>> # CONFIG_CRYPTO_CHACHA20_X86_64 is not set
>> # CONFIG_CRYPTO_SEED is not set
>> CONFIG_CRYPTO_SERPENT=y
>> CONFIG_CRYPTO_SERPENT_SSE2_X86_64=m
>> CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
>> # CONFIG_CRYPTO_SERPENT_AVX2_X86_64 is not set
>> CONFIG_CRYPTO_SM4=m
>> CONFIG_CRYPTO_TEA=y
>> CONFIG_CRYPTO_TWOFISH=m
>> CONFIG_CRYPTO_TWOFISH_COMMON=y
>> CONFIG_CRYPTO_TWOFISH_X86_64=y
>> CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
>> CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y
>>
>> #
>> # Compression
>> #
>> # CONFIG_CRYPTO_DEFLATE is not set
>> CONFIG_CRYPTO_LZO=m
>> CONFIG_CRYPTO_842=m
>> # CONFIG_CRYPTO_LZ4 is not set
>> CONFIG_CRYPTO_LZ4HC=m
>> CONFIG_CRYPTO_ZSTD=y
>>
>> #
>> # Random Number Generation
>> #
>> CONFIG_CRYPTO_ANSI_CPRNG=m
>> CONFIG_CRYPTO_DRBG_MENU=y
>> CONFIG_CRYPTO_DRBG_HMAC=y
>> CONFIG_CRYPTO_DRBG_HASH=y
>> # CONFIG_CRYPTO_DRBG_CTR is not set
>> CONFIG_CRYPTO_DRBG=y
>> CONFIG_CRYPTO_JITTERENTROPY=y
>> CONFIG_CRYPTO_USER_API=y
>> CONFIG_CRYPTO_USER_API_HASH=y
>> # CONFIG_CRYPTO_USER_API_SKCIPHER is not set
>> CONFIG_CRYPTO_USER_API_RNG=y
>> # CONFIG_CRYPTO_USER_API_AEAD is not set
>> CONFIG_CRYPTO_HASH_INFO=y
>> # CONFIG_CRYPTO_HW is not set
>> CONFIG_ASYMMETRIC_KEY_TYPE=y
>> CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=m
>> CONFIG_X509_CERTIFICATE_PARSER=m
>> CONFIG_PKCS8_PRIVATE_KEY_PARSER=m
>> CONFIG_PKCS7_MESSAGE_PARSER=m
>>
>> #
>> # Certificates for signature checking
>> #
>> CONFIG_SYSTEM_TRUSTED_KEYRING=y
>> CONFIG_SYSTEM_TRUSTED_KEYS=""
>> CONFIG_SYSTEM_EXTRA_CERTIFICATE=y
>> CONFIG_SYSTEM_EXTRA_CERTIFICATE_SIZE=4096
>> # CONFIG_SECONDARY_TRUSTED_KEYRING is not set
>> # CONFIG_SYSTEM_BLACKLIST_KEYRING is not set
>> CONFIG_BINARY_PRINTF=y
>>
>> #
>> # Library routines
>> #
>> CONFIG_BITREVERSE=y
>> CONFIG_RATIONAL=y
>> CONFIG_GENERIC_STRNCPY_FROM_USER=y
>> CONFIG_GENERIC_STRNLEN_USER=y
>> CONFIG_GENERIC_NET_UTILS=y
>> CONFIG_GENERIC_FIND_FIRST_BIT=y
>> CONFIG_GENERIC_PCI_IOMAP=y
>> CONFIG_GENERIC_IOMAP=y
>> CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
>> CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
>> CONFIG_CRC_CCITT=y
>> CONFIG_CRC16=y
>> CONFIG_CRC_T10DIF=y
>> CONFIG_CRC_ITU_T=m
>> CONFIG_CRC32=y
>> CONFIG_CRC32_SELFTEST=m
>> # CONFIG_CRC32_SLICEBY8 is not set
>> # CONFIG_CRC32_SLICEBY4 is not set
>> CONFIG_CRC32_SARWATE=y
>> # CONFIG_CRC32_BIT is not set
>> CONFIG_CRC64=y
>> CONFIG_CRC4=y
>> CONFIG_CRC7=m
>> CONFIG_LIBCRC32C=m
>> CONFIG_CRC8=y
>> CONFIG_XXHASH=y
>> # CONFIG_RANDOM32_SELFTEST is not set
>> CONFIG_842_COMPRESS=m
>> CONFIG_842_DECOMPRESS=m
>> CONFIG_ZLIB_INFLATE=y
>> CONFIG_ZLIB_DEFLATE=m
>> CONFIG_LZO_COMPRESS=m
>> CONFIG_LZO_DECOMPRESS=m
>> CONFIG_LZ4HC_COMPRESS=m
>> CONFIG_LZ4_DECOMPRESS=m
>> CONFIG_ZSTD_COMPRESS=y
>> CONFIG_ZSTD_DECOMPRESS=y
>> CONFIG_XZ_DEC=y
>> CONFIG_XZ_DEC_X86=y
>> CONFIG_XZ_DEC_POWERPC=y
>> # CONFIG_XZ_DEC_IA64 is not set
>> # CONFIG_XZ_DEC_ARM is not set
>> CONFIG_XZ_DEC_ARMTHUMB=y
>> CONFIG_XZ_DEC_SPARC=y
>> CONFIG_XZ_DEC_BCJ=y
>> # CONFIG_XZ_DEC_TEST is not set
>> CONFIG_DECOMPRESS_GZIP=y
>> CONFIG_DECOMPRESS_XZ=y
>> CONFIG_GENERIC_ALLOCATOR=y
>> CONFIG_BCH=m
>> CONFIG_BCH_CONST_PARAMS=y
>> CONFIG_TEXTSEARCH=y
>> CONFIG_TEXTSEARCH_KMP=y
>> CONFIG_TEXTSEARCH_BM=y
>> CONFIG_TEXTSEARCH_FSM=y
>> CONFIG_ASSOCIATIVE_ARRAY=y
>> CONFIG_HAS_IOMEM=y
>> CONFIG_HAS_IOPORT_MAP=y
>> CONFIG_HAS_DMA=y
>> CONFIG_NEED_SG_DMA_LENGTH=y
>> CONFIG_NEED_DMA_MAP_STATE=y
>> CONFIG_ARCH_DMA_ADDR_T_64BIT=y
>> CONFIG_SWIOTLB=y
>> CONFIG_SGL_ALLOC=y
>> CONFIG_IOMMU_HELPER=y
>> # CONFIG_CPUMASK_OFFSTACK is not set
>> CONFIG_CPU_RMAP=y
>> CONFIG_DQL=y
>> CONFIG_GLOB=y
>> # CONFIG_GLOB_SELFTEST is not set
>> CONFIG_NLATTR=y
>> CONFIG_CLZ_TAB=y
>> # CONFIG_CORDIC is not set
>> # CONFIG_DDR is not set
>> # CONFIG_IRQ_POLL is not set
>> CONFIG_MPILIB=y
>> CONFIG_LIBFDT=y
>> CONFIG_OID_REGISTRY=m
>> CONFIG_ARCH_HAS_PMEM_API=y
>> CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
>> CONFIG_STRING_SELFTEST=y
>>
>> #
>> # Kernel hacking
>> #
>>
>> #
>> # printk and dmesg options
>> #
>> CONFIG_PRINTK_TIME=y
>> CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
>> CONFIG_CONSOLE_LOGLEVEL_QUIET=4
>> CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
>> # CONFIG_BOOT_PRINTK_DELAY is not set
>> # CONFIG_DYNAMIC_DEBUG is not set
>>
>> #
>> # Compile-time checks and compiler options
>> #
>> CONFIG_DEBUG_INFO=y
>> CONFIG_DEBUG_INFO_REDUCED=y
>> # CONFIG_DEBUG_INFO_SPLIT is not set
>> # CONFIG_DEBUG_INFO_DWARF4 is not set
>> # CONFIG_GDB_SCRIPTS is not set
>> # CONFIG_ENABLE_MUST_CHECK is not set
>> CONFIG_FRAME_WARN=2048
>> CONFIG_STRIP_ASM_SYMS=y
>> # CONFIG_READABLE_ASM is not set
>> # CONFIG_UNUSED_SYMBOLS is not set
>> # CONFIG_PAGE_OWNER is not set
>> CONFIG_DEBUG_FS=y
>> CONFIG_HEADERS_CHECK=y
>> # CONFIG_DEBUG_SECTION_MISMATCH is not set
>> # CONFIG_SECTION_MISMATCH_WARN_ONLY is not set
>> CONFIG_STACK_VALIDATION=y
>> # CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
>> CONFIG_MAGIC_SYSRQ=y
>> CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
>> # CONFIG_MAGIC_SYSRQ_SERIAL is not set
>> CONFIG_DEBUG_KERNEL=y
>>
>> #
>> # Memory Debugging
>> #
>> CONFIG_PAGE_EXTENSION=y
>> CONFIG_DEBUG_PAGEALLOC=y
>> # CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT is not set
>> CONFIG_PAGE_POISONING=y
>> CONFIG_PAGE_POISONING_NO_SANITY=y
>> CONFIG_PAGE_POISONING_ZERO=y
>> # CONFIG_DEBUG_PAGE_REF is not set
>> # CONFIG_DEBUG_RODATA_TEST is not set
>> # CONFIG_DEBUG_OBJECTS is not set
>> CONFIG_HAVE_DEBUG_KMEMLEAK=y
>> # CONFIG_DEBUG_KMEMLEAK is not set
>> # CONFIG_DEBUG_STACK_USAGE is not set
>> CONFIG_DEBUG_VM=y
>> # CONFIG_DEBUG_VM_VMACACHE is not set
>> CONFIG_DEBUG_VM_RB=y
>> CONFIG_DEBUG_VM_PGFLAGS=y
>> CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
>> # CONFIG_DEBUG_VIRTUAL is not set
>> # CONFIG_DEBUG_MEMORY_INIT is not set
>> CONFIG_DEBUG_PER_CPU_MAPS=y
>> CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
>> # CONFIG_DEBUG_STACKOVERFLOW is not set
>> CONFIG_HAVE_ARCH_KASAN=y
>> CONFIG_CC_HAS_KASAN_GENERIC=y
>> CONFIG_ARCH_HAS_KCOV=y
>> CONFIG_CC_HAS_SANCOV_TRACE_PC=y
>> # CONFIG_KCOV is not set
>> # CONFIG_DEBUG_SHIRQ is not set
>>
>> #
>> # Debug Lockups and Hangs
>> #
>> CONFIG_LOCKUP_DETECTOR=y
>> CONFIG_SOFTLOCKUP_DETECTOR=y
>> CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC=y
>> CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=1
>> CONFIG_HARDLOCKUP_DETECTOR_PERF=y
>> CONFIG_HARDLOCKUP_CHECK_TIMESTAMP=y
>> CONFIG_HARDLOCKUP_DETECTOR=y
>> CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
>> CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
>> # CONFIG_DETECT_HUNG_TASK is not set
>> # CONFIG_WQ_WATCHDOG is not set
>> # CONFIG_PANIC_ON_OOPS is not set
>> CONFIG_PANIC_ON_OOPS_VALUE=0
>> CONFIG_PANIC_TIMEOUT=0
>> # CONFIG_SCHED_DEBUG is not set
>> CONFIG_SCHED_INFO=y
>> CONFIG_SCHEDSTATS=y
>> # CONFIG_SCHED_STACK_END_CHECK is not set
>> CONFIG_DEBUG_TIMEKEEPING=y
>> CONFIG_DEBUG_PREEMPT=y
>>
>> #
>> # Lock Debugging (spinlocks, mutexes, etc...)
>> #
>> CONFIG_LOCK_DEBUGGING_SUPPORT=y
>> CONFIG_PROVE_LOCKING=y
>> # CONFIG_LOCK_STAT is not set
>> CONFIG_DEBUG_RT_MUTEXES=y
>> CONFIG_DEBUG_SPINLOCK=y
>> CONFIG_DEBUG_MUTEXES=y
>> CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
>> CONFIG_DEBUG_RWSEMS=y
>> CONFIG_DEBUG_LOCK_ALLOC=y
>> CONFIG_LOCKDEP=y
>> CONFIG_DEBUG_LOCKDEP=y
>> CONFIG_DEBUG_ATOMIC_SLEEP=y
>> # CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
>> CONFIG_LOCK_TORTURE_TEST=m
>> CONFIG_WW_MUTEX_SELFTEST=y
>> CONFIG_TRACE_IRQFLAGS=y
>> CONFIG_STACKTRACE=y
>> # CONFIG_WARN_ALL_UNSEEDED_RANDOM is not set
>> # CONFIG_DEBUG_KOBJECT is not set
>> CONFIG_DEBUG_BUGVERBOSE=y
>> # CONFIG_DEBUG_LIST is not set
>> CONFIG_DEBUG_PI_LIST=y
>> # CONFIG_DEBUG_SG is not set
>> # CONFIG_DEBUG_NOTIFIERS is not set
>> # CONFIG_DEBUG_CREDENTIALS is not set
>>
>> #
>> # RCU Debugging
>> #
>> CONFIG_PROVE_RCU=y
>> CONFIG_TORTURE_TEST=m
>> CONFIG_RCU_PERF_TEST=m
>> CONFIG_RCU_TORTURE_TEST=m
>> CONFIG_RCU_CPU_STALL_TIMEOUT=21
>> # CONFIG_RCU_TRACE is not set
>> # CONFIG_RCU_EQS_DEBUG is not set
>> CONFIG_DEBUG_WQ_FORCE_RR_CPU=y
>> CONFIG_CPU_HOTPLUG_STATE_CONTROL=y
>> # CONFIG_NOTIFIER_ERROR_INJECTION is not set
>> CONFIG_FAULT_INJECTION=y
>> CONFIG_FAIL_PAGE_ALLOC=y
>> # CONFIG_FAIL_FUTEX is not set
>> CONFIG_FAULT_INJECTION_DEBUG_FS=y
>> CONFIG_FAIL_MMC_REQUEST=y
>> # CONFIG_LATENCYTOP is not set
>> CONFIG_USER_STACKTRACE_SUPPORT=y
>> CONFIG_NOP_TRACER=y
>> CONFIG_HAVE_FUNCTION_TRACER=y
>> CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
>> CONFIG_HAVE_DYNAMIC_FTRACE=y
>> CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
>> CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
>> CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
>> CONFIG_HAVE_FENTRY=y
>> CONFIG_HAVE_C_RECORDMCOUNT=y
>> CONFIG_TRACE_CLOCK=y
>> CONFIG_RING_BUFFER=y
>> CONFIG_EVENT_TRACING=y
>> CONFIG_CONTEXT_SWITCH_TRACER=y
>> CONFIG_PREEMPTIRQ_TRACEPOINTS=y
>> CONFIG_TRACING=y
>> CONFIG_TRACING_SUPPORT=y
>> # CONFIG_FTRACE is not set
>> # CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
>> # CONFIG_DMA_API_DEBUG is not set
>> # CONFIG_RUNTIME_TESTING_MENU is not set
>> # CONFIG_MEMTEST is not set
>> # CONFIG_BUG_ON_DATA_CORRUPTION is not set
>> # CONFIG_SAMPLES is not set
>> CONFIG_HAVE_ARCH_KGDB=y
>> # CONFIG_KGDB is not set
>> CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
>> CONFIG_UBSAN=y
>> # CONFIG_UBSAN_SANITIZE_ALL is not set
>> # CONFIG_UBSAN_ALIGNMENT is not set
>> CONFIG_TEST_UBSAN=m
>> CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
>> CONFIG_STRICT_DEVMEM=y
>> CONFIG_IO_STRICT_DEVMEM=y
>> CONFIG_TRACE_IRQFLAGS_SUPPORT=y
>> CONFIG_X86_VERBOSE_BOOTUP=y
>> # CONFIG_EARLY_PRINTK is not set
>> # CONFIG_X86_PTDUMP is not set
>> # CONFIG_DEBUG_WX is not set
>> CONFIG_DOUBLEFAULT=y
>> # CONFIG_DEBUG_TLBFLUSH is not set
>> CONFIG_HAVE_MMIOTRACE_SUPPORT=y
>> CONFIG_IO_DELAY_TYPE_0X80=0
>> CONFIG_IO_DELAY_TYPE_0XED=1
>> CONFIG_IO_DELAY_TYPE_UDELAY=2
>> CONFIG_IO_DELAY_TYPE_NONE=3
>> # CONFIG_IO_DELAY_0X80 is not set
>> # CONFIG_IO_DELAY_0XED is not set
>> # CONFIG_IO_DELAY_UDELAY is not set
>> CONFIG_IO_DELAY_NONE=y
>> CONFIG_DEFAULT_IO_DELAY_TYPE=3
>> CONFIG_DEBUG_BOOT_PARAMS=y
>> # CONFIG_CPA_DEBUG is not set
>> # CONFIG_OPTIMIZE_INLINING is not set
>> # CONFIG_DEBUG_ENTRY is not set
>> # CONFIG_DEBUG_NMI_SELFTEST is not set
>> CONFIG_X86_DEBUG_FPU=y
>> CONFIG_PUNIT_ATOM_DEBUG=m
>> CONFIG_UNWINDER_ORC=y
>> # CONFIG_UNWINDER_FRAME_POINTER is not set
>> # CONFIG_UNWINDER_GUESS is not set
>

--------------8AA4B2326A15E0CDFA751ECC
Content-Type: text/plain; charset=UTF-8;
 name="dmesg-quantal-vm-quantal-607:20190218160041:x86_64-randconfig-s2-02172318:5.0.0-rc4-00150-gb523ab1:1"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename*0="dmesg-quantal-vm-quantal-607:20190218160041:x86_64-randconfi";
 filename*1="g-s2-02172318:5.0.0-rc4-00150-gb523ab1:1"

ZWFybHkgY29uc29sZSBpbiBzZXR1cCBjb2RlClByb2JpbmcgRUREIChlZGQ9b2ZmIHRvIGRp
c2FibGUpLi4uIG9rClsgICAgMC4wMDAwMDBdIExpbnV4IHZlcnNpb24gNS4wLjAtcmM0LTAw
MTUwLWdiNTIzYWIxIChrYnVpbGRAbGtwLWhzeDAzKSAoZ2NjIHZlcnNpb24gNi41LjAgMjAx
ODEwMjYgKERlYmlhbiA2LjUuMC0yKSkgIzEgU01QIFBSRUVNUFQgTW9uIEZlYiAxOCAxNTo1
Nzo1NSBDU1QgMjAxOQpbICAgIDAuMDAwMDAwXSBDb21tYW5kIGxpbmU6IHJvb3Q9L2Rldi9y
YW0wIGh1bmdfdGFza19wYW5pYz0xIGRlYnVnIGFwaWM9ZGVidWcgc3lzcnFfYWx3YXlzX2Vu
YWJsZWQgcmN1cGRhdGUucmN1X2NwdV9zdGFsbF90aW1lb3V0PTEwMCBuZXQuaWZuYW1lcz0w
IHByaW50ay5kZXZrbXNnPW9uIHBhbmljPS0xIHNvZnRsb2NrdXBfcGFuaWM9MSBubWlfd2F0
Y2hkb2c9cGFuaWMgb29wcz1wYW5pYyBsb2FkX3JhbWRpc2s9MiBwcm9tcHRfcmFtZGlzaz0w
IGRyYmQubWlub3JfY291bnQ9OCBzeXN0ZW1kLmxvZ19sZXZlbD1lcnIgaWdub3JlX2xvZ2xl
dmVsIGNvbnNvbGU9dHR5MCBlYXJseXByaW50az10dHlTMCwxMTUyMDAgY29uc29sZT10dHlT
MCwxMTUyMDAgdmdhPW5vcm1hbCBydyBsaW5rPS9jZXBoZnMva2J1aWxkL3J1bi1xdWV1ZS9r
dm0veDg2XzY0LXJhbmRjb25maWctczItMDIxNzIzMTgvbGludXgtZGV2ZWw6Zml4dXAtZWZh
ZDRlNDc1YzMxMjQ1NmVkYjNjNzg5ZDA5OTZkMTJlZDc0NGMxMzpiNTIzYWIxYjhjZTU5NTky
Y2IzMmQ2MjI1MDMyMTcwNzdjZjA3ZTRkLy52bWxpbnV6LWI1MjNhYjFiOGNlNTk1OTJjYjMy
ZDYyMjUwMzIxNzA3N2NmMDdlNGQtMjAxOTAyMTgxNjAwMTItMTA0OnF1YW50YWwtdm0tcXVh
bnRhbC02MDcgYnJhbmNoPWxpbnV4LWRldmVsL2ZpeHVwLWVmYWQ0ZTQ3NWMzMTI0NTZlZGIz
Yzc4OWQwOTk2ZDEyZWQ3NDRjMTMgQk9PVF9JTUFHRT0vcGtnL2xpbnV4L3g4Nl82NC1yYW5k
Y29uZmlnLXMyLTAyMTcyMzE4L2djYy02L2I1MjNhYjFiOGNlNTk1OTJjYjMyZDYyMjUwMzIx
NzA3N2NmMDdlNGQvdm1saW51ei01LjAuMC1yYzQtMDAxNTAtZ2I1MjNhYjEgZHJiZC5taW5v
cl9jb3VudD04IHJjdXBlcmYuc2h1dGRvd249MApbICAgIDAuMDAwMDAwXSBLRVJORUwgc3Vw
cG9ydGVkIGNwdXM6ClsgICAgMC4wMDAwMDBdICAgSW50ZWwgR2VudWluZUludGVsClsgICAg
MC4wMDAwMDBdIHg4Ni9mcHU6IHg4NyBGUFUgd2lsbCB1c2UgRlhTQVZFClsgICAgMC4wMDAw
MDBdIEJJT1MtcHJvdmlkZWQgcGh5c2ljYWwgUkFNIG1hcDoKWyAgICAwLjAwMDAwMF0gQklP
Uy1lODIwOiBbbWVtIDB4MDAwMDAwMDAwMDAwMDAwMC0weDAwMDAwMDAwMDAwOWZiZmZdIHVz
YWJsZQpbICAgIDAuMDAwMDAwXSBCSU9TLWU4MjA6IFttZW0gMHgwMDAwMDAwMDAwMDlmYzAw
LTB4MDAwMDAwMDAwMDA5ZmZmZl0gcmVzZXJ2ZWQKWyAgICAwLjAwMDAwMF0gQklPUy1lODIw
OiBbbWVtIDB4MDAwMDAwMDAwMDBmMDAwMC0weDAwMDAwMDAwMDAwZmZmZmZdIHJlc2VydmVk
ClsgICAgMC4wMDAwMDBdIEJJT1MtZTgyMDogW21lbSAweDAwMDAwMDAwMDAxMDAwMDAtMHgw
MDAwMDAwMDFmZmRmZmZmXSB1c2FibGUKWyAgICAwLjAwMDAwMF0gQklPUy1lODIwOiBbbWVt
IDB4MDAwMDAwMDAxZmZlMDAwMC0weDAwMDAwMDAwMWZmZmZmZmZdIHJlc2VydmVkClsgICAg
MC4wMDAwMDBdIEJJT1MtZTgyMDogW21lbSAweDAwMDAwMDAwZmVmZmMwMDAtMHgwMDAwMDAw
MGZlZmZmZmZmXSByZXNlcnZlZApbICAgIDAuMDAwMDAwXSBCSU9TLWU4MjA6IFttZW0gMHgw
MDAwMDAwMGZmZmMwMDAwLTB4MDAwMDAwMDBmZmZmZmZmZl0gcmVzZXJ2ZWQKWyAgICAwLjAw
MDAwMF0gcHJpbnRrOiBkZWJ1ZzogaWdub3JpbmcgbG9nbGV2ZWwgc2V0dGluZy4KWyAgICAw
LjAwMDAwMF0gTlggKEV4ZWN1dGUgRGlzYWJsZSkgcHJvdGVjdGlvbjogYWN0aXZlClsgICAg
MC4wMDAwMDBdIFNNQklPUyAyLjggcHJlc2VudC4KWyAgICAwLjAwMDAwMF0gRE1JOiBRRU1V
IFN0YW5kYXJkIFBDIChpNDQwRlggKyBQSUlYLCAxOTk2KSwgQklPUyAxLjEwLjItMSAwNC8w
MS8yMDE0ClsgICAgMC4wMDAwMDBdIEh5cGVydmlzb3IgZGV0ZWN0ZWQ6IEtWTQpbICAgIDAu
MDAwMDAwXSBrdm0tY2xvY2s6IFVzaW5nIG1zcnMgNGI1NjRkMDEgYW5kIDRiNTY0ZDAwClsg
ICAgMC4wMDAwMDBdIGt2bS1jbG9jazogY3B1IDAsIG1zciAyODg3MDAxLCBwcmltYXJ5IGNw
dSBjbG9jawpbICAgIDAuMDAwMDAwXSBrdm0tY2xvY2s6IHVzaW5nIHNjaGVkIG9mZnNldCBv
ZiAxNjA1NjYwOTI5IGN5Y2xlcwpbICAgIDAuMDAwMDA0XSBjbG9ja3NvdXJjZToga3ZtLWNs
b2NrOiBtYXNrOiAweGZmZmZmZmZmZmZmZmZmZmYgbWF4X2N5Y2xlczogMHgxY2Q0MmU0ZGZm
YiwgbWF4X2lkbGVfbnM6IDg4MTU5MDU5MTQ4MyBucwpbICAgIDAuMDAwMDEwXSB0c2M6IERl
dGVjdGVkIDIyOTkuOTk2IE1IeiBwcm9jZXNzb3IKWyAgICAwLjAwMTcyMF0gZTgyMDogdXBk
YXRlIFttZW0gMHgwMDAwMDAwMC0weDAwMDAwZmZmXSB1c2FibGUgPT0+IHJlc2VydmVkClsg
ICAgMC4wMDE3MjRdIGU4MjA6IHJlbW92ZSBbbWVtIDB4MDAwYTAwMDAtMHgwMDBmZmZmZl0g
dXNhYmxlClsgICAgMC4wMDE3MjldIGxhc3RfcGZuID0gMHgxZmZlMCBtYXhfYXJjaF9wZm4g
PSAweDQwMDAwMDAwMApbICAgIDAuMDAxNzMzXSB4ODYvUEFUOiBDb25maWd1cmF0aW9uIFsw
LTddOiBXQiAgV1QgIFVDLSBVQyAgV0IgIFdUICBVQy0gVUMgIApbICAgIDAuMDAxNzM2XSBT
Y2FuIGZvciBTTVAgaW4gW21lbSAweDAwMDAwMDAwLTB4MDAwMDAzZmZdClsgICAgMC4wMDE3
NTddIFNjYW4gZm9yIFNNUCBpbiBbbWVtIDB4MDAwOWZjMDAtMHgwMDA5ZmZmZl0KWyAgICAw
LjAwMTc3OV0gU2NhbiBmb3IgU01QIGluIFttZW0gMHgwMDBmMDAwMC0weDAwMGZmZmZmXQpb
ICAgIDAuMDA2MTM1XSBmb3VuZCBTTVAgTVAtdGFibGUgYXQgW21lbSAweDAwMGY2YTgwLTB4
MDAwZjZhOGZdIG1hcHBlZCBhdCBbKF9fX19wdHJ2YWxfX19fKV0KWyAgICAwLjAwNjEzOV0g
ICBtcGM6IGY2YTkwLWY2Yjc0ClsgICAgMC4wMDYxODJdIGNoZWNrOiBTY2FubmluZyAxIGFy
ZWFzIGZvciBsb3cgbWVtb3J5IGNvcnJ1cHRpb24KWyAgICAwLjAwNjE4Nl0gQmFzZSBtZW1v
cnkgdHJhbXBvbGluZSBhdCBbKF9fX19wdHJ2YWxfX19fKV0gOTkwMDAgc2l6ZSAyNDU3Ngpb
ICAgIDAuMDA2MjM3XSBCUksgWzB4MDM2MDEwMDAsIDB4MDM2MDFmZmZdIFBHVEFCTEUKWyAg
ICAwLjAwNjI0MV0gQlJLIFsweDAzNjAyMDAwLCAweDAzNjAyZmZmXSBQR1RBQkxFClsgICAg
MC4wMDYyNDNdIEJSSyBbMHgwMzYwMzAwMCwgMHgwMzYwM2ZmZl0gUEdUQUJMRQpbICAgIDAu
MDA2NDAzXSBCUksgWzB4MDM2MDQwMDAsIDB4MDM2MDRmZmZdIFBHVEFCTEUKWyAgICAwLjAw
NjQzMV0gUkFNRElTSzogW21lbSAweDFlOGM2MDAwLTB4MWZmZGZmZmZdClsgICAgMC4wMDY0
NDldIEFDUEk6IEVhcmx5IHRhYmxlIGNoZWNrc3VtIHZlcmlmaWNhdGlvbiBkaXNhYmxlZApb
ICAgIDAuMDA2NDkyXSBBQ1BJOiBSU0RQIDB4MDAwMDAwMDAwMDBGNjg3MCAwMDAwMTQgKHYw
MCBCT0NIUyApClsgICAgMC4wMDY0OTddIEFDUEk6IFJTRFQgMHgwMDAwMDAwMDFGRkUxOTM2
IDAwMDAzMCAodjAxIEJPQ0hTICBCWFBDUlNEVCAwMDAwMDAwMSBCWFBDIDAwMDAwMDAxKQpb
ICAgIDAuMDA2NTAzXSBBQ1BJOiBGQUNQIDB4MDAwMDAwMDAxRkZFMTgwQSAwMDAwNzQgKHYw
MSBCT0NIUyAgQlhQQ0ZBQ1AgMDAwMDAwMDEgQlhQQyAwMDAwMDAwMSkKWyAgICAwLjAwNjUw
OV0gQUNQSTogRFNEVCAweDAwMDAwMDAwMUZGRTAwNDAgMDAxN0NBICh2MDEgQk9DSFMgIEJY
UENEU0RUIDAwMDAwMDAxIEJYUEMgMDAwMDAwMDEpClsgICAgMC4wMDY1MTNdIEFDUEk6IEZB
Q1MgMHgwMDAwMDAwMDFGRkUwMDAwIDAwMDA0MApbICAgIDAuMDA2NTE3XSBBQ1BJOiBBUElD
IDB4MDAwMDAwMDAxRkZFMTg3RSAwMDAwODAgKHYwMSBCT0NIUyAgQlhQQ0FQSUMgMDAwMDAw
MDEgQlhQQyAwMDAwMDAwMSkKWyAgICAwLjAwNjUyMV0gQUNQSTogSFBFVCAweDAwMDAwMDAw
MUZGRTE4RkUgMDAwMDM4ICh2MDEgQk9DSFMgIEJYUENIUEVUIDAwMDAwMDAxIEJYUEMgMDAw
MDAwMDEpClsgICAgMC4wMDY1MjhdIEFDUEk6IExvY2FsIEFQSUMgYWRkcmVzcyAweGZlZTAw
MDAwClsgICAgMC4wMDY1MzNdIG1hcHBlZCBBUElDIHRvIGZmZmZmZmZmZmY1ZmQwMDAgKCAg
ICAgICAgZmVlMDAwMDApClsgICAgMC4wMDY4NDVdIE5vIE5VTUEgY29uZmlndXJhdGlvbiBm
b3VuZApbICAgIDAuMDA2ODQ4XSBGYWtpbmcgYSBub2RlIGF0IFttZW0gMHgwMDAwMDAwMDAw
MDAwMDAwLTB4MDAwMDAwMDAxZmZkZmZmZl0KWyAgICAwLjAwNjg1M10gTk9ERV9EQVRBKDAp
IGFsbG9jYXRlZCBbbWVtIDB4MWU4YzMwMDAtMHgxZThjNWZmZl0KWyAgICAwLjAwOTYyM10g
Wm9uZSByYW5nZXM6ClsgICAgMC4wMDk2MjddICAgRE1BMzIgICAgW21lbSAweDAwMDAwMDAw
MDAwMDEwMDAtMHgwMDAwMDAwMDFmZmRmZmZmXQpbICAgIDAuMDA5NjI5XSAgIE5vcm1hbCAg
IGVtcHR5ClsgICAgMC4wMDk2MzJdIE1vdmFibGUgem9uZSBzdGFydCBmb3IgZWFjaCBub2Rl
ClsgICAgMC4wMDk2MzRdIEVhcmx5IG1lbW9yeSBub2RlIHJhbmdlcwpbICAgIDAuMDA5NjM2
XSAgIG5vZGUgICAwOiBbbWVtIDB4MDAwMDAwMDAwMDAwMTAwMC0weDAwMDAwMDAwMDAwOWVm
ZmZdClsgICAgMC4wMDk2MzhdICAgbm9kZSAgIDA6IFttZW0gMHgwMDAwMDAwMDAwMTAwMDAw
LTB4MDAwMDAwMDAxZmZkZmZmZl0KWyAgICAwLjAwOTY0M10gWmVyb2VkIHN0cnVjdCBwYWdl
IGluIHVuYXZhaWxhYmxlIHJhbmdlczogOTggcGFnZXMKWyAgICAwLjAwOTY0NF0gSW5pdG1l
bSBzZXR1cCBub2RlIDAgW21lbSAweDAwMDAwMDAwMDAwMDEwMDAtMHgwMDAwMDAwMDFmZmRm
ZmZmXQpbICAgIDAuMDA5NjQ3XSBPbiBub2RlIDAgdG90YWxwYWdlczogMTMwOTQyClsgICAg
MC4wMDk2NTBdICAgRE1BMzIgem9uZTogMTc5MiBwYWdlcyB1c2VkIGZvciBtZW1tYXAKWyAg
ICAwLjAwOTY1Ml0gICBETUEzMiB6b25lOiAyMSBwYWdlcyByZXNlcnZlZApbICAgIDAuMDA5
NjU0XSAgIERNQTMyIHpvbmU6IDEzMDk0MiBwYWdlcywgTElGTyBiYXRjaDozMQpbICAgIDAu
MDEyNDI5XSBBQ1BJOiBQTS1UaW1lciBJTyBQb3J0OiAweDYwOApbICAgIDAuMDEyNDMzXSBB
Q1BJOiBMb2NhbCBBUElDIGFkZHJlc3MgMHhmZWUwMDAwMApbICAgIDAuMDEyNDM5XSBBQ1BJ
OiBMQVBJQ19OTUkgKGFjcGlfaWRbMHhmZl0gZGZsIGRmbCBsaW50WzB4MV0pClsgICAgMC4w
MTI0NzRdIElPQVBJQ1swXTogYXBpY19pZCAwLCB2ZXJzaW9uIDE3LCBhZGRyZXNzIDB4ZmVj
MDAwMDAsIEdTSSAwLTIzClsgICAgMC4wMTI0ODJdIEFDUEk6IElOVF9TUkNfT1ZSIChidXMg
MCBidXNfaXJxIDAgZ2xvYmFsX2lycSAyIGRmbCBkZmwpClsgICAgMC4wMTI0ODZdIEludDog
dHlwZSAwLCBwb2wgMCwgdHJpZyAwLCBidXMgMDAsIElSUSAwMCwgQVBJQyBJRCAwLCBBUElD
IElOVCAwMgpbICAgIDAuMDEyNDg5XSBBQ1BJOiBJTlRfU1JDX09WUiAoYnVzIDAgYnVzX2ly
cSA1IGdsb2JhbF9pcnEgNSBoaWdoIGxldmVsKQpbICAgIDAuMDEyNDkxXSBJbnQ6IHR5cGUg
MCwgcG9sIDEsIHRyaWcgMywgYnVzIDAwLCBJUlEgMDUsIEFQSUMgSUQgMCwgQVBJQyBJTlQg
MDUKWyAgICAwLjAxMjQ5NF0gQUNQSTogSU5UX1NSQ19PVlIgKGJ1cyAwIGJ1c19pcnEgOSBn
bG9iYWxfaXJxIDkgaGlnaCBsZXZlbCkKWyAgICAwLjAxMjQ5Nl0gSW50OiB0eXBlIDAsIHBv
bCAxLCB0cmlnIDMsIGJ1cyAwMCwgSVJRIDA5LCBBUElDIElEIDAsIEFQSUMgSU5UIDA5Clsg
ICAgMC4wMTI0OTldIEFDUEk6IElOVF9TUkNfT1ZSIChidXMgMCBidXNfaXJxIDEwIGdsb2Jh
bF9pcnEgMTAgaGlnaCBsZXZlbCkKWyAgICAwLjAxMjUwMl0gSW50OiB0eXBlIDAsIHBvbCAx
LCB0cmlnIDMsIGJ1cyAwMCwgSVJRIDBhLCBBUElDIElEIDAsIEFQSUMgSU5UIDBhClsgICAg
MC4wMTI1MDRdIEFDUEk6IElOVF9TUkNfT1ZSIChidXMgMCBidXNfaXJxIDExIGdsb2JhbF9p
cnEgMTEgaGlnaCBsZXZlbCkKWyAgICAwLjAxMjUwN10gSW50OiB0eXBlIDAsIHBvbCAxLCB0
cmlnIDMsIGJ1cyAwMCwgSVJRIDBiLCBBUElDIElEIDAsIEFQSUMgSU5UIDBiClsgICAgMC4w
MTI1MDldIEFDUEk6IElSUTAgdXNlZCBieSBvdmVycmlkZS4KWyAgICAwLjAxMjUxMl0gSW50
OiB0eXBlIDAsIHBvbCAwLCB0cmlnIDAsIGJ1cyAwMCwgSVJRIDAxLCBBUElDIElEIDAsIEFQ
SUMgSU5UIDAxClsgICAgMC4wMTI1MTRdIEludDogdHlwZSAwLCBwb2wgMCwgdHJpZyAwLCBi
dXMgMDAsIElSUSAwMywgQVBJQyBJRCAwLCBBUElDIElOVCAwMwpbICAgIDAuMDEyNTE3XSBJ
bnQ6IHR5cGUgMCwgcG9sIDAsIHRyaWcgMCwgYnVzIDAwLCBJUlEgMDQsIEFQSUMgSUQgMCwg
QVBJQyBJTlQgMDQKWyAgICAwLjAxMjUxOV0gQUNQSTogSVJRNSB1c2VkIGJ5IG92ZXJyaWRl
LgpbICAgIDAuMDEyNTIyXSBJbnQ6IHR5cGUgMCwgcG9sIDAsIHRyaWcgMCwgYnVzIDAwLCBJ
UlEgMDYsIEFQSUMgSUQgMCwgQVBJQyBJTlQgMDYKWyAgICAwLjAxMjUyNF0gSW50OiB0eXBl
IDAsIHBvbCAwLCB0cmlnIDAsIGJ1cyAwMCwgSVJRIDA3LCBBUElDIElEIDAsIEFQSUMgSU5U
IDA3ClsgICAgMC4wMTI1MjddIEludDogdHlwZSAwLCBwb2wgMCwgdHJpZyAwLCBidXMgMDAs
IElSUSAwOCwgQVBJQyBJRCAwLCBBUElDIElOVCAwOApbICAgIDAuMDEyNTI5XSBBQ1BJOiBJ
UlE5IHVzZWQgYnkgb3ZlcnJpZGUuClsgICAgMC4wMTI1MzFdIEFDUEk6IElSUTEwIHVzZWQg
Ynkgb3ZlcnJpZGUuClsgICAgMC4wMTI1MzNdIEFDUEk6IElSUTExIHVzZWQgYnkgb3ZlcnJp
ZGUuClsgICAgMC4wMTI1MzZdIEludDogdHlwZSAwLCBwb2wgMCwgdHJpZyAwLCBidXMgMDAs
IElSUSAwYywgQVBJQyBJRCAwLCBBUElDIElOVCAwYwpbICAgIDAuMDEyNTM4XSBJbnQ6IHR5
cGUgMCwgcG9sIDAsIHRyaWcgMCwgYnVzIDAwLCBJUlEgMGQsIEFQSUMgSUQgMCwgQVBJQyBJ
TlQgMGQKWyAgICAwLjAxMjU0MV0gSW50OiB0eXBlIDAsIHBvbCAwLCB0cmlnIDAsIGJ1cyAw
MCwgSVJRIDBlLCBBUElDIElEIDAsIEFQSUMgSU5UIDBlClsgICAgMC4wMTI1NDRdIEludDog
dHlwZSAwLCBwb2wgMCwgdHJpZyAwLCBidXMgMDAsIElSUSAwZiwgQVBJQyBJRCAwLCBBUElD
IElOVCAwZgpbICAgIDAuMDEyNTQ3XSBVc2luZyBBQ1BJIChNQURUKSBmb3IgU01QIGNvbmZp
Z3VyYXRpb24gaW5mb3JtYXRpb24KWyAgICAwLjAxMjU1MF0gQUNQSTogSFBFVCBpZDogMHg4
MDg2YTIwMSBiYXNlOiAweGZlZDAwMDAwClsgICAgMC4wMTI1NTVdIHNtcGJvb3Q6IEFsbG93
aW5nIDIgQ1BVcywgMCBob3RwbHVnIENQVXMKWyAgICAwLjAxMjU1OF0gbWFwcGVkIElPQVBJ
QyB0byBmZmZmZmZmZmZmNWZjMDAwIChmZWMwMDAwMCkKWyAgICAwLjAxMjU4NV0gW21lbSAw
eDIwMDAwMDAwLTB4ZmVmZmJmZmZdIGF2YWlsYWJsZSBmb3IgUENJIGRldmljZXMKWyAgICAw
LjAxMjU4N10gQm9vdGluZyBwYXJhdmlydHVhbGl6ZWQga2VybmVsIG9uIEtWTQpbICAgIDAu
MDEyNTkwXSBjbG9ja3NvdXJjZTogcmVmaW5lZC1qaWZmaWVzOiBtYXNrOiAweGZmZmZmZmZm
IG1heF9jeWNsZXM6IDB4ZmZmZmZmZmYsIG1heF9pZGxlX25zOiAxOTEwOTY5OTQwMzkxNDE5
IG5zClsgICAgMC4xNjQ5ODJdIHNldHVwX3BlcmNwdTogTlJfQ1BVUzo2NCBucl9jcHVtYXNr
X2JpdHM6NjQgbnJfY3B1X2lkczoyIG5yX25vZGVfaWRzOjEKWyAgICAwLjE2NTU2OV0gcGVy
Y3B1OiBFbWJlZGRlZCA1OSBwYWdlcy9jcHUgQChfX19fcHRydmFsX19fXykgczIwMTkyOCBy
ODE5MiBkMzE1NDQgdTEwNDg1NzYKWyAgICAwLjE2NTU3NV0gcGNwdS1hbGxvYzogczIwMTky
OCByODE5MiBkMzE1NDQgdTEwNDg1NzYgYWxsb2M9MSoyMDk3MTUyClsgICAgMC4xNjU1Nzhd
IHBjcHUtYWxsb2M6IFswXSAwIDEgClsgICAgMC4xNjU2MDddIEtWTSBzZXR1cCBhc3luYyBQ
RiBmb3IgY3B1IDAKWyAgICAwLjE2NTYxM10ga3ZtLXN0ZWFsdGltZTogY3B1IDAsIG1zciAx
ZGMxNTBjMApbICAgIDAuMTY1NjIxXSBCdWlsdCAxIHpvbmVsaXN0cywgbW9iaWxpdHkgZ3Jv
dXBpbmcgb24uICBUb3RhbCBwYWdlczogMTI5MTI5ClsgICAgMC4xNjU2MjNdIFBvbGljeSB6
b25lOiBETUEzMgpbICAgIDAuMTY1NjI4XSBLZXJuZWwgY29tbWFuZCBsaW5lOiByb290PS9k
ZXYvcmFtMCBodW5nX3Rhc2tfcGFuaWM9MSBkZWJ1ZyBhcGljPWRlYnVnIHN5c3JxX2Fsd2F5
c19lbmFibGVkIHJjdXBkYXRlLnJjdV9jcHVfc3RhbGxfdGltZW91dD0xMDAgbmV0LmlmbmFt
ZXM9MCBwcmludGsuZGV2a21zZz1vbiBwYW5pYz0tMSBzb2Z0bG9ja3VwX3BhbmljPTEgbm1p
X3dhdGNoZG9nPXBhbmljIG9vcHM9cGFuaWMgbG9hZF9yYW1kaXNrPTIgcHJvbXB0X3JhbWRp
c2s9MCBkcmJkLm1pbm9yX2NvdW50PTggc3lzdGVtZC5sb2dfbGV2ZWw9ZXJyIGlnbm9yZV9s
b2dsZXZlbCBjb25zb2xlPXR0eTAgZWFybHlwcmludGs9dHR5UzAsMTE1MjAwIGNvbnNvbGU9
dHR5UzAsMTE1MjAwIHZnYT1ub3JtYWwgcncgbGluaz0vY2VwaGZzL2tidWlsZC9ydW4tcXVl
dWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLXMyLTAyMTcyMzE4L2xpbnV4LWRldmVsOmZpeHVw
LWVmYWQ0ZTQ3NWMzMTI0NTZlZGIzYzc4OWQwOTk2ZDEyZWQ3NDRjMTM6YjUyM2FiMWI4Y2U1
OTU5MmNiMzJkNjIyNTAzMjE3MDc3Y2YwN2U0ZC8udm1saW51ei1iNTIzYWIxYjhjZTU5NTky
Y2IzMmQ2MjI1MDMyMTcwNzdjZjA3ZTRkLTIwMTkwMjE4MTYwMDEyLTEwNDpxdWFudGFsLXZt
LXF1YW50YWwtNjA3IGJyYW5jaD1saW51eC1kZXZlbC9maXh1cC1lZmFkNGU0NzVjMzEyNDU2
ZWRiM2M3ODlkMDk5NmQxMmVkNzQ0YzEzIEJPT1RfSU1BR0U9L3BrZy9saW51eC94ODZfNjQt
cmFuZGNvbmZpZy1zMi0wMjE3MjMxOC9nY2MtNi9iNTIzYWIxYjhjZTU5NTkyY2IzMmQ2MjI1
MDMyMTcwNzdjZjA3ZTRkL3ZtbGludXotNS4wLjAtcmM0LTAwMTUwLWdiNTIzYWIxIGRyYmQu
bWlub3JfY291bnQ9OCByY3VwZXJmLnNodXRkb3duPTAKWyAgICAwLjE2NTcwOF0gc3lzcnE6
IHN5c3JxIGFsd2F5cyBlbmFibGVkLgpbICAgIDAuMTY2MDE5XSBDYWxnYXJ5OiBkZXRlY3Rp
bmcgQ2FsZ2FyeSB2aWEgQklPUyBFQkRBIGFyZWEKWyAgICAwLjE2NjAyM10gQ2FsZ2FyeTog
VW5hYmxlIHRvIGxvY2F0ZSBSaW8gR3JhbmRlIHRhYmxlIGluIEVCREEgLSBiYWlsaW5nIQpb
ICAgIDAuMTY3Mjc5XSBNZW1vcnk6IDQ1MjMyOEsvNTIzNzY4SyBhdmFpbGFibGUgKDEyMjkx
SyBrZXJuZWwgY29kZSwgMTM0NksgcndkYXRhLCAzODcySyByb2RhdGEsIDExMDhLIGluaXQs
IDEzODY4SyBic3MsIDcxNDQwSyByZXNlcnZlZCwgMEsgY21hLXJlc2VydmVkKQpbICAgIDAu
MTY3MzAzXSBLZXJuZWwvVXNlciBwYWdlIHRhYmxlcyBpc29sYXRpb246IGVuYWJsZWQKWyAg
ICAwLjE2NzQ5OV0gUnVubmluZyBSQ1Ugc2VsZiB0ZXN0cwpbICAgIDAuMTY3NTAyXSByY3U6
IFByZWVtcHRpYmxlIGhpZXJhcmNoaWNhbCBSQ1UgaW1wbGVtZW50YXRpb24uClsgICAgMC4x
Njc1MDRdIHJjdTogCVJDVSBsb2NrZGVwIGNoZWNraW5nIGlzIGVuYWJsZWQuClsgICAgMC4x
Njc1MDddIHJjdTogCVJDVSByZXN0cmljdGluZyBDUFVzIGZyb20gTlJfQ1BVUz02NCB0byBu
cl9jcHVfaWRzPTIuClsgICAgMC4xNjc1MDldIAlSQ1UgQ1BVIHN0YWxsIHdhcm5pbmdzIHRp
bWVvdXQgc2V0IHRvIDEwMCAocmN1X2NwdV9zdGFsbF90aW1lb3V0KS4KWyAgICAwLjE2NzUx
MV0gCVRhc2tzIFJDVSBlbmFibGVkLgpbICAgIDAuMTY3NTE0XSByY3U6IFJDVSBjYWxjdWxh
dGVkIHZhbHVlIG9mIHNjaGVkdWxlci1lbmxpc3RtZW50IGRlbGF5IGlzIDEwMCBqaWZmaWVz
LgpbICAgIDAuMTY3NTE2XSByY3U6IEFkanVzdGluZyBnZW9tZXRyeSBmb3IgcmN1X2Zhbm91
dF9sZWFmPTE2LCBucl9jcHVfaWRzPTIKWyAgICAwLjE2Nzc5NF0gTlJfSVJRUzogNDM1Miwg
bnJfaXJxczogNDQwLCBwcmVhbGxvY2F0ZWQgaXJxczogMTYKWyAgICAwLjE2Nzk4Nl0gcmN1
OiAJT2ZmbG9hZCBSQ1UgY2FsbGJhY2tzIGZyb20gQ1BVczogKG5vbmUpLgpbICAgIDAuMjgz
OTg1XSBwcmludGs6IGNvbnNvbGUgW3R0eVMwXSBlbmFibGVkClsgICAgMC4yODQ0MjVdIExv
Y2sgZGVwZW5kZW5jeSB2YWxpZGF0b3I6IENvcHlyaWdodCAoYykgMjAwNiBSZWQgSGF0LCBJ
bmMuLCBJbmdvIE1vbG5hcgpbICAgIDAuMjg1MjUyXSAuLi4gTUFYX0xPQ0tERVBfU1VCQ0xB
U1NFUzogIDgKWyAgICAwLjI4NTY2OF0gLi4uIE1BWF9MT0NLX0RFUFRIOiAgICAgICAgICA0
OApbICAgIDAuMjg2MTExXSAuLi4gTUFYX0xPQ0tERVBfS0VZUzogICAgICAgIDgxOTEKWyAg
ICAwLjI4NjU2OV0gLi4uIENMQVNTSEFTSF9TSVpFOiAgICAgICAgICA0MDk2ClsgICAgMC4y
ODcwMzRdIC4uLiBNQVhfTE9DS0RFUF9FTlRSSUVTOiAgICAgMzI3NjgKWyAgICAwLjI4NzUw
MF0gLi4uIE1BWF9MT0NLREVQX0NIQUlOUzogICAgICA2NTUzNgpbICAgIDAuMjg3OTY2XSAu
Li4gQ0hBSU5IQVNIX1NJWkU6ICAgICAgICAgIDMyNzY4ClsgICAgMC4yODg0MzZdICBtZW1v
cnkgdXNlZCBieSBsb2NrIGRlcGVuZGVuY3kgaW5mbzogNzI2MyBrQgpbICAgIDAuMjk3MDY0
XSAgcGVyIHRhc2stc3RydWN0IG1lbW9yeSBmb290cHJpbnQ6IDE5MjAgYnl0ZXMKWyAgICAw
LjI5NzY2OV0gQUNQSTogQ29yZSByZXZpc2lvbiAyMDE4MTIxMwpbICAgIDAuMjk4Mzg2XSBj
bG9ja3NvdXJjZTogaHBldDogbWFzazogMHhmZmZmZmZmZiBtYXhfY3ljbGVzOiAweGZmZmZm
ZmZmLCBtYXhfaWRsZV9uczogMTkxMTI2MDQ0NjcgbnMKWyAgICAwLjI5OTU1NF0gaHBldCBj
bG9ja2V2ZW50IHJlZ2lzdGVyZWQKWyAgICAwLjMwMDA0Ml0gQVBJQzogU3dpdGNoIHRvIHN5
bW1ldHJpYyBJL08gbW9kZSBzZXR1cApbICAgIDAuMzAwNjI4XSBlbmFibGVkIEV4dElOVCBv
biBDUFUjMApbICAgIDAuMzAxODE5XSBFTkFCTElORyBJTy1BUElDIElSUXMKWyAgICAwLjMw
MjE5MV0gaW5pdCBJT19BUElDIElSUXMKWyAgICAwLjMwMjU0Ml0gIGFwaWMgMCBwaW4gMCBu
b3QgY29ubmVjdGVkClsgICAgMC4zMDI5NzZdIElPQVBJQ1swXTogU2V0IHJvdXRpbmcgZW50
cnkgKDAtMSAtPiAweGVmIC0+IElSUSAxIE1vZGU6MCBBY3RpdmU6MCBEZXN0OjEpClsgICAg
MC4zMDM4NjZdIElPQVBJQ1swXTogU2V0IHJvdXRpbmcgZW50cnkgKDAtMiAtPiAweDMwIC0+
IElSUSAwIE1vZGU6MCBBY3RpdmU6MCBEZXN0OjEpClsgICAgMC4zMDQ3MjhdIElPQVBJQ1sw
XTogU2V0IHJvdXRpbmcgZW50cnkgKDAtMyAtPiAweGVmIC0+IElSUSAzIE1vZGU6MCBBY3Rp
dmU6MCBEZXN0OjEpClsgICAgMC4zMDU1OThdIElPQVBJQ1swXTogU2V0IHJvdXRpbmcgZW50
cnkgKDAtNCAtPiAweGVmIC0+IElSUSA0IE1vZGU6MCBBY3RpdmU6MCBEZXN0OjEpClsgICAg
MC4zMDY0MjddIElPQVBJQ1swXTogU2V0IHJvdXRpbmcgZW50cnkgKDAtNSAtPiAweGVmIC0+
IElSUSA1IE1vZGU6MSBBY3RpdmU6MCBEZXN0OjEpClsgICAgMC4zMDcyNzldIElPQVBJQ1sw
XTogU2V0IHJvdXRpbmcgZW50cnkgKDAtNiAtPiAweGVmIC0+IElSUSA2IE1vZGU6MCBBY3Rp
dmU6MCBEZXN0OjEpClsgICAgMC4zMDgxMjZdIElPQVBJQ1swXTogU2V0IHJvdXRpbmcgZW50
cnkgKDAtNyAtPiAweGVmIC0+IElSUSA3IE1vZGU6MCBBY3RpdmU6MCBEZXN0OjEpClsgICAg
MC4zMDkwMDJdIElPQVBJQ1swXTogU2V0IHJvdXRpbmcgZW50cnkgKDAtOCAtPiAweGVmIC0+
IElSUSA4IE1vZGU6MCBBY3RpdmU6MCBEZXN0OjEpClsgICAgMC4zMDk4NDRdIElPQVBJQ1sw
XTogU2V0IHJvdXRpbmcgZW50cnkgKDAtOSAtPiAweGVmIC0+IElSUSA5IE1vZGU6MSBBY3Rp
dmU6MCBEZXN0OjEpClsgICAgMC4zMTA2OTFdIElPQVBJQ1swXTogU2V0IHJvdXRpbmcgZW50
cnkgKDAtMTAgLT4gMHhlZiAtPiBJUlEgMTAgTW9kZToxIEFjdGl2ZTowIERlc3Q6MSkKWyAg
ICAwLjMxMTU0OV0gSU9BUElDWzBdOiBTZXQgcm91dGluZyBlbnRyeSAoMC0xMSAtPiAweGVm
IC0+IElSUSAxMSBNb2RlOjEgQWN0aXZlOjAgRGVzdDoxKQpbICAgIDAuMzEyMzkyXSBJT0FQ
SUNbMF06IFNldCByb3V0aW5nIGVudHJ5ICgwLTEyIC0+IDB4ZWYgLT4gSVJRIDEyIE1vZGU6
MCBBY3RpdmU6MCBEZXN0OjEpClsgICAgMC4zMTMyNThdIElPQVBJQ1swXTogU2V0IHJvdXRp
bmcgZW50cnkgKDAtMTMgLT4gMHhlZiAtPiBJUlEgMTMgTW9kZTowIEFjdGl2ZTowIERlc3Q6
MSkKWyAgICAwLjMxNDExN10gSU9BUElDWzBdOiBTZXQgcm91dGluZyBlbnRyeSAoMC0xNCAt
PiAweGVmIC0+IElSUSAxNCBNb2RlOjAgQWN0aXZlOjAgRGVzdDoxKQpbICAgIDAuMzE0OTcx
XSBJT0FQSUNbMF06IFNldCByb3V0aW5nIGVudHJ5ICgwLTE1IC0+IDB4ZWYgLT4gSVJRIDE1
IE1vZGU6MCBBY3RpdmU6MCBEZXN0OjEpClsgICAgMC4zMTU4MjRdICBhcGljIDAgcGluIDE2
IG5vdCBjb25uZWN0ZWQKWyAgICAwLjMxNjI0Ml0gIGFwaWMgMCBwaW4gMTcgbm90IGNvbm5l
Y3RlZApbICAgIDAuMzE2NjY5XSAgYXBpYyAwIHBpbiAxOCBub3QgY29ubmVjdGVkClsgICAg
MC4zMTcxMjddICBhcGljIDAgcGluIDE5IG5vdCBjb25uZWN0ZWQKWyAgICAwLjMxNzU2MF0g
IGFwaWMgMCBwaW4gMjAgbm90IGNvbm5lY3RlZApbICAgIDAuMzE3OTcxXSAgYXBpYyAwIHBp
biAyMSBub3QgY29ubmVjdGVkClsgICAgMC4zMTgzOTBdICBhcGljIDAgcGluIDIyIG5vdCBj
b25uZWN0ZWQKWyAgICAwLjMxODgxNl0gIGFwaWMgMCBwaW4gMjMgbm90IGNvbm5lY3RlZApb
ICAgIDAuMzE5MzQ4XSAuLlRJTUVSOiB2ZWN0b3I9MHgzMCBhcGljMT0wIHBpbjE9MiBhcGlj
Mj0tMSBwaW4yPS0xClsgICAgMC4zMjAwMTFdIGNsb2Nrc291cmNlOiB0c2MtZWFybHk6IG1h
c2s6IDB4ZmZmZmZmZmZmZmZmZmZmZiBtYXhfY3ljbGVzOiAweDIxMjczMWE1MzAxLCBtYXhf
aWRsZV9uczogNDQwNzk1MzE3MTIzIG5zClsgICAgMC4zMjExNTBdIENhbGlicmF0aW5nIGRl
bGF5IGxvb3AgKHNraXBwZWQpIHByZXNldCB2YWx1ZS4uIDQ1OTkuOTkgQm9nb01JUFMgKGxw
aj0yMjk5OTk2KQpbICAgIDAuMzIyMTM0XSBwaWRfbWF4OiBkZWZhdWx0OiA0MDk2IG1pbmlt
dW06IDMwMQpbICAgIDAuMzIzNDk5XSBEZW50cnkgY2FjaGUgaGFzaCB0YWJsZSBlbnRyaWVz
OiA2NTUzNiAob3JkZXI6IDcsIDUyNDI4OCBieXRlcykKWyAgICAwLjMyNDI5OV0gSW5vZGUt
Y2FjaGUgaGFzaCB0YWJsZSBlbnRyaWVzOiAzMjc2OCAob3JkZXI6IDYsIDI2MjE0NCBieXRl
cykKWyAgICAwLjMyNTE0OV0gTW91bnQtY2FjaGUgaGFzaCB0YWJsZSBlbnRyaWVzOiAxMDI0
IChvcmRlcjogMSwgODE5MiBieXRlcykKWyAgICAwLjMyNTg0MV0gTW91bnRwb2ludC1jYWNo
ZSBoYXNoIHRhYmxlIGVudHJpZXM6IDEwMjQgKG9yZGVyOiAxLCA4MTkyIGJ5dGVzKQpbICAg
IDAuMzI3MjE2XSBudW1hX2FkZF9jcHUgY3B1IDAgbm9kZSAwOiBtYXNrIG5vdyAwClsgICAg
MC4zMjc3MjddIExhc3QgbGV2ZWwgaVRMQiBlbnRyaWVzOiA0S0IgMCwgMk1CIDAsIDRNQiAw
ClsgICAgMC4zMjgxMzRdIExhc3QgbGV2ZWwgZFRMQiBlbnRyaWVzOiA0S0IgMCwgMk1CIDAs
IDRNQiAwLCAxR0IgMApbICAgIDAuMzI4NzU3XSBTcGVjdHJlIFYyIDogTWl0aWdhdGlvbjog
RnVsbCBnZW5lcmljIHJldHBvbGluZQpbICAgIDAuMzI5MTMzXSBTcGVjdHJlIFYyIDogU3Bl
Y3RyZSB2MiAvIFNwZWN0cmVSU0IgbWl0aWdhdGlvbjogRmlsbGluZyBSU0Igb24gY29udGV4
dCBzd2l0Y2gKWyAgICAwLjMzMDE0MF0gU3BlY3VsYXRpdmUgU3RvcmUgQnlwYXNzOiBWdWxu
ZXJhYmxlClsgICAgMC4zMzA3MzddIEZyZWVpbmcgU01QIGFsdGVybmF0aXZlcyBtZW1vcnk6
IDIwSwpbICAgIDAuMzMxNDQ3XSBVc2luZyBsb2NhbCBBUElDIHRpbWVyIGludGVycnVwdHMu
ClsgICAgMC4zMzE0NDddIGNhbGlicmF0aW5nIEFQSUMgdGltZXIgLi4uClsgICAgMC4zMzMx
MjldIC4uLiBsYXBpYyBkZWx0YSA9IDc5OTk2NTQKWyAgICAwLjMzMzEyOV0gLi4uIFBNLVRp
bWVyIGRlbHRhID0gNDU4MTY2ClsgICAgMC4zMzMxMjldIEFQSUMgY2FsaWJyYXRpb24gbm90
IGNvbnNpc3RlbnQgd2l0aCBQTS1UaW1lcjogMTI3bXMgaW5zdGVhZCBvZiAxMDBtcwpbICAg
IDAuMzMzMTI5XSBBUElDIGRlbHRhIGFkanVzdGVkIHRvIFBNLVRpbWVyOiA2MjQ5OTM1ICg3
OTk5NjU0KQpbICAgIDAuMzMzMTI5XSBUU0MgZGVsdGEgYWRqdXN0ZWQgdG8gUE0tVGltZXI6
IDIyOTk5OTE3OSAoMjk0Mzg5MjM0KQpbICAgIDAuMzMzMTI5XSAuLi4uLiBkZWx0YSA2MjQ5
OTM1ClsgICAgMC4zMzMxMjldIC4uLi4uIG11bHQ6IDI2ODQzMjY2NApbICAgIDAuMzMzMTI5
XSAuLi4uLiBjYWxpYnJhdGlvbiByZXN1bHQ6IDk5OTk4OQpbICAgIDAuMzMzMTI5XSAuLi4u
LiBDUFUgY2xvY2sgc3BlZWQgaXMgMjI5OS4wOTkxIE1Iei4KWyAgICAwLjMzMzEyOV0gLi4u
Li4gaG9zdCBidXMgY2xvY2sgc3BlZWQgaXMgOTk5LjA5ODkgTUh6LgpbICAgIDAuMzMzMTc1
XSBzbXBib290OiBDUFUwOiBJbnRlbCBDb21tb24gS1ZNIHByb2Nlc3NvciAoZmFtaWx5OiAw
eGYsIG1vZGVsOiAweDYsIHN0ZXBwaW5nOiAweDEpClsgICAgMC4zNDAxNTddIFBlcmZvcm1h
bmNlIEV2ZW50czogdW5zdXBwb3J0ZWQgTmV0YnVyc3QgQ1BVIG1vZGVsIDYgbm8gUE1VIGRy
aXZlciwgc29mdHdhcmUgZXZlbnRzIG9ubHkuClsgICAgMC4zNDMxNDNdIHJjdTogSGllcmFy
Y2hpY2FsIFNSQ1UgaW1wbGVtZW50YXRpb24uClsgICAgMC4zNDUyMzJdIE5NSSB3YXRjaGRv
ZzogUGVyZiBOTUkgd2F0Y2hkb2cgcGVybWFuZW50bHkgZGlzYWJsZWQKWyAgICAwLjM0ODE0
Ml0gc21wOiBCcmluZ2luZyB1cCBzZWNvbmRhcnkgQ1BVcyAuLi4KWyAgICAwLjM1NjIwNF0g
eDg2OiBCb290aW5nIFNNUCBjb25maWd1cmF0aW9uOgpbICAgIDAuMzU2Njc3XSAuLi4uIG5v
ZGUgICMwLCBDUFVzOiAgICAgICMxClsgICAgMC4xNDgxMzZdIGt2bS1jbG9jazogY3B1IDEs
IG1zciAyODg3MDQxLCBzZWNvbmRhcnkgY3B1IGNsb2NrClsgICAgMC4xNDgxMzZdIG1hc2tl
ZCBFeHRJTlQgb24gQ1BVIzEKWyAgICAwLjE0ODEzNl0gbnVtYV9hZGRfY3B1IGNwdSAxIG5v
ZGUgMDogbWFzayBub3cgMC0xClsgICAgMC4zNzYyMDFdIEtWTSBzZXR1cCBhc3luYyBQRiBm
b3IgY3B1IDEKWyAgICAwLjM3NjYyNV0ga3ZtLXN0ZWFsdGltZTogY3B1IDEsIG1zciAxZGQx
NTBjMApbICAgIDAuMzc3MTQ4XSBzbXA6IEJyb3VnaHQgdXAgMSBub2RlLCAyIENQVXMKWyAg
ICAwLjM3ODE1NV0gc21wYm9vdDogTWF4IGxvZ2ljYWwgcGFja2FnZXM6IDIKWyAgICAwLjM3
ODYwMF0gc21wYm9vdDogVG90YWwgb2YgMiBwcm9jZXNzb3JzIGFjdGl2YXRlZCAoOTE5OS45
OCBCb2dvTUlQUykKWyAgICAwLjM3OTQ2N10gZGV2dG1wZnM6IGluaXRpYWxpemVkClsgICAg
MC4zODAzNzBdIHg4Ni9tbTogTWVtb3J5IGJsb2NrIHNpemU6IDEyOE1CClsgICAgMC4zODIy
MjddIHdvcmtxdWV1ZTogcm91bmQtcm9iaW4gQ1BVIHNlbGVjdGlvbiBmb3JjZWQsIGV4cGVj
dCBwZXJmb3JtYW5jZSBpbXBhY3QKWyAgICAwLjM4MzIxNV0gY2xvY2tzb3VyY2U6IGppZmZp
ZXM6IG1hc2s6IDB4ZmZmZmZmZmYgbWF4X2N5Y2xlczogMHhmZmZmZmZmZiwgbWF4X2lkbGVf
bnM6IDE5MTEyNjA0NDYyNzUwMDAgbnMKWyAgICAwLjM4NDE0NV0gZnV0ZXggaGFzaCB0YWJs
ZSBlbnRyaWVzOiAxNiAob3JkZXI6IC0xLCAyMDQ4IGJ5dGVzKQpbICAgIDAuMzg1MjQ5XSBw
aW5jdHJsIGNvcmU6IGluaXRpYWxpemVkIHBpbmN0cmwgc3Vic3lzdGVtClsgICAgMC4zODY0
NzVdIHJlZ3VsYXRvci1kdW1teTogbm8gcGFyYW1ldGVycwpbICAgIDAuMzg3Mjg4XSByZWd1
bGF0b3ItZHVtbXk6IG5vIHBhcmFtZXRlcnMKWyAgICAwLjM4NzgwNV0gcmVndWxhdG9yLWR1
bW15OiBGYWlsZWQgdG8gY3JlYXRlIGRlYnVnZnMgZGlyZWN0b3J5ClsgICAgMC4zODgyNTVd
IFJUQyB0aW1lOiAxNjowMDoyMiwgZGF0ZTogMjAxOS0wMi0xOApbICAgIDAuMzg5MjgxXSBy
YW5kb206IGdldF9yYW5kb21fdTMyIGNhbGxlZCBmcm9tIGJ1Y2tldF90YWJsZV9hbGxvYysw
eDgzLzB4MTUwIHdpdGggY3JuZ19pbml0PTAKWyAgICAwLjM5MDI3OF0gTkVUOiBSZWdpc3Rl
cmVkIHByb3RvY29sIGZhbWlseSAxNgpbICAgIDAuMzkyNDAwXSBhdWRpdDogaW5pdGlhbGl6
aW5nIG5ldGxpbmsgc3Vic3lzIChkaXNhYmxlZCkKWyAgICAwLjM5NDE1NV0gYXVkaXQ6IHR5
cGU9MjAwMCBhdWRpdCgxNTUwNDc2ODIyLjE5OToxKTogc3RhdGU9aW5pdGlhbGl6ZWQgYXVk
aXRfZW5hYmxlZD0wIHJlcz0xClsgICAgMC4zOTUxNjhdIGNwdWlkbGU6IHVzaW5nIGdvdmVy
bm9yIGxhZGRlcgpbICAgIDAuMzk2MTcxXSBjcHVpZGxlOiB1c2luZyBnb3Zlcm5vciBtZW51
ClsgICAgMC4zOTcxMzVdIEFDUEk6IGJ1cyB0eXBlIFBDSSByZWdpc3RlcmVkClsgICAgMC4z
OTc3MTFdIGRjYSBzZXJ2aWNlIHN0YXJ0ZWQsIHZlcnNpb24gMS4xMi4xClsgICAgMC4zOTgy
NDFdIFBDSTogVXNpbmcgY29uZmlndXJhdGlvbiB0eXBlIDEgZm9yIGJhc2UgYWNjZXNzClsg
ICAgMC40MTYyMzZdIEh1Z2VUTEIgcmVnaXN0ZXJlZCAyLjAwIE1pQiBwYWdlIHNpemUsIHBy
ZS1hbGxvY2F0ZWQgMCBwYWdlcwpbICAgIDAuNDE3MTY3XSBjcnlwdGQ6IG1heF9jcHVfcWxl
biBzZXQgdG8gMTAwMApbICAgIDAuNDE3NzY2XSBBQ1BJOiBBZGRlZCBfT1NJKE1vZHVsZSBE
ZXZpY2UpClsgICAgMC40MTgxMzZdIEFDUEk6IEFkZGVkIF9PU0koUHJvY2Vzc29yIERldmlj
ZSkKWyAgICAwLjQxODYwNF0gQUNQSTogQWRkZWQgX09TSSgzLjAgX1NDUCBFeHRlbnNpb25z
KQpbICAgIDAuNDE5MTM0XSBBQ1BJOiBBZGRlZCBfT1NJKFByb2Nlc3NvciBBZ2dyZWdhdG9y
IERldmljZSkKWyAgICAwLjQyMDEzNF0gQUNQSTogQWRkZWQgX09TSShMaW51eC1EZWxsLVZp
ZGVvKQpbICAgIDAuNDIwMTM3XSBBQ1BJOiBBZGRlZCBfT1NJKExpbnV4LUxlbm92by1OVi1I
RE1JLUF1ZGlvKQpbICAgIDAuNDIwNjkxXSBBQ1BJOiBBZGRlZCBfT1NJKExpbnV4LUhQSS1I
eWJyaWQtR3JhcGhpY3MpClsgICAgMC40MjQ3NTJdIEFDUEk6IDEgQUNQSSBBTUwgdGFibGVz
IHN1Y2Nlc3NmdWxseSBhY3F1aXJlZCBhbmQgbG9hZGVkClsgICAgMC40MjgyNDBdIEFDUEk6
IEludGVycHJldGVyIGVuYWJsZWQKWyAgICAwLjQyODY3NV0gQUNQSTogKHN1cHBvcnRzIFMw
IFMzIFM1KQpbICAgIDAuNDI5MDc5XSBBQ1BJOiBVc2luZyBJT0FQSUMgZm9yIGludGVycnVw
dCByb3V0aW5nClsgICAgMC40MzAxNzBdIFBDSTogVXNpbmcgaG9zdCBicmlkZ2Ugd2luZG93
cyBmcm9tIEFDUEk7IGlmIG5lY2Vzc2FyeSwgdXNlICJwY2k9bm9jcnMiIGFuZCByZXBvcnQg
YSBidWcKWyAgICAwLjQzMTQ3OV0gQUNQSTogRW5hYmxlZCAzIEdQRXMgaW4gYmxvY2sgMDAg
dG8gMEYKWyAgICAwLjQ1NDcyNF0gQUNQSTogUENJIFJvb3QgQnJpZGdlIFtQQ0kwXSAoZG9t
YWluIDAwMDAgW2J1cyAwMC1mZl0pClsgICAgMC40NTUxNDNdIGFjcGkgUE5QMEEwMzowMDog
X09TQzogT1Mgc3VwcG9ydHMgW0FTUE0gQ2xvY2tQTSBTZWdtZW50cyBNU0ldClsgICAgMC40
NTYyMjBdIGFjcGkgUE5QMEEwMzowMDogZmFpbCB0byBhZGQgTU1DT05GSUcgaW5mb3JtYXRp
b24sIGNhbid0IGFjY2VzcyBleHRlbmRlZCBQQ0kgY29uZmlndXJhdGlvbiBzcGFjZSB1bmRl
ciB0aGlzIGJyaWRnZS4KWyAgICAwLjQ1ODMzNl0gUENJIGhvc3QgYnJpZGdlIHRvIGJ1cyAw
MDAwOjAwClsgICAgMC40NTg3ODRdIHBjaV9idXMgMDAwMDowMDogcm9vdCBidXMgcmVzb3Vy
Y2UgW2lvICAweDAwMDAtMHgwY2Y3IHdpbmRvd10KWyAgICAwLjQ4MzE0OV0gcGNpX2J1cyAw
MDAwOjAwOiByb290IGJ1cyByZXNvdXJjZSBbaW8gIDB4MGQwMC0weGZmZmYgd2luZG93XQpb
ICAgIDAuNDg0MTM2XSBwY2lfYnVzIDAwMDA6MDA6IHJvb3QgYnVzIHJlc291cmNlIFttZW0g
MHgwMDBhMDAwMC0weDAwMGJmZmZmIHdpbmRvd10KWyAgICAwLjQ4NDEzNl0gcGNpX2J1cyAw
MDAwOjAwOiByb290IGJ1cyByZXNvdXJjZSBbbWVtIDB4MjAwMDAwMDAtMHhmZWJmZmZmZiB3
aW5kb3ddClsgICAgMC40ODQ4ODJdIHBjaV9idXMgMDAwMDowMDogcm9vdCBidXMgcmVzb3Vy
Y2UgW2J1cyAwMC1mZl0KWyAgICAwLjQ4NjIzNV0gcGNpIDAwMDA6MDA6MDAuMDogWzgwODY6
MTIzN10gdHlwZSAwMCBjbGFzcyAweDA2MDAwMApbICAgIDAuNDg3MjA1XSBwY2kgMDAwMDow
MDowMS4wOiBbODA4Njo3MDAwXSB0eXBlIDAwIGNsYXNzIDB4MDYwMTAwClsgICAgMC40ODg2
MjNdIHBjaSAwMDAwOjAwOjAxLjE6IFs4MDg2OjcwMTBdIHR5cGUgMDAgY2xhc3MgMHgwMTAx
ODAKWyAgICAwLjUxOTE0MF0gcGNpIDAwMDA6MDA6MDEuMTogcmVnIDB4MjA6IFtpbyAgMHhj
MDQwLTB4YzA0Zl0KWyAgICAwLjUyNzE2MV0gcGNpIDAwMDA6MDA6MDEuMTogbGVnYWN5IElE
RSBxdWlyazogcmVnIDB4MTA6IFtpbyAgMHgwMWYwLTB4MDFmN10KWyAgICAwLjUyNzkwNV0g
cGNpIDAwMDA6MDA6MDEuMTogbGVnYWN5IElERSBxdWlyazogcmVnIDB4MTQ6IFtpbyAgMHgw
M2Y2XQpbICAgIDAuNTI5MTM3XSBwY2kgMDAwMDowMDowMS4xOiBsZWdhY3kgSURFIHF1aXJr
OiByZWcgMHgxODogW2lvICAweDAxNzAtMHgwMTc3XQpbICAgIDAuNTI5MTM3XSBwY2kgMDAw
MDowMDowMS4xOiBsZWdhY3kgSURFIHF1aXJrOiByZWcgMHgxYzogW2lvICAweDAzNzZdClsg
ICAgMC41MzA1NzZdIHBjaSAwMDAwOjAwOjAxLjM6IFs4MDg2OjcxMTNdIHR5cGUgMDAgY2xh
c3MgMHgwNjgwMDAKWyAgICAwLjUzMTU0M10gcGNpIDAwMDA6MDA6MDEuMzogcXVpcms6IFtp
byAgMHgwNjAwLTB4MDYzZl0gY2xhaW1lZCBieSBQSUlYNCBBQ1BJClsgICAgMC41MzIxNDVd
IHBjaSAwMDAwOjAwOjAxLjM6IHF1aXJrOiBbaW8gIDB4MDcwMC0weDA3MGZdIGNsYWltZWQg
YnkgUElJWDQgU01CClsgICAgMC41MzM1OTRdIHBjaSAwMDAwOjAwOjAyLjA6IFsxMjM0OjEx
MTFdIHR5cGUgMDAgY2xhc3MgMHgwMzAwMDAKWyAgICAwLjU0MDE0MV0gcGNpIDAwMDA6MDA6
MDIuMDogcmVnIDB4MTA6IFttZW0gMHhmZDAwMDAwMC0weGZkZmZmZmZmIHByZWZdClsgICAg
MC41NDYxNDBdIHBjaSAwMDAwOjAwOjAyLjA6IHJlZyAweDE4OiBbbWVtIDB4ZmViZjAwMDAt
MHhmZWJmMGZmZl0KWyAgICAwLjU2NjE0NF0gcGNpIDAwMDA6MDA6MDIuMDogcmVnIDB4MzA6
IFttZW0gMHhmZWJlMDAwMC0weGZlYmVmZmZmIHByZWZdClsgICAgMC41Njc1OTBdIHBjaSAw
MDAwOjAwOjAzLjA6IFs4MDg2OjEwMGVdIHR5cGUgMDAgY2xhc3MgMHgwMjAwMDAKWyAgICAw
LjU3MDEzN10gcGNpIDAwMDA6MDA6MDMuMDogcmVnIDB4MTA6IFttZW0gMHhmZWJjMDAwMC0w
eGZlYmRmZmZmXQpbICAgIDAuNTcyMTM2XSBwY2kgMDAwMDowMDowMy4wOiByZWcgMHgxNDog
W2lvICAweGMwMDAtMHhjMDNmXQpbICAgIDAuNTg3MTM3XSBwY2kgMDAwMDowMDowMy4wOiBy
ZWcgMHgzMDogW21lbSAweGZlYjgwMDAwLTB4ZmViYmZmZmYgcHJlZl0KWyAgICAwLjU4NzY2
NF0gcGNpIDAwMDA6MDA6MDQuMDogWzgwODY6MjVhYl0gdHlwZSAwMCBjbGFzcyAweDA4ODAw
MApbICAgIDAuNTg4NzI0XSBwY2kgMDAwMDowMDowNC4wOiByZWcgMHgxMDogW21lbSAweGZl
YmYxMDAwLTB4ZmViZjEwMGZdClsgICAgMC42MDYzMDhdIEFDUEk6IFBDSSBJbnRlcnJ1cHQg
TGluayBbTE5LQV0gKElSUXMgNSAqMTAgMTEpClsgICAgMC42MDcxNzZdIEFDUEk6IFBDSSBJ
bnRlcnJ1cHQgTGluayBbTE5LQl0gKElSUXMgNSAqMTAgMTEpClsgICAgMC42MDc5ODNdIEFD
UEk6IFBDSSBJbnRlcnJ1cHQgTGluayBbTE5LQ10gKElSUXMgNSAxMCAqMTEpClsgICAgMC42
MDkzODRdIEFDUEk6IFBDSSBJbnRlcnJ1cHQgTGluayBbTE5LRF0gKElSUXMgNSAxMCAqMTEp
ClsgICAgMC42MDkzODRdIEFDUEk6IFBDSSBJbnRlcnJ1cHQgTGluayBbTE5LU10gKElSUXMg
KjkpClsgICAgMC42MTEyOTVdIHBjaSAwMDAwOjAwOjAyLjA6IHZnYWFyYjogc2V0dGluZyBh
cyBib290IFZHQSBkZXZpY2UKWyAgICAwLjYxMTkzOV0gcGNpIDAwMDA6MDA6MDIuMDogdmdh
YXJiOiBWR0EgZGV2aWNlIGFkZGVkOiBkZWNvZGVzPWlvK21lbSxvd25zPWlvK21lbSxsb2Nr
cz1ub25lClsgICAgMC42MTMxMzddIHBjaSAwMDAwOjAwOjAyLjA6IHZnYWFyYjogYnJpZGdl
IGNvbnRyb2wgcG9zc2libGUKWyAgICAwLjYxNDEzNV0gdmdhYXJiOiBsb2FkZWQKWyAgICAw
LjYxNDY4M10gdmlkZW9kZXY6IExpbnV4IHZpZGVvIGNhcHR1cmUgaW50ZXJmYWNlOiB2Mi4w
MApbICAgIDAuNjE2MjEyXSBwcHNfY29yZTogTGludXhQUFMgQVBJIHZlci4gMSByZWdpc3Rl
cmVkClsgICAgMC42MTgxNTFdIHBwc19jb3JlOiBTb2Z0d2FyZSB2ZXIuIDUuMy42IC0gQ29w
eXJpZ2h0IDIwMDUtMjAwNyBSb2RvbGZvIEdpb21ldHRpIDxnaW9tZXR0aUBsaW51eC5pdD4K
WyAgICAwLjYyMTE3MF0gUFRQIGNsb2NrIHN1cHBvcnQgcmVnaXN0ZXJlZApbICAgIDAuNjIy
NTc4XSBQQ0k6IFVzaW5nIEFDUEkgZm9yIElSUSByb3V0aW5nClsgICAgMC42MjQxNDldIFBD
STogcGNpX2NhY2hlX2xpbmVfc2l6ZSBzZXQgdG8gNjQgYnl0ZXMKWyAgICAwLjYyNTQ0Ml0g
ZTgyMDogcmVzZXJ2ZSBSQU0gYnVmZmVyIFttZW0gMHgwMDA5ZmMwMC0weDAwMDlmZmZmXQpb
ICAgIDAuNjI4MTczXSBlODIwOiByZXNlcnZlIFJBTSBidWZmZXIgW21lbSAweDFmZmUwMDAw
LTB4MWZmZmZmZmZdClsgICAgMC42MzExMzJdIE5FVDogUmVnaXN0ZXJlZCBwcm90b2NvbCBm
YW1pbHkgOApbICAgIDAuNjQ0MTM5XSBORVQ6IFJlZ2lzdGVyZWQgcHJvdG9jb2wgZmFtaWx5
IDIwClsgICAgMC42NDU0NDhdIEhQRVQ6IDMgdGltZXJzIGluIHRvdGFsLCAwIHRpbWVycyB3
aWxsIGJlIHVzZWQgZm9yIHBlci1jcHUgdGltZXIKWyAgICAwLjY0NzI1N10gY2xvY2tzb3Vy
Y2U6IFN3aXRjaGVkIHRvIGNsb2Nrc291cmNlIGt2bS1jbG9jawpbICAgIDAuNjkyNTkzXSBW
RlM6IERpc2sgcXVvdGFzIGRxdW90XzYuNi4wClsgICAgMC42OTMwNjVdIFZGUzogRHF1b3Qt
Y2FjaGUgaGFzaCB0YWJsZSBlbnRyaWVzOiA1MTIgKG9yZGVyIDAsIDQwOTYgYnl0ZXMpClsg
ICAgMC42OTM5NDVdIHBucDogUG5QIEFDUEkgaW5pdApbICAgIDAuNjk0NDkwXSBwbnAgMDA6
MDA6IFBsdWcgYW5kIFBsYXkgQUNQSSBkZXZpY2UsIElEcyBQTlAwYjAwIChhY3RpdmUpClsg
ICAgMC42OTUyNjldIHBucCAwMDowMTogUGx1ZyBhbmQgUGxheSBBQ1BJIGRldmljZSwgSURz
IFBOUDAzMDMgKGFjdGl2ZSkKWyAgICAwLjY5NjAxM10gcG5wIDAwOjAyOiBQbHVnIGFuZCBQ
bGF5IEFDUEkgZGV2aWNlLCBJRHMgUE5QMGYxMyAoYWN0aXZlKQpbICAgIDAuNjk2NzA1XSBw
bnAgMDA6MDM6IFtkbWEgMl0KWyAgICAwLjY5NzA3NF0gcG5wIDAwOjAzOiBQbHVnIGFuZCBQ
bGF5IEFDUEkgZGV2aWNlLCBJRHMgUE5QMDcwMCAoYWN0aXZlKQpbICAgIDAuNjk3ODg0XSBw
bnAgMDA6MDQ6IFBsdWcgYW5kIFBsYXkgQUNQSSBkZXZpY2UsIElEcyBQTlAwNDAwIChhY3Rp
dmUpClsgICAgMC42OTg2NzldIHBucCAwMDowNTogUGx1ZyBhbmQgUGxheSBBQ1BJIGRldmlj
ZSwgSURzIFBOUDA1MDEgKGFjdGl2ZSkKWyAgICAwLjY5OTQ3NF0gcG5wIDAwOjA2OiBQbHVn
IGFuZCBQbGF5IEFDUEkgZGV2aWNlLCBJRHMgUE5QMDUwMSAoYWN0aXZlKQpbICAgIDAuNzAw
Nzk1XSBwbnA6IFBuUCBBQ1BJOiBmb3VuZCA3IGRldmljZXMKWyAgICAwLjcxOTYxMV0gY2xv
Y2tzb3VyY2U6IGFjcGlfcG06IG1hc2s6IDB4ZmZmZmZmIG1heF9jeWNsZXM6IDB4ZmZmZmZm
LCBtYXhfaWRsZV9uczogMjA4NTcwMTAyNCBucwpbICAgIDAuNzIwNjAzXSBwY2lfYnVzIDAw
MDA6MDA6IHJlc291cmNlIDQgW2lvICAweDAwMDAtMHgwY2Y3IHdpbmRvd10KWyAgICAwLjcy
MTI2NF0gcGNpX2J1cyAwMDAwOjAwOiByZXNvdXJjZSA1IFtpbyAgMHgwZDAwLTB4ZmZmZiB3
aW5kb3ddClsgICAgMC43MjE5MDJdIHBjaV9idXMgMDAwMDowMDogcmVzb3VyY2UgNiBbbWVt
IDB4MDAwYTAwMDAtMHgwMDBiZmZmZiB3aW5kb3ddClsgICAgMC43MjI2MTldIHBjaV9idXMg
MDAwMDowMDogcmVzb3VyY2UgNyBbbWVtIDB4MjAwMDAwMDAtMHhmZWJmZmZmZiB3aW5kb3dd
ClsgICAgMC43MjM1NDBdIE5FVDogUmVnaXN0ZXJlZCBwcm90b2NvbCBmYW1pbHkgMgpbICAg
IDAuNzI0NDEyXSB0Y3BfbGlzdGVuX3BvcnRhZGRyX2hhc2ggaGFzaCB0YWJsZSBlbnRyaWVz
OiAyNTYgKG9yZGVyOiAyLCAxODQzMiBieXRlcykKWyAgICAwLjcyNTI4MF0gVENQIGVzdGFi
bGlzaGVkIGhhc2ggdGFibGUgZW50cmllczogNDA5NiAob3JkZXI6IDMsIDMyNzY4IGJ5dGVz
KQpbICAgIDAuNzI2MDYxXSBUQ1AgYmluZCBoYXNoIHRhYmxlIGVudHJpZXM6IDQwOTYgKG9y
ZGVyOiA2LCAyNjIxNDQgYnl0ZXMpClsgICAgMC43MjY4OTZdIFRDUDogSGFzaCB0YWJsZXMg
Y29uZmlndXJlZCAoZXN0YWJsaXNoZWQgNDA5NiBiaW5kIDQwOTYpClsgICAgMC43MjgzMzNd
IFVEUCBoYXNoIHRhYmxlIGVudHJpZXM6IDI1NiAob3JkZXI6IDMsIDQwOTYwIGJ5dGVzKQpb
ICAgIDAuNzI4OTg1XSBVRFAtTGl0ZSBoYXNoIHRhYmxlIGVudHJpZXM6IDI1NiAob3JkZXI6
IDMsIDQwOTYwIGJ5dGVzKQpbICAgIDAuNzI5NzUwXSBORVQ6IFJlZ2lzdGVyZWQgcHJvdG9j
b2wgZmFtaWx5IDEKWyAgICAwLjczMDM4OV0gcGNpIDAwMDA6MDA6MDEuMDogUElJWDM6IEVu
YWJsaW5nIFBhc3NpdmUgUmVsZWFzZQpbICAgIDAuNzMwOTk3XSBwY2kgMDAwMDowMDowMC4w
OiBMaW1pdGluZyBkaXJlY3QgUENJL1BDSSB0cmFuc2ZlcnMKWyAgICAwLjczMTY2NV0gcGNp
IDAwMDA6MDA6MDEuMDogQWN0aXZhdGluZyBJU0EgRE1BIGhhbmcgd29ya2Fyb3VuZHMKWyAg
ICAwLjczMjQxMl0gcGNpIDAwMDA6MDA6MDIuMDogVmlkZW8gZGV2aWNlIHdpdGggc2hhZG93
ZWQgUk9NIGF0IFttZW0gMHgwMDBjMDAwMC0weDAwMGRmZmZmXQpbICAgIDAuNzMzMjg3XSBQ
Q0k6IENMUyAwIGJ5dGVzLCBkZWZhdWx0IDY0ClsgICAgMC43MzM4NzddIFVucGFja2luZyBp
bml0cmFtZnMuLi4KWyAgICAyLjIyMjgwN10gRnJlZWluZyBpbml0cmQgbWVtb3J5OiAyMzY1
NksKWyAgICAyLjIyMzYyM10gY2xvY2tzb3VyY2U6IHRzYzogbWFzazogMHhmZmZmZmZmZmZm
ZmZmZmZmIG1heF9jeWNsZXM6IDB4MjEyNzMxYTUzMDEsIG1heF9pZGxlX25zOiA0NDA3OTUz
MTcxMjMgbnMKWyAgICAyLjIyNDgyNF0gY2hlY2s6IFNjYW5uaW5nIGZvciBsb3cgbWVtb3J5
IGNvcnJ1cHRpb24gZXZlcnkgNjAgc2Vjb25kcwpbICAgIDIuMjM1OTQxXSBkZXMzX2VkZS14
ODZfNjQ6IHBlcmZvcm1hbmNlIG9uIHRoaXMgQ1BVIHdvdWxkIGJlIHN1Ym9wdGltYWw6IGRp
c2FibGluZyBkZXMzX2VkZS14ODZfNjQuClsgICAgMi4yMzY4ODJdIGJsb3dmaXNoLXg4Nl82
NDogcGVyZm9ybWFuY2Ugb24gdGhpcyBDUFUgd291bGQgYmUgc3Vib3B0aW1hbDogZGlzYWJs
aW5nIGJsb3dmaXNoLXg4Nl82NC4KWyAgICAyLjIzOTIzM10gdHdvZmlzaC14ODZfNjQtM3dh
eTogcGVyZm9ybWFuY2Ugb24gdGhpcyBDUFUgd291bGQgYmUgc3Vib3B0aW1hbDogZGlzYWJs
aW5nIHR3b2Zpc2gteDg2XzY0LTN3YXkuClsgICAgMi4yNDAyNjNdIENQVSBmZWF0dXJlICdB
VlggcmVnaXN0ZXJzJyBpcyBub3Qgc3VwcG9ydGVkLgpbICAgIDIuMjQwODA0XSBDUFUgZmVh
dHVyZSAnQVZYIHJlZ2lzdGVycycgaXMgbm90IHN1cHBvcnRlZC4KWyAgICAyLjI0MTM3Nl0g
Q1BVIGZlYXR1cmUgJ0FWWCByZWdpc3RlcnMnIGlzIG5vdCBzdXBwb3J0ZWQuClsgICAgOC44
NTI4MDldIEluaXRpYWxpc2Ugc3lzdGVtIHRydXN0ZWQga2V5cmluZ3MKWyAgICA4Ljg1NDcx
NF0gd29ya2luZ3NldDogdGltZXN0YW1wX2JpdHM9NTYgbWF4X29yZGVyPTE3IGJ1Y2tldF9v
cmRlcj0wClsgICAgOC44NTcyNTVdIG9yYW5nZWZzX2RlYnVnZnNfaW5pdDogY2FsbGVkIHdp
dGggZGVidWcgbWFzazogOm5vbmU6IDowOgpbICAgIDguODU4MzM3XSBvcmFuZ2Vmc19pbml0
OiBtb2R1bGUgdmVyc2lvbiB1cHN0cmVhbSBsb2FkZWQKWyAgICA4Ljg4MDc3N10gTkVUOiBS
ZWdpc3RlcmVkIHByb3RvY29sIGZhbWlseSAzOApbICAgIDguODgxOTk0XSBLZXkgdHlwZSBh
c3ltbWV0cmljIHJlZ2lzdGVyZWQKWyAgICA5LjAwNjYyMl0gU3RyaW5nIHNlbGZ0ZXN0cyBz
dWNjZWVkZWQKWyAgICA5LjAwNzQ3MF0gZ3Bpb19pdDg3OiBubyBkZXZpY2UKWyAgICA5LjAw
ODA1N10gZ3Bpb193aW5ib25kOiBjaGlwIElEIGF0IDJlIGlzIGZmZmYKWyAgICA5LjAwODUz
M10gZ3Bpb193aW5ib25kOiBub3QgYW4gb3VyIGNoaXAKWyAgICA5LjAwODk2MV0gZ3Bpb193
aW5ib25kOiBjaGlwIElEIGF0IDRlIGlzIGZmZmYKWyAgICA5LjAwOTQ1MV0gZ3Bpb193aW5i
b25kOiBub3QgYW4gb3VyIGNoaXAKWyAgICA5LjAyMzIyOV0gc2hwY2hwOiBTdGFuZGFyZCBI
b3QgUGx1ZyBQQ0kgQ29udHJvbGxlciBEcml2ZXIgdmVyc2lvbjogMC40ClsgICAgOS4wMjQw
MjddIHN3aXRjaHRlYzogbG9hZGVkLgpbICAgIDkuMDI0NzA4XSBpbnB1dDogUG93ZXIgQnV0
dG9uIGFzIC9kZXZpY2VzL0xOWFNZU1RNOjAwL0xOWFBXUkJOOjAwL2lucHV0L2lucHV0MApb
ICAgIDkuMDMyMjMxXSBBQ1BJOiBQb3dlciBCdXR0b24gW1BXUkZdClsgICAgOS4wMzMwNThd
IGlucHV0OiBQb3dlciBCdXR0b24gYXMgL2RldmljZXMvTE5YU1lTVE06MDAvTE5YUFdSQk46
MDAvaW5wdXQvaW5wdXQxClsgICAgOS4wMzM5MThdIEFDUEk6IFBvd2VyIEJ1dHRvbiBbUFdS
Rl0KWyAgICA5LjAzNDQxNF0gV2FybmluZzogUHJvY2Vzc29yIFBsYXRmb3JtIExpbWl0IGV2
ZW50IGRldGVjdGVkLCBidXQgbm90IGhhbmRsZWQuClsgICAgOS4wMzUxNTNdIENvbnNpZGVy
IGNvbXBpbGluZyBDUFVmcmVxIHN1cHBvcnQgaW50byB5b3VyIGtlcm5lbC4KWyAgICA5LjA0
OTY1MF0gaW9hdGRtYTogSW50ZWwoUikgUXVpY2tEYXRhIFRlY2hub2xvZ3kgRHJpdmVyIDQu
MDAKWyAgICA5LjA1MDgwNV0gU2VyaWFsOiA4MjUwLzE2NTUwIGRyaXZlciwgNCBwb3J0cywg
SVJRIHNoYXJpbmcgZGlzYWJsZWQKWyAgICA5LjA4NDUxNF0gMDA6MDU6IHR0eVMwIGF0IEkv
TyAweDNmOCAoaXJxID0gNCwgYmFzZV9iYXVkID0gMTE1MjAwKSBpcyBhIDE2NTUwQQpbICAg
IDkuMDg3OTM1XSBwcmludGs6IGNvbnNvbGUgW3R0eVMwXSBkaXNhYmxlZApbICAgIDAuMDAw
MDAwXSBMaW51eCB2ZXJzaW9uIDUuMC4wLXJjNC0wMDE1MC1nYjUyM2FiMSAoa2J1aWxkQGxr
cC1oc3gwMykgKGdjYyB2ZXJzaW9uIDYuNS4wIDIwMTgxMDI2IChEZWJpYW4gNi41LjAtMikp
ICMxIFNNUCBQUkVFTVBUIE1vbiBGZWIgMTggMTU6NTc6NTUgQ1NUIDIwMTkKWyAgICAwLjAw
MDAwMF0gQ29tbWFuZCBsaW5lOiByb290PS9kZXYvcmFtMCBodW5nX3Rhc2tfcGFuaWM9MSBk
ZWJ1ZyBhcGljPWRlYnVnIHN5c3JxX2Fsd2F5c19lbmFibGVkIHJjdXBkYXRlLnJjdV9jcHVf
c3RhbGxfdGltZW91dD0xMDAgbmV0LmlmbmFtZXM9MCBwcmludGsuZGV2a21zZz1vbiBwYW5p
Yz0tMSBzb2Z0bG9ja3VwX3BhbmljPTEgbm1pX3dhdGNoZG9nPXBhbmljIG9vcHM9cGFuaWMg
bG9hZF9yYW1kaXNrPTIgcHJvbXB0X3JhbWRpc2s9MCBkcmJkLm1pbm9yX2NvdW50PTggc3lz
dGVtZC5sb2dfbGV2ZWw9ZXJyIGlnbm9yZV9sb2dsZXZlbCBjb25zb2xlPXR0eTAgZWFybHlw
cmludGs9dHR5UzAsMTE1MjAwIGNvbnNvbGU9dHR5UzAsMTE1MjAwIHZnYT1ub3JtYWwgcncg
bGluaz0vY2VwaGZzL2tidWlsZC9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLXMy
LTAyMTcyMzE4L2xpbnV4LWRldmVsOmZpeHVwLWVmYWQ0ZTQ3NWMzMTI0NTZlZGIzYzc4OWQw
OTk2ZDEyZWQ3NDRjMTM6YjUyM2FiMWI4Y2U1OTU5MmNiMzJkNjIyNTAzMjE3MDc3Y2YwN2U0
ZC8udm1saW51ei1iNTIzYWIxYjhjZTU5NTkyY2IzMmQ2MjI1MDMyMTcwNzdjZjA3ZTRkLTIw
MTkwMjE4MTYwMDEyLTEwNDpxdWFudGFsLXZtLXF1YW50YWwtNjA3IGJyYW5jaD1saW51eC1k
ZXZlbC9maXh1cC1lZmFkNGU0NzVjMzEyNDU2ZWRiM2M3ODlkMDk5NmQxMmVkNzQ0YzEzIEJP
T1RfSU1BR0U9L3BrZy9saW51eC94ODZfNjQtcmFuZGNvbmZpZy1zMi0wMjE3MjMxOC9nY2Mt
Ni9iNTIzYWIxYjhjZTU5NTkyY2IzMmQ2MjI1MDMyMTcwNzdjZjA3ZTRkL3ZtbGludXotNS4w
LjAtcmM0LTAwMTUwLWdiNTIzYWIxIGRyYmQubWlub3JfY291bnQ9OCByY3VwZXJmLnNodXRk
b3duPTAKWyAgICAwLjAwMDAwMF0gS0VSTkVMIHN1cHBvcnRlZCBjcHVzOgpbICAgIDAuMDAw
MDAwXSAgIEludGVsIEdlbnVpbmVJbnRlbApbICAgIDAuMDAwMDAwXSB4ODYvZnB1OiB4ODcg
RlBVIHdpbGwgdXNlIEZYU0FWRQpbICAgIDAuMDAwMDAwXSBCSU9TLXByb3ZpZGVkIHBoeXNp
Y2FsIFJBTSBtYXA6ClsgICAgMC4wMDAwMDBdIEJJT1MtZTgyMDogW21lbSAweDAwMDAwMDAw
MDAwMDAwMDAtMHgwMDAwMDAwMDAwMDlmYmZmXSB1c2FibGUKWyAgICAwLjAwMDAwMF0gQklP
Uy1lODIwOiBbbWVtIDB4MDAwMDAwMDAwMDA5ZmMwMC0weDAwMDAwMDAwMDAwOWZmZmZdIHJl
c2VydmVkClsgICAgMC4wMDAwMDBdIEJJT1MtZTgyMDogW21lbSAweDAwMDAwMDAwMDAwZjAw
MDAtMHgwMDAwMDAwMDAwMGZmZmZmXSByZXNlcnZlZApbICAgIDAuMDAwMDAwXSBCSU9TLWU4
MjA6IFttZW0gMHgwMDAwMDAwMDAwMTAwMDAwLTB4MDAwMDAwMDAxZmZkZmZmZl0gdXNhYmxl
ClsgICAgMC4wMDAwMDBdIEJJT1MtZTgyMDogW21lbSAweDAwMDAwMDAwMWZmZTAwMDAtMHgw
MDAwMDAwMDFmZmZmZmZmXSByZXNlcnZlZApbICAgIDAuMDAwMDAwXSBCSU9TLWU4MjA6IFtt
ZW0gMHgwMDAwMDAwMGZlZmZjMDAwLTB4MDAwMDAwMDBmZWZmZmZmZl0gcmVzZXJ2ZWQKWyAg
ICAwLjAwMDAwMF0gQklPUy1lODIwOiBbbWVtIDB4MDAwMDAwMDBmZmZjMDAwMC0weDAwMDAw
MDAwZmZmZmZmZmZdIHJlc2VydmVkClsgICAgMC4wMDAwMDBdIHByaW50azogZGVidWc6IGln
bm9yaW5nIGxvZ2xldmVsIHNldHRpbmcuClsgICAgMC4wMDAwMDBdIE5YIChFeGVjdXRlIERp
c2FibGUpIHByb3RlY3Rpb246IGFjdGl2ZQpbICAgIDAuMDAwMDAwXSBTTUJJT1MgMi44IHBy
ZXNlbnQuClsgICAgMC4wMDAwMDBdIERNSTogUUVNVSBTdGFuZGFyZCBQQyAoaTQ0MEZYICsg
UElJWCwgMTk5NiksIEJJT1MgMS4xMC4yLTEgMDQvMDEvMjAxNApbICAgIDAuMDAwMDAwXSBI
eXBlcnZpc29yIGRldGVjdGVkOiBLVk0KWyAgICAwLjAwMDAwMF0ga3ZtLWNsb2NrOiBVc2lu
ZyBtc3JzIDRiNTY0ZDAxIGFuZCA0YjU2NGQwMApbICAgIDAuMDAwMDAwXSBrdm0tY2xvY2s6
IGNwdSAwLCBtc3IgMjg4NzAwMSwgcHJpbWFyeSBjcHUgY2xvY2sKWyAgICAwLjAwMDAwMF0g
a3ZtLWNsb2NrOiB1c2luZyBzY2hlZCBvZmZzZXQgb2YgMTYwNTY2MDkyOSBjeWNsZXMKWyAg
ICAwLjAwMDAwNF0gY2xvY2tzb3VyY2U6IGt2bS1jbG9jazogbWFzazogMHhmZmZmZmZmZmZm
ZmZmZmZmIG1heF9jeWNsZXM6IDB4MWNkNDJlNGRmZmIsIG1heF9pZGxlX25zOiA4ODE1OTA1
OTE0ODMgbnMKWyAgICAwLjAwMDAxMF0gdHNjOiBEZXRlY3RlZCAyMjk5Ljk5NiBNSHogcHJv
Y2Vzc29yClsgICAgMC4wMDE3MjBdIGU4MjA6IHVwZGF0ZSBbbWVtIDB4MDAwMDAwMDAtMHgw
MDAwMGZmZl0gdXNhYmxlID09PiByZXNlcnZlZApbICAgIDAuMDAxNzI0XSBlODIwOiByZW1v
dmUgW21lbSAweDAwMGEwMDAwLTB4MDAwZmZmZmZdIHVzYWJsZQpbICAgIDAuMDAxNzI5XSBs
YXN0X3BmbiA9IDB4MWZmZTAgbWF4X2FyY2hfcGZuID0gMHg0MDAwMDAwMDAKWyAgICAwLjAw
MTczM10geDg2L1BBVDogQ29uZmlndXJhdGlvbiBbMC03XTogV0IgIFdUICBVQy0gVUMgIFdC
ICBXVCAgVUMtIFVDICAKWyAgICAwLjAwMTczNl0gU2NhbiBmb3IgU01QIGluIFttZW0gMHgw
MDAwMDAwMC0weDAwMDAwM2ZmXQpbICAgIDAuMDAxNzU3XSBTY2FuIGZvciBTTVAgaW4gW21l
bSAweDAwMDlmYzAwLTB4MDAwOWZmZmZdClsgICAgMC4wMDE3NzldIFNjYW4gZm9yIFNNUCBp
biBbbWVtIDB4MDAwZjAwMDAtMHgwMDBmZmZmZl0KWyAgICAwLjAwNjEzNV0gZm91bmQgU01Q
IE1QLXRhYmxlIGF0IFttZW0gMHgwMDBmNmE4MC0weDAwMGY2YThmXSBtYXBwZWQgYXQgWyhf
X19fcHRydmFsX19fXyldClsgICAgMC4wMDYxMzldICAgbXBjOiBmNmE5MC1mNmI3NApbICAg
IDAuMDA2MTgyXSBjaGVjazogU2Nhbm5pbmcgMSBhcmVhcyBmb3IgbG93IG1lbW9yeSBjb3Jy
dXB0aW9uClsgICAgMC4wMDYxODZdIEJhc2UgbWVtb3J5IHRyYW1wb2xpbmUgYXQgWyhfX19f
cHRydmFsX19fXyldIDk5MDAwIHNpemUgMjQ1NzYKWyAgICAwLjAwNjIzN10gQlJLIFsweDAz
NjAxMDAwLCAweDAzNjAxZmZmXSBQR1RBQkxFClsgICAgMC4wMDYyNDFdIEJSSyBbMHgwMzYw
MjAwMCwgMHgwMzYwMmZmZl0gUEdUQUJMRQpbICAgIDAuMDA2MjQzXSBCUksgWzB4MDM2MDMw
MDAsIDB4MDM2MDNmZmZdIFBHVEFCTEUKWyAgICAwLjAwNjQwM10gQlJLIFsweDAzNjA0MDAw
LCAweDAzNjA0ZmZmXSBQR1RBQkxFClsgICAgMC4wMDY0MzFdIFJBTURJU0s6IFttZW0gMHgx
ZThjNjAwMC0weDFmZmRmZmZmXQpbICAgIDAuMDA2NDQ5XSBBQ1BJOiBFYXJseSB0YWJsZSBj
aGVja3N1bSB2ZXJpZmljYXRpb24gZGlzYWJsZWQKWyAgICAwLjAwNjQ5Ml0gQUNQSTogUlNE
UCAweDAwMDAwMDAwMDAwRjY4NzAgMDAwMDE0ICh2MDAgQk9DSFMgKQpbICAgIDAuMDA2NDk3
XSBBQ1BJOiBSU0RUIDB4MDAwMDAwMDAxRkZFMTkzNiAwMDAwMzAgKHYwMSBCT0NIUyAgQlhQ
Q1JTRFQgMDAwMDAwMDEgQlhQQyAwMDAwMDAwMSkKWyAgICAwLjAwNjUwM10gQUNQSTogRkFD
UCAweDAwMDAwMDAwMUZGRTE4MEEgMDAwMDc0ICh2MDEgQk9DSFMgIEJYUENGQUNQIDAwMDAw
MDAxIEJYUEMgMDAwMDAwMDEpClsgICAgMC4wMDY1MDldIEFDUEk6IERTRFQgMHgwMDAwMDAw
MDFGRkUwMDQwIDAwMTdDQSAodjAxIEJPQ0hTICBCWFBDRFNEVCAwMDAwMDAwMSBCWFBDIDAw
MDAwMDAxKQpbICAgIDAuMDA2NTEzXSBBQ1BJOiBGQUNTIDB4MDAwMDAwMDAxRkZFMDAwMCAw
MDAwNDAKWyAgICAwLjAwNjUxN10gQUNQSTogQVBJQyAweDAwMDAwMDAwMUZGRTE4N0UgMDAw
MDgwICh2MDEgQk9DSFMgIEJYUENBUElDIDAwMDAwMDAxIEJYUEMgMDAwMDAwMDEpClsgICAg
MC4wMDY1MjFdIEFDUEk6IEhQRVQgMHgwMDAwMDAwMDFGRkUxOEZFIDAwMDAzOCAodjAxIEJP
Q0hTICBCWFBDSFBFVCAwMDAwMDAwMSBCWFBDIDAwMDAwMDAxKQpbICAgIDAuMDA2NTI4XSBB
Q1BJOiBMb2NhbCBBUElDIGFkZHJlc3MgMHhmZWUwMDAwMApbICAgIDAuMDA2NTMzXSBtYXBw
ZWQgQVBJQyB0byBmZmZmZmZmZmZmNWZkMDAwICggICAgICAgIGZlZTAwMDAwKQpbICAgIDAu
MDA2ODQ1XSBObyBOVU1BIGNvbmZpZ3VyYXRpb24gZm91bmQKWyAgICAwLjAwNjg0OF0gRmFr
aW5nIGEgbm9kZSBhdCBbbWVtIDB4MDAwMDAwMDAwMDAwMDAwMC0weDAwMDAwMDAwMWZmZGZm
ZmZdClsgICAgMC4wMDY4NTNdIE5PREVfREFUQSgwKSBhbGxvY2F0ZWQgW21lbSAweDFlOGMz
MDAwLTB4MWU4YzVmZmZdClsgICAgMC4wMDk2MjNdIFpvbmUgcmFuZ2VzOgpbICAgIDAuMDA5
NjI3XSAgIERNQTMyICAgIFttZW0gMHgwMDAwMDAwMDAwMDAxMDAwLTB4MDAwMDAwMDAxZmZk
ZmZmZl0KWyAgICAwLjAwOTYyOV0gICBOb3JtYWwgICBlbXB0eQpbICAgIDAuMDA5NjMyXSBN
b3ZhYmxlIHpvbmUgc3RhcnQgZm9yIGVhY2ggbm9kZQpbICAgIDAuMDA5NjM0XSBFYXJseSBt
ZW1vcnkgbm9kZSByYW5nZXMKWyAgICAwLjAwOTYzNl0gICBub2RlICAgMDogW21lbSAweDAw
MDAwMDAwMDAwMDEwMDAtMHgwMDAwMDAwMDAwMDllZmZmXQpbICAgIDAuMDA5NjM4XSAgIG5v
ZGUgICAwOiBbbWVtIDB4MDAwMDAwMDAwMDEwMDAwMC0weDAwMDAwMDAwMWZmZGZmZmZdClsg
ICAgMC4wMDk2NDNdIFplcm9lZCBzdHJ1Y3QgcGFnZSBpbiB1bmF2YWlsYWJsZSByYW5nZXM6
IDk4IHBhZ2VzClsgICAgMC4wMDk2NDRdIEluaXRtZW0gc2V0dXAgbm9kZSAwIFttZW0gMHgw
MDAwMDAwMDAwMDAxMDAwLTB4MDAwMDAwMDAxZmZkZmZmZl0KWyAgICAwLjAwOTY0N10gT24g
bm9kZSAwIHRvdGFscGFnZXM6IDEzMDk0MgpbICAgIDAuMDA5NjUwXSAgIERNQTMyIHpvbmU6
IDE3OTIgcGFnZXMgdXNlZCBmb3IgbWVtbWFwClsgICAgMC4wMDk2NTJdICAgRE1BMzIgem9u
ZTogMjEgcGFnZXMgcmVzZXJ2ZWQKWyAgICAwLjAwOTY1NF0gICBETUEzMiB6b25lOiAxMzA5
NDIgcGFnZXMsIExJRk8gYmF0Y2g6MzEKWyAgICAwLjAxMjQyOV0gQUNQSTogUE0tVGltZXIg
SU8gUG9ydDogMHg2MDgKWyAgICAwLjAxMjQzM10gQUNQSTogTG9jYWwgQVBJQyBhZGRyZXNz
IDB4ZmVlMDAwMDAKWyAgICAwLjAxMjQzOV0gQUNQSTogTEFQSUNfTk1JIChhY3BpX2lkWzB4
ZmZdIGRmbCBkZmwgbGludFsweDFdKQpbICAgIDAuMDEyNDc0XSBJT0FQSUNbMF06IGFwaWNf
aWQgMCwgdmVyc2lvbiAxNywgYWRkcmVzcyAweGZlYzAwMDAwLCBHU0kgMC0yMwpbICAgIDAu
MDEyNDgyXSBBQ1BJOiBJTlRfU1JDX09WUiAoYnVzIDAgYnVzX2lycSAwIGdsb2JhbF9pcnEg
MiBkZmwgZGZsKQpbICAgIDAuMDEyNDg2XSBJbnQ6IHR5cGUgMCwgcG9sIDAsIHRyaWcgMCwg
YnVzIDAwLCBJUlEgMDAsIEFQSUMgSUQgMCwgQVBJQyBJTlQgMDIKWyAgICAwLjAxMjQ4OV0g
QUNQSTogSU5UX1NSQ19PVlIgKGJ1cyAwIGJ1c19pcnEgNSBnbG9iYWxfaXJxIDUgaGlnaCBs
ZXZlbCkKWyAgICAwLjAxMjQ5MV0gSW50OiB0eXBlIDAsIHBvbCAxLCB0cmlnIDMsIGJ1cyAw
MCwgSVJRIDA1LCBBUElDIElEIDAsIEFQSUMgSU5UIDA1ClsgICAgMC4wMTI0OTRdIEFDUEk6
IElOVF9TUkNfT1ZSIChidXMgMCBidXNfaXJxIDkgZ2xvYmFsX2lycSA5IGhpZ2ggbGV2ZWwp
ClsgICAgMC4wMTI0OTZdIEludDogdHlwZSAwLCBwb2wgMSwgdHJpZyAzLCBidXMgMDAsIElS
USAwOSwgQVBJQyBJRCAwLCBBUElDIElOVCAwOQpbICAgIDAuMDEyNDk5XSBBQ1BJOiBJTlRf
U1JDX09WUiAoYnVzIDAgYnVzX2lycSAxMCBnbG9iYWxfaXJxIDEwIGhpZ2ggbGV2ZWwpClsg
ICAgMC4wMTI1MDJdIEludDogdHlwZSAwLCBwb2wgMSwgdHJpZyAzLCBidXMgMDAsIElSUSAw
YSwgQVBJQyBJRCAwLCBBUElDIElOVCAwYQpbICAgIDAuMDEyNTA0XSBBQ1BJOiBJTlRfU1JD
X09WUiAoYnVzIDAgYnVzX2lycSAxMSBnbG9iYWxfaXJxIDExIGhpZ2ggbGV2ZWwpClsgICAg
MC4wMTI1MDddIEludDogdHlwZSAwLCBwb2wgMSwgdHJpZyAzLCBidXMgMDAsIElSUSAwYiwg
QVBJQyBJRCAwLCBBUElDIElOVCAwYgpbICAgIDAuMDEyNTA5XSBBQ1BJOiBJUlEwIHVzZWQg
Ynkgb3ZlcnJpZGUuClsgICAgMC4wMTI1MTJdIEludDogdHlwZSAwLCBwb2wgMCwgdHJpZyAw
LCBidXMgMDAsIElSUSAwMSwgQVBJQyBJRCAwLCBBUElDIElOVCAwMQpbICAgIDAuMDEyNTE0
XSBJbnQ6IHR5cGUgMCwgcG9sIDAsIHRyaWcgMCwgYnVzIDAwLCBJUlEgMDMsIEFQSUMgSUQg
MCwgQVBJQyBJTlQgMDMKWyAgICAwLjAxMjUxN10gSW50OiB0eXBlIDAsIHBvbCAwLCB0cmln
IDAsIGJ1cyAwMCwgSVJRIDA0LCBBUElDIElEIDAsIEFQSUMgSU5UIDA0ClsgICAgMC4wMTI1
MTldIEFDUEk6IElSUTUgdXNlZCBieSBvdmVycmlkZS4KWyAgICAwLjAxMjUyMl0gSW50OiB0
eXBlIDAsIHBvbCAwLCB0cmlnIDAsIGJ1cyAwMCwgSVJRIDA2LCBBUElDIElEIDAsIEFQSUMg
SU5UIDA2ClsgICAgMC4wMTI1MjRdIEludDogdHlwZSAwLCBwb2wgMCwgdHJpZyAwLCBidXMg
MDAsIElSUSAwNywgQVBJQyBJRCAwLCBBUElDIElOVCAwNwpbICAgIDAuMDEyNTI3XSBJbnQ6
IHR5cGUgMCwgcG9sIDAsIHRyaWcgMCwgYnVzIDAwLCBJUlEgMDgsIEFQSUMgSUQgMCwgQVBJ
QyBJTlQgMDgKWyAgICAwLjAxMjUyOV0gQUNQSTogSVJROSB1c2VkIGJ5IG92ZXJyaWRlLgpb
ICAgIDAuMDEyNTMxXSBBQ1BJOiBJUlExMCB1c2VkIGJ5IG92ZXJyaWRlLgpbICAgIDAuMDEy
NTMzXSBBQ1BJOiBJUlExMSB1c2VkIGJ5IG92ZXJyaWRlLgpbICAgIDAuMDEyNTM2XSBJbnQ6
IHR5cGUgMCwgcG9sIDAsIHRyaWcgMCwgYnVzIDAwLCBJUlEgMGMsIEFQSUMgSUQgMCwgQVBJ
QyBJTlQgMGMKWyAgICAwLjAxMjUzOF0gSW50OiB0eXBlIDAsIHBvbCAwLCB0cmlnIDAsIGJ1
cyAwMCwgSVJRIDBkLCBBUElDIElEIDAsIEFQSUMgSU5UIDBkClsgICAgMC4wMTI1NDFdIElu
dDogdHlwZSAwLCBwb2wgMCwgdHJpZyAwLCBidXMgMDAsIElSUSAwZSwgQVBJQyBJRCAwLCBB
UElDIElOVCAwZQpbICAgIDAuMDEyNTQ0XSBJbnQ6IHR5cGUgMCwgcG9sIDAsIHRyaWcgMCwg
YnVzIDAwLCBJUlEgMGYsIEFQSUMgSUQgMCwgQVBJQyBJTlQgMGYKWyAgICAwLjAxMjU0N10g
VXNpbmcgQUNQSSAoTUFEVCkgZm9yIFNNUCBjb25maWd1cmF0aW9uIGluZm9ybWF0aW9uClsg
ICAgMC4wMTI1NTBdIEFDUEk6IEhQRVQgaWQ6IDB4ODA4NmEyMDEgYmFzZTogMHhmZWQwMDAw
MApbICAgIDAuMDEyNTU1XSBzbXBib290OiBBbGxvd2luZyAyIENQVXMsIDAgaG90cGx1ZyBD
UFVzClsgICAgMC4wMTI1NThdIG1hcHBlZCBJT0FQSUMgdG8gZmZmZmZmZmZmZjVmYzAwMCAo
ZmVjMDAwMDApClsgICAgMC4wMTI1ODVdIFttZW0gMHgyMDAwMDAwMC0weGZlZmZiZmZmXSBh
dmFpbGFibGUgZm9yIFBDSSBkZXZpY2VzClsgICAgMC4wMTI1ODddIEJvb3RpbmcgcGFyYXZp
cnR1YWxpemVkIGtlcm5lbCBvbiBLVk0KWyAgICAwLjAxMjU5MF0gY2xvY2tzb3VyY2U6IHJl
ZmluZWQtamlmZmllczogbWFzazogMHhmZmZmZmZmZiBtYXhfY3ljbGVzOiAweGZmZmZmZmZm
LCBtYXhfaWRsZV9uczogMTkxMDk2OTk0MDM5MTQxOSBucwpbICAgIDAuMTY0OTgyXSBzZXR1
cF9wZXJjcHU6IE5SX0NQVVM6NjQgbnJfY3B1bWFza19iaXRzOjY0IG5yX2NwdV9pZHM6MiBu
cl9ub2RlX2lkczoxClsgICAgMC4xNjU1NjldIHBlcmNwdTogRW1iZWRkZWQgNTkgcGFnZXMv
Y3B1IEAoX19fX3B0cnZhbF9fX18pIHMyMDE5MjggcjgxOTIgZDMxNTQ0IHUxMDQ4NTc2Clsg
ICAgMC4xNjU1NzVdIHBjcHUtYWxsb2M6IHMyMDE5MjggcjgxOTIgZDMxNTQ0IHUxMDQ4NTc2
IGFsbG9jPTEqMjA5NzE1MgpbICAgIDAuMTY1NTc4XSBwY3B1LWFsbG9jOiBbMF0gMCAxIApb
ICAgIDAuMTY1NjA3XSBLVk0gc2V0dXAgYXN5bmMgUEYgZm9yIGNwdSAwClsgICAgMC4xNjU2
MTNdIGt2bS1zdGVhbHRpbWU6IGNwdSAwLCBtc3IgMWRjMTUwYzAKWyAgICAwLjE2NTYyMV0g
QnVpbHQgMSB6b25lbGlzdHMsIG1vYmlsaXR5IGdyb3VwaW5nIG9uLiAgVG90YWwgcGFnZXM6
IDEyOTEyOQpbICAgIDAuMTY1NjIzXSBQb2xpY3kgem9uZTogRE1BMzIKWyAgICAwLjE2NTYy
OF0gS2VybmVsIGNvbW1hbmQgbGluZTogcm9vdD0vZGV2L3JhbTAgaHVuZ190YXNrX3Bhbmlj
PTEgZGVidWcgYXBpYz1kZWJ1ZyBzeXNycV9hbHdheXNfZW5hYmxlZCByY3VwZGF0ZS5yY3Vf
Y3B1X3N0YWxsX3RpbWVvdXQ9MTAwIG5ldC5pZm5hbWVzPTAgcHJpbnRrLmRldmttc2c9b24g
cGFuaWM9LTEgc29mdGxvY2t1cF9wYW5pYz0xIG5taV93YXRjaGRvZz1wYW5pYyBvb3BzPXBh
bmljIGxvYWRfcmFtZGlzaz0yIHByb21wdF9yYW1kaXNrPTAgZHJiZC5taW5vcl9jb3VudD04
IHN5c3RlbWQubG9nX2xldmVsPWVyciBpZ25vcmVfbG9nbGV2ZWwgY29uc29sZT10dHkwIGVh
cmx5cHJpbnRrPXR0eVMwLDExNTIwMCBjb25zb2xlPXR0eVMwLDExNTIwMCB2Z2E9bm9ybWFs
IHJ3IGxpbms9L2NlcGhmcy9rYnVpbGQvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZp
Zy1zMi0wMjE3MjMxOC9saW51eC1kZXZlbDpmaXh1cC1lZmFkNGU0NzVjMzEyNDU2ZWRiM2M3
ODlkMDk5NmQxMmVkNzQ0YzEzOmI1MjNhYjFiOGNlNTk1OTJjYjMyZDYyMjUwMzIxNzA3N2Nm
MDdlNGQvLnZtbGludXotYjUyM2FiMWI4Y2U1OTU5MmNiMzJkNjIyNTAzMjE3MDc3Y2YwN2U0
ZC0yMDE5MDIxODE2MDAxMi0xMDQ6cXVhbnRhbC12bS1xdWFudGFsLTYwNyBicmFuY2g9bGlu
dXgtZGV2ZWwvZml4dXAtZWZhZDRlNDc1YzMxMjQ1NmVkYjNjNzg5ZDA5OTZkMTJlZDc0NGMx
MyBCT09UX0lNQUdFPS9wa2cvbGludXgveDg2XzY0LXJhbmRjb25maWctczItMDIxNzIzMTgv
Z2NjLTYvYjUyM2FiMWI4Y2U1OTU5MmNiMzJkNjIyNTAzMjE3MDc3Y2YwN2U0ZC92bWxpbnV6
LTUuMC4wLXJjNC0wMDE1MC1nYjUyM2FiMSBkcmJkLm1pbm9yX2NvdW50PTggcmN1cGVyZi5z
aHV0ZG93bj0wClsgICAgMC4xNjU3MDhdIHN5c3JxOiBzeXNycSBhbHdheXMgZW5hYmxlZC4K
WyAgICAwLjE2NjAxOV0gQ2FsZ2FyeTogZGV0ZWN0aW5nIENhbGdhcnkgdmlhIEJJT1MgRUJE
QSBhcmVhClsgICAgMC4xNjYwMjNdIENhbGdhcnk6IFVuYWJsZSB0byBsb2NhdGUgUmlvIEdy
YW5kZSB0YWJsZSBpbiBFQkRBIC0gYmFpbGluZyEKWyAgICAwLjE2NzI3OV0gTWVtb3J5OiA0
NTIzMjhLLzUyMzc2OEsgYXZhaWxhYmxlICgxMjI5MUsga2VybmVsIGNvZGUsIDEzNDZLIHJ3
ZGF0YSwgMzg3Mksgcm9kYXRhLCAxMTA4SyBpbml0LCAxMzg2OEsgYnNzLCA3MTQ0MEsgcmVz
ZXJ2ZWQsIDBLIGNtYS1yZXNlcnZlZCkKWyAgICAwLjE2NzMwM10gS2VybmVsL1VzZXIgcGFn
ZSB0YWJsZXMgaXNvbGF0aW9uOiBlbmFibGVkClsgICAgMC4xNjc0OTldIFJ1bm5pbmcgUkNV
IHNlbGYgdGVzdHMKWyAgICAwLjE2NzUwMl0gcmN1OiBQcmVlbXB0aWJsZSBoaWVyYXJjaGlj
YWwgUkNVIGltcGxlbWVudGF0aW9uLgpbICAgIDAuMTY3NTA0XSByY3U6IAlSQ1UgbG9ja2Rl
cCBjaGVja2luZyBpcyBlbmFibGVkLgpbICAgIDAuMTY3NTA3XSByY3U6IAlSQ1UgcmVzdHJp
Y3RpbmcgQ1BVcyBmcm9tIE5SX0NQVVM9NjQgdG8gbnJfY3B1X2lkcz0yLgpbICAgIDAuMTY3
NTA5XSAJUkNVIENQVSBzdGFsbCB3YXJuaW5ncyB0aW1lb3V0IHNldCB0byAxMDAgKHJjdV9j
cHVfc3RhbGxfdGltZW91dCkuClsgICAgMC4xNjc1MTFdIAlUYXNrcyBSQ1UgZW5hYmxlZC4K
WyAgICAwLjE2NzUxNF0gcmN1OiBSQ1UgY2FsY3VsYXRlZCB2YWx1ZSBvZiBzY2hlZHVsZXIt
ZW5saXN0bWVudCBkZWxheSBpcyAxMDAgamlmZmllcy4KWyAgICAwLjE2NzUxNl0gcmN1OiBB
ZGp1c3RpbmcgZ2VvbWV0cnkgZm9yIHJjdV9mYW5vdXRfbGVhZj0xNiwgbnJfY3B1X2lkcz0y
ClsgICAgMC4xNjc3OTRdIE5SX0lSUVM6IDQzNTIsIG5yX2lycXM6IDQ0MCwgcHJlYWxsb2Nh
dGVkIGlycXM6IDE2ClsgICAgMC4xNjc5ODZdIHJjdTogCU9mZmxvYWQgUkNVIGNhbGxiYWNr
cyBmcm9tIENQVXM6IChub25lKS4KWyAgICAwLjI4Mzk4NV0gcHJpbnRrOiBjb25zb2xlIFt0
dHlTMF0gZW5hYmxlZApbICAgIDAuMjg0NDI1XSBMb2NrIGRlcGVuZGVuY3kgdmFsaWRhdG9y
OiBDb3B5cmlnaHQgKGMpIDIwMDYgUmVkIEhhdCwgSW5jLiwgSW5nbyBNb2xuYXIKWyAgICAw
LjI4NTI1Ml0gLi4uIE1BWF9MT0NLREVQX1NVQkNMQVNTRVM6ICA4ClsgICAgMC4yODU2Njhd
IC4uLiBNQVhfTE9DS19ERVBUSDogICAgICAgICAgNDgKWyAgICAwLjI4NjExMV0gLi4uIE1B
WF9MT0NLREVQX0tFWVM6ICAgICAgICA4MTkxClsgICAgMC4yODY1NjldIC4uLiBDTEFTU0hB
U0hfU0laRTogICAgICAgICAgNDA5NgpbICAgIDAuMjg3MDM0XSAuLi4gTUFYX0xPQ0tERVBf
RU5UUklFUzogICAgIDMyNzY4ClsgICAgMC4yODc1MDBdIC4uLiBNQVhfTE9DS0RFUF9DSEFJ
TlM6ICAgICAgNjU1MzYKWyAgICAwLjI4Nzk2Nl0gLi4uIENIQUlOSEFTSF9TSVpFOiAgICAg
ICAgICAzMjc2OApbICAgIDAuMjg4NDM2XSAgbWVtb3J5IHVzZWQgYnkgbG9jayBkZXBlbmRl
bmN5IGluZm86IDcyNjMga0IKWyAgICAwLjI5NzA2NF0gIHBlciB0YXNrLXN0cnVjdCBtZW1v
cnkgZm9vdHByaW50OiAxOTIwIGJ5dGVzClsgICAgMC4yOTc2NjldIEFDUEk6IENvcmUgcmV2
aXNpb24gMjAxODEyMTMKWyAgICAwLjI5ODM4Nl0gY2xvY2tzb3VyY2U6IGhwZXQ6IG1hc2s6
IDB4ZmZmZmZmZmYgbWF4X2N5Y2xlczogMHhmZmZmZmZmZiwgbWF4X2lkbGVfbnM6IDE5MTEy
NjA0NDY3IG5zClsgICAgMC4yOTk1NTRdIGhwZXQgY2xvY2tldmVudCByZWdpc3RlcmVkClsg
ICAgMC4zMDAwNDJdIEFQSUM6IFN3aXRjaCB0byBzeW1tZXRyaWMgSS9PIG1vZGUgc2V0dXAK
WyAgICAwLjMwMDYyOF0gZW5hYmxlZCBFeHRJTlQgb24gQ1BVIzAKWyAgICAwLjMwMTgxOV0g
RU5BQkxJTkcgSU8tQVBJQyBJUlFzClsgICAgMC4zMDIxOTFdIGluaXQgSU9fQVBJQyBJUlFz
ClsgICAgMC4zMDI1NDJdICBhcGljIDAgcGluIDAgbm90IGNvbm5lY3RlZApbICAgIDAuMzAy
OTc2XSBJT0FQSUNbMF06IFNldCByb3V0aW5nIGVudHJ5ICgwLTEgLT4gMHhlZiAtPiBJUlEg
MSBNb2RlOjAgQWN0aXZlOjAgRGVzdDoxKQpbICAgIDAuMzAzODY2XSBJT0FQSUNbMF06IFNl
dCByb3V0aW5nIGVudHJ5ICgwLTIgLT4gMHgzMCAtPiBJUlEgMCBNb2RlOjAgQWN0aXZlOjAg
RGVzdDoxKQpbICAgIDAuMzA0NzI4XSBJT0FQSUNbMF06IFNldCByb3V0aW5nIGVudHJ5ICgw
LTMgLT4gMHhlZiAtPiBJUlEgMyBNb2RlOjAgQWN0aXZlOjAgRGVzdDoxKQpbICAgIDAuMzA1
NTk4XSBJT0FQSUNbMF06IFNldCByb3V0aW5nIGVudHJ5ICgwLTQgLT4gMHhlZiAtPiBJUlEg
NCBNb2RlOjAgQWN0aXZlOjAgRGVzdDoxKQpbICAgIDAuMzA2NDI3XSBJT0FQSUNbMF06IFNl
dCByb3V0aW5nIGVudHJ5ICgwLTUgLT4gMHhlZiAtPiBJUlEgNSBNb2RlOjEgQWN0aXZlOjAg
RGVzdDoxKQpbICAgIDAuMzA3Mjc5XSBJT0FQSUNbMF06IFNldCByb3V0aW5nIGVudHJ5ICgw
LTYgLT4gMHhlZiAtPiBJUlEgNiBNb2RlOjAgQWN0aXZlOjAgRGVzdDoxKQpbICAgIDAuMzA4
MTI2XSBJT0FQSUNbMF06IFNldCByb3V0aW5nIGVudHJ5ICgwLTcgLT4gMHhlZiAtPiBJUlEg
NyBNb2RlOjAgQWN0aXZlOjAgRGVzdDoxKQpbICAgIDAuMzA5MDAyXSBJT0FQSUNbMF06IFNl
dCByb3V0aW5nIGVudHJ5ICgwLTggLT4gMHhlZiAtPiBJUlEgOCBNb2RlOjAgQWN0aXZlOjAg
RGVzdDoxKQpbICAgIDAuMzA5ODQ0XSBJT0FQSUNbMF06IFNldCByb3V0aW5nIGVudHJ5ICgw
LTkgLT4gMHhlZiAtPiBJUlEgOSBNb2RlOjEgQWN0aXZlOjAgRGVzdDoxKQpbICAgIDAuMzEw
NjkxXSBJT0FQSUNbMF06IFNldCByb3V0aW5nIGVudHJ5ICgwLTEwIC0+IDB4ZWYgLT4gSVJR
IDEwIE1vZGU6MSBBY3RpdmU6MCBEZXN0OjEpClsgICAgMC4zMTE1NDldIElPQVBJQ1swXTog
U2V0IHJvdXRpbmcgZW50cnkgKDAtMTEgLT4gMHhlZiAtPiBJUlEgMTEgTW9kZToxIEFjdGl2
ZTowIERlc3Q6MSkKWyAgICAwLjMxMjM5Ml0gSU9BUElDWzBdOiBTZXQgcm91dGluZyBlbnRy
eSAoMC0xMiAtPiAweGVmIC0+IElSUSAxMiBNb2RlOjAgQWN0aXZlOjAgRGVzdDoxKQpbICAg
IDAuMzEzMjU4XSBJT0FQSUNbMF06IFNldCByb3V0aW5nIGVudHJ5ICgwLTEzIC0+IDB4ZWYg
LT4gSVJRIDEzIE1vZGU6MCBBY3RpdmU6MCBEZXN0OjEpClsgICAgMC4zMTQxMTddIElPQVBJ
Q1swXTogU2V0IHJvdXRpbmcgZW50cnkgKDAtMTQgLT4gMHhlZiAtPiBJUlEgMTQgTW9kZTow
IEFjdGl2ZTowIERlc3Q6MSkKWyAgICAwLjMxNDk3MV0gSU9BUElDWzBdOiBTZXQgcm91dGlu
ZyBlbnRyeSAoMC0xNSAtPiAweGVmIC0+IElSUSAxNSBNb2RlOjAgQWN0aXZlOjAgRGVzdDox
KQpbICAgIDAuMzE1ODI0XSAgYXBpYyAwIHBpbiAxNiBub3QgY29ubmVjdGVkClsgICAgMC4z
MTYyNDJdICBhcGljIDAgcGluIDE3IG5vdCBjb25uZWN0ZWQKWyAgICAwLjMxNjY2OV0gIGFw
aWMgMCBwaW4gMTggbm90IGNvbm5lY3RlZApbICAgIDAuMzE3MTI3XSAgYXBpYyAwIHBpbiAx
OSBub3QgY29ubmVjdGVkClsgICAgMC4zMTc1NjBdICBhcGljIDAgcGluIDIwIG5vdCBjb25u
ZWN0ZWQKWyAgICAwLjMxNzk3MV0gIGFwaWMgMCBwaW4gMjEgbm90IGNvbm5lY3RlZApbICAg
IDAuMzE4MzkwXSAgYXBpYyAwIHBpbiAyMiBub3QgY29ubmVjdGVkClsgICAgMC4zMTg4MTZd
ICBhcGljIDAgcGluIDIzIG5vdCBjb25uZWN0ZWQKWyAgICAwLjMxOTM0OF0gLi5USU1FUjog
dmVjdG9yPTB4MzAgYXBpYzE9MCBwaW4xPTIgYXBpYzI9LTEgcGluMj0tMQpbICAgIDAuMzIw
MDExXSBjbG9ja3NvdXJjZTogdHNjLWVhcmx5OiBtYXNrOiAweGZmZmZmZmZmZmZmZmZmZmYg
bWF4X2N5Y2xlczogMHgyMTI3MzFhNTMwMSwgbWF4X2lkbGVfbnM6IDQ0MDc5NTMxNzEyMyBu
cwpbICAgIDAuMzIxMTUwXSBDYWxpYnJhdGluZyBkZWxheSBsb29wIChza2lwcGVkKSBwcmVz
ZXQgdmFsdWUuLiA0NTk5Ljk5IEJvZ29NSVBTIChscGo9MjI5OTk5NikKWyAgICAwLjMyMjEz
NF0gcGlkX21heDogZGVmYXVsdDogNDA5NiBtaW5pbXVtOiAzMDEKWyAgICAwLjMyMzQ5OV0g
RGVudHJ5IGNhY2hlIGhhc2ggdGFibGUgZW50cmllczogNjU1MzYgKG9yZGVyOiA3LCA1MjQy
ODggYnl0ZXMpClsgICAgMC4zMjQyOTldIElub2RlLWNhY2hlIGhhc2ggdGFibGUgZW50cmll
czogMzI3NjggKG9yZGVyOiA2LCAyNjIxNDQgYnl0ZXMpClsgICAgMC4zMjUxNDldIE1vdW50
LWNhY2hlIGhhc2ggdGFibGUgZW50cmllczogMTAyNCAob3JkZXI6IDEsIDgxOTIgYnl0ZXMp
ClsgICAgMC4zMjU4NDFdIE1vdW50cG9pbnQtY2FjaGUgaGFzaCB0YWJsZSBlbnRyaWVzOiAx
MDI0IChvcmRlcjogMSwgODE5MiBieXRlcykKWyAgICAwLjMyNzIxNl0gbnVtYV9hZGRfY3B1
IGNwdSAwIG5vZGUgMDogbWFzayBub3cgMApbICAgIDAuMzI3NzI3XSBMYXN0IGxldmVsIGlU
TEIgZW50cmllczogNEtCIDAsIDJNQiAwLCA0TUIgMApbICAgIDAuMzI4MTM0XSBMYXN0IGxl
dmVsIGRUTEIgZW50cmllczogNEtCIDAsIDJNQiAwLCA0TUIgMCwgMUdCIDAKWyAgICAwLjMy
ODc1N10gU3BlY3RyZSBWMiA6IE1pdGlnYXRpb246IEZ1bGwgZ2VuZXJpYyByZXRwb2xpbmUK
WyAgICAwLjMyOTEzM10gU3BlY3RyZSBWMiA6IFNwZWN0cmUgdjIgLyBTcGVjdHJlUlNCIG1p
dGlnYXRpb246IEZpbGxpbmcgUlNCIG9uIGNvbnRleHQgc3dpdGNoClsgICAgMC4zMzAxNDBd
IFNwZWN1bGF0aXZlIFN0b3JlIEJ5cGFzczogVnVsbmVyYWJsZQpbICAgIDAuMzMwNzM3XSBG
cmVlaW5nIFNNUCBhbHRlcm5hdGl2ZXMgbWVtb3J5OiAyMEsKWyAgICAwLjMzMTQ0N10gVXNp
bmcgbG9jYWwgQVBJQyB0aW1lciBpbnRlcnJ1cHRzLgpbICAgIDAuMzMxNDQ3XSBjYWxpYnJh
dGluZyBBUElDIHRpbWVyIC4uLgpbICAgIDAuMzMzMTI5XSAuLi4gbGFwaWMgZGVsdGEgPSA3
OTk5NjU0ClsgICAgMC4zMzMxMjldIC4uLiBQTS1UaW1lciBkZWx0YSA9IDQ1ODE2NgpbICAg
IDAuMzMzMTI5XSBBUElDIGNhbGlicmF0aW9uIG5vdCBjb25zaXN0ZW50IHdpdGggUE0tVGlt
ZXI6IDEyN21zIGluc3RlYWQgb2YgMTAwbXMKWyAgICAwLjMzMzEyOV0gQVBJQyBkZWx0YSBh
ZGp1c3RlZCB0byBQTS1UaW1lcjogNjI0OTkzNSAoNzk5OTY1NCkKWyAgICAwLjMzMzEyOV0g
VFNDIGRlbHRhIGFkanVzdGVkIHRvIFBNLVRpbWVyOiAyMjk5OTkxNzkgKDI5NDM4OTIzNCkK
WyAgICAwLjMzMzEyOV0gLi4uLi4gZGVsdGEgNjI0OTkzNQpbICAgIDAuMzMzMTI5XSAuLi4u
LiBtdWx0OiAyNjg0MzI2NjQKWyAgICAwLjMzMzEyOV0gLi4uLi4gY2FsaWJyYXRpb24gcmVz
dWx0OiA5OTk5ODkKWyAgICAwLjMzMzEyOV0gLi4uLi4gQ1BVIGNsb2NrIHNwZWVkIGlzIDIy
OTkuMDk5MSBNSHouClsgICAgMC4zMzMxMjldIC4uLi4uIGhvc3QgYnVzIGNsb2NrIHNwZWVk
IGlzIDk5OS4wOTg5IE1Iei4KWyAgICAwLjMzMzE3NV0gc21wYm9vdDogQ1BVMDogSW50ZWwg
Q29tbW9uIEtWTSBwcm9jZXNzb3IgKGZhbWlseTogMHhmLCBtb2RlbDogMHg2LCBzdGVwcGlu
ZzogMHgxKQpbICAgIDAuMzQwMTU3XSBQZXJmb3JtYW5jZSBFdmVudHM6IHVuc3VwcG9ydGVk
IE5ldGJ1cnN0IENQVSBtb2RlbCA2IG5vIFBNVSBkcml2ZXIsIHNvZnR3YXJlIGV2ZW50cyBv
bmx5LgpbICAgIDAuMzQzMTQzXSByY3U6IEhpZXJhcmNoaWNhbCBTUkNVIGltcGxlbWVudGF0
aW9uLgpbICAgIDAuMzQ1MjMyXSBOTUkgd2F0Y2hkb2c6IFBlcmYgTk1JIHdhdGNoZG9nIHBl
cm1hbmVudGx5IGRpc2FibGVkClsgICAgMC4zNDgxNDJdIHNtcDogQnJpbmdpbmcgdXAgc2Vj
b25kYXJ5IENQVXMgLi4uClsgICAgMC4zNTYyMDRdIHg4NjogQm9vdGluZyBTTVAgY29uZmln
dXJhdGlvbjoKWyAgICAwLjM1NjY3N10gLi4uLiBub2RlICAjMCwgQ1BVczogICAgICAjMQpb
ICAgIDAuMTQ4MTM2XSBrdm0tY2xvY2s6IGNwdSAxLCBtc3IgMjg4NzA0MSwgc2Vjb25kYXJ5
IGNwdSBjbG9jawpbICAgIDAuMTQ4MTM2XSBtYXNrZWQgRXh0SU5UIG9uIENQVSMxClsgICAg
MC4xNDgxMzZdIG51bWFfYWRkX2NwdSBjcHUgMSBub2RlIDA6IG1hc2sgbm93IDAtMQpbICAg
IDAuMzc2MjAxXSBLVk0gc2V0dXAgYXN5bmMgUEYgZm9yIGNwdSAxClsgICAgMC4zNzY2MjVd
IGt2bS1zdGVhbHRpbWU6IGNwdSAxLCBtc3IgMWRkMTUwYzAKWyAgICAwLjM3NzE0OF0gc21w
OiBCcm91Z2h0IHVwIDEgbm9kZSwgMiBDUFVzClsgICAgMC4zNzgxNTVdIHNtcGJvb3Q6IE1h
eCBsb2dpY2FsIHBhY2thZ2VzOiAyClsgICAgMC4zNzg2MDBdIHNtcGJvb3Q6IFRvdGFsIG9m
IDIgcHJvY2Vzc29ycyBhY3RpdmF0ZWQgKDkxOTkuOTggQm9nb01JUFMpClsgICAgMC4zNzk0
NjddIGRldnRtcGZzOiBpbml0aWFsaXplZApbICAgIDAuMzgwMzcwXSB4ODYvbW06IE1lbW9y
eSBibG9jayBzaXplOiAxMjhNQgpbICAgIDAuMzgyMjI3XSB3b3JrcXVldWU6IHJvdW5kLXJv
YmluIENQVSBzZWxlY3Rpb24gZm9yY2VkLCBleHBlY3QgcGVyZm9ybWFuY2UgaW1wYWN0Clsg
ICAgMC4zODMyMTVdIGNsb2Nrc291cmNlOiBqaWZmaWVzOiBtYXNrOiAweGZmZmZmZmZmIG1h
eF9jeWNsZXM6IDB4ZmZmZmZmZmYsIG1heF9pZGxlX25zOiAxOTExMjYwNDQ2Mjc1MDAwIG5z
ClsgICAgMC4zODQxNDVdIGZ1dGV4IGhhc2ggdGFibGUgZW50cmllczogMTYgKG9yZGVyOiAt
MSwgMjA0OCBieXRlcykKWyAgICAwLjM4NTI0OV0gcGluY3RybCBjb3JlOiBpbml0aWFsaXpl
ZCBwaW5jdHJsIHN1YnN5c3RlbQpbICAgIDAuMzg2NDc1XSByZWd1bGF0b3ItZHVtbXk6IG5v
IHBhcmFtZXRlcnMKWyAgICAwLjM4NzI4OF0gcmVndWxhdG9yLWR1bW15OiBubyBwYXJhbWV0
ZXJzClsgICAgMC4zODc4MDVdIHJlZ3VsYXRvci1kdW1teTogRmFpbGVkIHRvIGNyZWF0ZSBk
ZWJ1Z2ZzIGRpcmVjdG9yeQpbICAgIDAuMzg4MjU1XSBSVEMgdGltZTogMTY6MDA6MjIsIGRh
dGU6IDIwMTktMDItMTgKWyAgICAwLjM4OTI4MV0gcmFuZG9tOiBnZXRfcmFuZG9tX3UzMiBj
YWxsZWQgZnJvbSBidWNrZXRfdGFibGVfYWxsb2MrMHg4My8weDE1MCB3aXRoIGNybmdfaW5p
dD0wClsgICAgMC4zOTAyNzhdIE5FVDogUmVnaXN0ZXJlZCBwcm90b2NvbCBmYW1pbHkgMTYK
WyAgICAwLjM5MjQwMF0gYXVkaXQ6IGluaXRpYWxpemluZyBuZXRsaW5rIHN1YnN5cyAoZGlz
YWJsZWQpClsgICAgMC4zOTQxNTVdIGF1ZGl0OiB0eXBlPTIwMDAgYXVkaXQoMTU1MDQ3Njgy
Mi4xOTk6MSk6IHN0YXRlPWluaXRpYWxpemVkIGF1ZGl0X2VuYWJsZWQ9MCByZXM9MQpbICAg
IDAuMzk1MTY4XSBjcHVpZGxlOiB1c2luZyBnb3Zlcm5vciBsYWRkZXIKWyAgICAwLjM5NjE3
MV0gY3B1aWRsZTogdXNpbmcgZ292ZXJub3IgbWVudQpbICAgIDAuMzk3MTM1XSBBQ1BJOiBi
dXMgdHlwZSBQQ0kgcmVnaXN0ZXJlZApbICAgIDAuMzk3NzExXSBkY2Egc2VydmljZSBzdGFy
dGVkLCB2ZXJzaW9uIDEuMTIuMQpbICAgIDAuMzk4MjQxXSBQQ0k6IFVzaW5nIGNvbmZpZ3Vy
YXRpb24gdHlwZSAxIGZvciBiYXNlIGFjY2VzcwpbICAgIDAuNDE2MjM2XSBIdWdlVExCIHJl
Z2lzdGVyZWQgMi4wMCBNaUIgcGFnZSBzaXplLCBwcmUtYWxsb2NhdGVkIDAgcGFnZXMKWyAg
ICAwLjQxNzE2N10gY3J5cHRkOiBtYXhfY3B1X3FsZW4gc2V0IHRvIDEwMDAKWyAgICAwLjQx
Nzc2Nl0gQUNQSTogQWRkZWQgX09TSShNb2R1bGUgRGV2aWNlKQpbICAgIDAuNDE4MTM2XSBB
Q1BJOiBBZGRlZCBfT1NJKFByb2Nlc3NvciBEZXZpY2UpClsgICAgMC40MTg2MDRdIEFDUEk6
IEFkZGVkIF9PU0koMy4wIF9TQ1AgRXh0ZW5zaW9ucykKWyAgICAwLjQxOTEzNF0gQUNQSTog
QWRkZWQgX09TSShQcm9jZXNzb3IgQWdncmVnYXRvciBEZXZpY2UpClsgICAgMC40MjAxMzRd
IEFDUEk6IEFkZGVkIF9PU0koTGludXgtRGVsbC1WaWRlbykKWyAgICAwLjQyMDEzN10gQUNQ
STogQWRkZWQgX09TSShMaW51eC1MZW5vdm8tTlYtSERNSS1BdWRpbykKWyAgICAwLjQyMDY5
MV0gQUNQSTogQWRkZWQgX09TSShMaW51eC1IUEktSHlicmlkLUdyYXBoaWNzKQpbICAgIDAu
NDI0NzUyXSBBQ1BJOiAxIEFDUEkgQU1MIHRhYmxlcyBzdWNjZXNzZnVsbHkgYWNxdWlyZWQg
YW5kIGxvYWRlZApbICAgIDAuNDI4MjQwXSBBQ1BJOiBJbnRlcnByZXRlciBlbmFibGVkClsg
ICAgMC40Mjg2NzVdIEFDUEk6IChzdXBwb3J0cyBTMCBTMyBTNSkKWyAgICAwLjQyOTA3OV0g
QUNQSTogVXNpbmcgSU9BUElDIGZvciBpbnRlcnJ1cHQgcm91dGluZwpbICAgIDAuNDMwMTcw
XSBQQ0k6IFVzaW5nIGhvc3QgYnJpZGdlIHdpbmRvd3MgZnJvbSBBQ1BJOyBpZiBuZWNlc3Nh
cnksIHVzZSAicGNpPW5vY3JzIiBhbmQgcmVwb3J0IGEgYnVnClsgICAgMC40MzE0NzldIEFD
UEk6IEVuYWJsZWQgMyBHUEVzIGluIGJsb2NrIDAwIHRvIDBGClsgICAgMC40NTQ3MjRdIEFD
UEk6IFBDSSBSb290IEJyaWRnZSBbUENJMF0gKGRvbWFpbiAwMDAwIFtidXMgMDAtZmZdKQpb
ICAgIDAuNDU1MTQzXSBhY3BpIFBOUDBBMDM6MDA6IF9PU0M6IE9TIHN1cHBvcnRzIFtBU1BN
IENsb2NrUE0gU2VnbWVudHMgTVNJXQpbICAgIDAuNDU2MjIwXSBhY3BpIFBOUDBBMDM6MDA6
IGZhaWwgdG8gYWRkIE1NQ09ORklHIGluZm9ybWF0aW9uLCBjYW4ndCBhY2Nlc3MgZXh0ZW5k
ZWQgUENJIGNvbmZpZ3VyYXRpb24gc3BhY2UgdW5kZXIgdGhpcyBicmlkZ2UuClsgICAgMC40
NTgzMzZdIFBDSSBob3N0IGJyaWRnZSB0byBidXMgMDAwMDowMApbICAgIDAuNDU4Nzg0XSBw
Y2lfYnVzIDAwMDA6MDA6IHJvb3QgYnVzIHJlc291cmNlIFtpbyAgMHgwMDAwLTB4MGNmNyB3
aW5kb3ddClsgICAgMC40ODMxNDldIHBjaV9idXMgMDAwMDowMDogcm9vdCBidXMgcmVzb3Vy
Y2UgW2lvICAweDBkMDAtMHhmZmZmIHdpbmRvd10KWyAgICAwLjQ4NDEzNl0gcGNpX2J1cyAw
MDAwOjAwOiByb290IGJ1cyByZXNvdXJjZSBbbWVtIDB4MDAwYTAwMDAtMHgwMDBiZmZmZiB3
aW5kb3ddClsgICAgMC40ODQxMzZdIHBjaV9idXMgMDAwMDowMDogcm9vdCBidXMgcmVzb3Vy
Y2UgW21lbSAweDIwMDAwMDAwLTB4ZmViZmZmZmYgd2luZG93XQpbICAgIDAuNDg0ODgyXSBw
Y2lfYnVzIDAwMDA6MDA6IHJvb3QgYnVzIHJlc291cmNlIFtidXMgMDAtZmZdClsgICAgMC40
ODYyMzVdIHBjaSAwMDAwOjAwOjAwLjA6IFs4MDg2OjEyMzddIHR5cGUgMDAgY2xhc3MgMHgw
NjAwMDAKWyAgICAwLjQ4NzIwNV0gcGNpIDAwMDA6MDA6MDEuMDogWzgwODY6NzAwMF0gdHlw
ZSAwMCBjbGFzcyAweDA2MDEwMApbICAgIDAuNDg4NjIzXSBwY2kgMDAwMDowMDowMS4xOiBb
ODA4Njo3MDEwXSB0eXBlIDAwIGNsYXNzIDB4MDEwMTgwClsgICAgMC41MTkxNDBdIHBjaSAw
MDAwOjAwOjAxLjE6IHJlZyAweDIwOiBbaW8gIDB4YzA0MC0weGMwNGZdClsgICAgMC41Mjcx
NjFdIHBjaSAwMDAwOjAwOjAxLjE6IGxlZ2FjeSBJREUgcXVpcms6IHJlZyAweDEwOiBbaW8g
IDB4MDFmMC0weDAxZjddClsgICAgMC41Mjc5MDVdIHBjaSAwMDAwOjAwOjAxLjE6IGxlZ2Fj
eSBJREUgcXVpcms6IHJlZyAweDE0OiBbaW8gIDB4MDNmNl0KWyAgICAwLjUyOTEzN10gcGNp
IDAwMDA6MDA6MDEuMTogbGVnYWN5IElERSBxdWlyazogcmVnIDB4MTg6IFtpbyAgMHgwMTcw
LTB4MDE3N10KWyAgICAwLjUyOTEzN10gcGNpIDAwMDA6MDA6MDEuMTogbGVnYWN5IElERSBx
dWlyazogcmVnIDB4MWM6IFtpbyAgMHgwMzc2XQpbICAgIDAuNTMwNTc2XSBwY2kgMDAwMDow
MDowMS4zOiBbODA4Njo3MTEzXSB0eXBlIDAwIGNsYXNzIDB4MDY4MDAwClsgICAgMC41MzE1
NDNdIHBjaSAwMDAwOjAwOjAxLjM6IHF1aXJrOiBbaW8gIDB4MDYwMC0weDA2M2ZdIGNsYWlt
ZWQgYnkgUElJWDQgQUNQSQpbICAgIDAuNTMyMTQ1XSBwY2kgMDAwMDowMDowMS4zOiBxdWly
azogW2lvICAweDA3MDAtMHgwNzBmXSBjbGFpbWVkIGJ5IFBJSVg0IFNNQgpbICAgIDAuNTMz
NTk0XSBwY2kgMDAwMDowMDowMi4wOiBbMTIzNDoxMTExXSB0eXBlIDAwIGNsYXNzIDB4MDMw
MDAwClsgICAgMC41NDAxNDFdIHBjaSAwMDAwOjAwOjAyLjA6IHJlZyAweDEwOiBbbWVtIDB4
ZmQwMDAwMDAtMHhmZGZmZmZmZiBwcmVmXQpbICAgIDAuNTQ2MTQwXSBwY2kgMDAwMDowMDow
Mi4wOiByZWcgMHgxODogW21lbSAweGZlYmYwMDAwLTB4ZmViZjBmZmZdClsgICAgMC41NjYx
NDRdIHBjaSAwMDAwOjAwOjAyLjA6IHJlZyAweDMwOiBbbWVtIDB4ZmViZTAwMDAtMHhmZWJl
ZmZmZiBwcmVmXQpbICAgIDAuNTY3NTkwXSBwY2kgMDAwMDowMDowMy4wOiBbODA4NjoxMDBl
XSB0eXBlIDAwIGNsYXNzIDB4MDIwMDAwClsgICAgMC41NzAxMzddIHBjaSAwMDAwOjAwOjAz
LjA6IHJlZyAweDEwOiBbbWVtIDB4ZmViYzAwMDAtMHhmZWJkZmZmZl0KWyAgICAwLjU3MjEz
Nl0gcGNpIDAwMDA6MDA6MDMuMDogcmVnIDB4MTQ6IFtpbyAgMHhjMDAwLTB4YzAzZl0KWyAg
ICAwLjU4NzEzN10gcGNpIDAwMDA6MDA6MDMuMDogcmVnIDB4MzA6IFttZW0gMHhmZWI4MDAw
MC0weGZlYmJmZmZmIHByZWZdClsgICAgMC41ODc2NjRdIHBjaSAwMDAwOjAwOjA0LjA6IFs4
MDg2OjI1YWJdIHR5cGUgMDAgY2xhc3MgMHgwODgwMDAKWyAgICAwLjU4ODcyNF0gcGNpIDAw
MDA6MDA6MDQuMDogcmVnIDB4MTA6IFttZW0gMHhmZWJmMTAwMC0weGZlYmYxMDBmXQpbICAg
IDAuNjA2MzA4XSBBQ1BJOiBQQ0kgSW50ZXJydXB0IExpbmsgW0xOS0FdIChJUlFzIDUgKjEw
IDExKQpbICAgIDAuNjA3MTc2XSBBQ1BJOiBQQ0kgSW50ZXJydXB0IExpbmsgW0xOS0JdIChJ
UlFzIDUgKjEwIDExKQpbICAgIDAuNjA3OTgzXSBBQ1BJOiBQQ0kgSW50ZXJydXB0IExpbmsg
W0xOS0NdIChJUlFzIDUgMTAgKjExKQpbICAgIDAuNjA5Mzg0XSBBQ1BJOiBQQ0kgSW50ZXJy
dXB0IExpbmsgW0xOS0RdIChJUlFzIDUgMTAgKjExKQpbICAgIDAuNjA5Mzg0XSBBQ1BJOiBQ
Q0kgSW50ZXJydXB0IExpbmsgW0xOS1NdIChJUlFzICo5KQpbICAgIDAuNjExMjk1XSBwY2kg
MDAwMDowMDowMi4wOiB2Z2FhcmI6IHNldHRpbmcgYXMgYm9vdCBWR0EgZGV2aWNlClsgICAg
MC42MTE5MzldIHBjaSAwMDAwOjAwOjAyLjA6IHZnYWFyYjogVkdBIGRldmljZSBhZGRlZDog
ZGVjb2Rlcz1pbyttZW0sb3ducz1pbyttZW0sbG9ja3M9bm9uZQpbICAgIDAuNjEzMTM3XSBw
Y2kgMDAwMDowMDowMi4wOiB2Z2FhcmI6IGJyaWRnZSBjb250cm9sIHBvc3NpYmxlClsgICAg
MC42MTQxMzVdIHZnYWFyYjogbG9hZGVkClsgICAgMC42MTQ2ODNdIHZpZGVvZGV2OiBMaW51
eCB2aWRlbyBjYXB0dXJlIGludGVyZmFjZTogdjIuMDAKWyAgICAwLjYxNjIxMl0gcHBzX2Nv
cmU6IExpbnV4UFBTIEFQSSB2ZXIuIDEgcmVnaXN0ZXJlZApbICAgIDAuNjE4MTUxXSBwcHNf
Y29yZTogU29mdHdhcmUgdmVyLiA1LjMuNiAtIENvcHlyaWdodCAyMDA1LTIwMDcgUm9kb2xm
byBHaW9tZXR0aSA8Z2lvbWV0dGlAbGludXguaXQ+ClsgICAgMC42MjExNzBdIFBUUCBjbG9j
ayBzdXBwb3J0IHJlZ2lzdGVyZWQKWyAgICAwLjYyMjU3OF0gUENJOiBVc2luZyBBQ1BJIGZv
ciBJUlEgcm91dGluZwpbICAgIDAuNjI0MTQ5XSBQQ0k6IHBjaV9jYWNoZV9saW5lX3NpemUg
c2V0IHRvIDY0IGJ5dGVzClsgICAgMC42MjU0NDJdIGU4MjA6IHJlc2VydmUgUkFNIGJ1ZmZl
ciBbbWVtIDB4MDAwOWZjMDAtMHgwMDA5ZmZmZl0KWyAgICAwLjYyODE3M10gZTgyMDogcmVz
ZXJ2ZSBSQU0gYnVmZmVyIFttZW0gMHgxZmZlMDAwMC0weDFmZmZmZmZmXQpbICAgIDAuNjMx
MTMyXSBORVQ6IFJlZ2lzdGVyZWQgcHJvdG9jb2wgZmFtaWx5IDgKWyAgICAwLjY0NDEzOV0g
TkVUOiBSZWdpc3RlcmVkIHByb3RvY29sIGZhbWlseSAyMApbICAgIDAuNjQ1NDQ4XSBIUEVU
OiAzIHRpbWVycyBpbiB0b3RhbCwgMCB0aW1lcnMgd2lsbCBiZSB1c2VkIGZvciBwZXItY3B1
IHRpbWVyClsgICAgMC42NDcyNTddIGNsb2Nrc291cmNlOiBTd2l0Y2hlZCB0byBjbG9ja3Nv
dXJjZSBrdm0tY2xvY2sKWyAgICAwLjY5MjU5M10gVkZTOiBEaXNrIHF1b3RhcyBkcXVvdF82
LjYuMApbICAgIDAuNjkzMDY1XSBWRlM6IERxdW90LWNhY2hlIGhhc2ggdGFibGUgZW50cmll
czogNTEyIChvcmRlciAwLCA0MDk2IGJ5dGVzKQpbICAgIDAuNjkzOTQ1XSBwbnA6IFBuUCBB
Q1BJIGluaXQKWyAgICAwLjY5NDQ5MF0gcG5wIDAwOjAwOiBQbHVnIGFuZCBQbGF5IEFDUEkg
ZGV2aWNlLCBJRHMgUE5QMGIwMCAoYWN0aXZlKQpbICAgIDAuNjk1MjY5XSBwbnAgMDA6MDE6
IFBsdWcgYW5kIFBsYXkgQUNQSSBkZXZpY2UsIElEcyBQTlAwMzAzIChhY3RpdmUpClsgICAg
MC42OTYwMTNdIHBucCAwMDowMjogUGx1ZyBhbmQgUGxheSBBQ1BJIGRldmljZSwgSURzIFBO
UDBmMTMgKGFjdGl2ZSkKWyAgICAwLjY5NjcwNV0gcG5wIDAwOjAzOiBbZG1hIDJdClsgICAg
MC42OTcwNzRdIHBucCAwMDowMzogUGx1ZyBhbmQgUGxheSBBQ1BJIGRldmljZSwgSURzIFBO
UDA3MDAgKGFjdGl2ZSkKWyAgICAwLjY5Nzg4NF0gcG5wIDAwOjA0OiBQbHVnIGFuZCBQbGF5
IEFDUEkgZGV2aWNlLCBJRHMgUE5QMDQwMCAoYWN0aXZlKQpbICAgIDAuNjk4Njc5XSBwbnAg
MDA6MDU6IFBsdWcgYW5kIFBsYXkgQUNQSSBkZXZpY2UsIElEcyBQTlAwNTAxIChhY3RpdmUp
ClsgICAgMC42OTk0NzRdIHBucCAwMDowNjogUGx1ZyBhbmQgUGxheSBBQ1BJIGRldmljZSwg
SURzIFBOUDA1MDEgKGFjdGl2ZSkKWyAgICAwLjcwMDc5NV0gcG5wOiBQblAgQUNQSTogZm91
bmQgNyBkZXZpY2VzClsgICAgMC43MTk2MTFdIGNsb2Nrc291cmNlOiBhY3BpX3BtOiBtYXNr
OiAweGZmZmZmZiBtYXhfY3ljbGVzOiAweGZmZmZmZiwgbWF4X2lkbGVfbnM6IDIwODU3MDEw
MjQgbnMKWyAgICAwLjcyMDYwM10gcGNpX2J1cyAwMDAwOjAwOiByZXNvdXJjZSA0IFtpbyAg
MHgwMDAwLTB4MGNmNyB3aW5kb3ddClsgICAgMC43MjEyNjRdIHBjaV9idXMgMDAwMDowMDog
cmVzb3VyY2UgNSBbaW8gIDB4MGQwMC0weGZmZmYgd2luZG93XQpbICAgIDAuNzIxOTAyXSBw
Y2lfYnVzIDAwMDA6MDA6IHJlc291cmNlIDYgW21lbSAweDAwMGEwMDAwLTB4MDAwYmZmZmYg
d2luZG93XQpbICAgIDAuNzIyNjE5XSBwY2lfYnVzIDAwMDA6MDA6IHJlc291cmNlIDcgW21l
bSAweDIwMDAwMDAwLTB4ZmViZmZmZmYgd2luZG93XQpbICAgIDAuNzIzNTQwXSBORVQ6IFJl
Z2lzdGVyZWQgcHJvdG9jb2wgZmFtaWx5IDIKWyAgICAwLjcyNDQxMl0gdGNwX2xpc3Rlbl9w
b3J0YWRkcl9oYXNoIGhhc2ggdGFibGUgZW50cmllczogMjU2IChvcmRlcjogMiwgMTg0MzIg
Ynl0ZXMpClsgICAgMC43MjUyODBdIFRDUCBlc3RhYmxpc2hlZCBoYXNoIHRhYmxlIGVudHJp
ZXM6IDQwOTYgKG9yZGVyOiAzLCAzMjc2OCBieXRlcykKWyAgICAwLjcyNjA2MV0gVENQIGJp
bmQgaGFzaCB0YWJsZSBlbnRyaWVzOiA0MDk2IChvcmRlcjogNiwgMjYyMTQ0IGJ5dGVzKQpb
ICAgIDAuNzI2ODk2XSBUQ1A6IEhhc2ggdGFibGVzIGNvbmZpZ3VyZWQgKGVzdGFibGlzaGVk
IDQwOTYgYmluZCA0MDk2KQpbICAgIDAuNzI4MzMzXSBVRFAgaGFzaCB0YWJsZSBlbnRyaWVz
OiAyNTYgKG9yZGVyOiAzLCA0MDk2MCBieXRlcykKWyAgICAwLjcyODk4NV0gVURQLUxpdGUg
aGFzaCB0YWJsZSBlbnRyaWVzOiAyNTYgKG9yZGVyOiAzLCA0MDk2MCBieXRlcykKWyAgICAw
LjcyOTc1MF0gTkVUOiBSZWdpc3RlcmVkIHByb3RvY29sIGZhbWlseSAxClsgICAgMC43MzAz
ODldIHBjaSAwMDAwOjAwOjAxLjA6IFBJSVgzOiBFbmFibGluZyBQYXNzaXZlIFJlbGVhc2UK
WyAgICAwLjczMDk5N10gcGNpIDAwMDA6MDA6MDAuMDogTGltaXRpbmcgZGlyZWN0IFBDSS9Q
Q0kgdHJhbnNmZXJzClsgICAgMC43MzE2NjVdIHBjaSAwMDAwOjAwOjAxLjA6IEFjdGl2YXRp
bmcgSVNBIERNQSBoYW5nIHdvcmthcm91bmRzClsgICAgMC43MzI0MTJdIHBjaSAwMDAwOjAw
OjAyLjA6IFZpZGVvIGRldmljZSB3aXRoIHNoYWRvd2VkIFJPTSBhdCBbbWVtIDB4MDAwYzAw
MDAtMHgwMDBkZmZmZl0KWyAgICAwLjczMzI4N10gUENJOiBDTFMgMCBieXRlcywgZGVmYXVs
dCA2NApbICAgIDAuNzMzODc3XSBVbnBhY2tpbmcgaW5pdHJhbWZzLi4uClsgICAgMi4yMjI4
MDddIEZyZWVpbmcgaW5pdHJkIG1lbW9yeTogMjM2NTZLClsgICAgMi4yMjM2MjNdIGNsb2Nr
c291cmNlOiB0c2M6IG1hc2s6IDB4ZmZmZmZmZmZmZmZmZmZmZiBtYXhfY3ljbGVzOiAweDIx
MjczMWE1MzAxLCBtYXhfaWRsZV9uczogNDQwNzk1MzE3MTIzIG5zClsgICAgMi4yMjQ4MjRd
IGNoZWNrOiBTY2FubmluZyBmb3IgbG93IG1lbW9yeSBjb3JydXB0aW9uIGV2ZXJ5IDYwIHNl
Y29uZHMKWyAgICAyLjIzNTk0MV0gZGVzM19lZGUteDg2XzY0OiBwZXJmb3JtYW5jZSBvbiB0
aGlzIENQVSB3b3VsZCBiZSBzdWJvcHRpbWFsOiBkaXNhYmxpbmcgZGVzM19lZGUteDg2XzY0
LgpbICAgIDIuMjM2ODgyXSBibG93ZmlzaC14ODZfNjQ6IHBlcmZvcm1hbmNlIG9uIHRoaXMg
Q1BVIHdvdWxkIGJlIHN1Ym9wdGltYWw6IGRpc2FibGluZyBibG93ZmlzaC14ODZfNjQuClsg
ICAgMi4yMzkyMzNdIHR3b2Zpc2gteDg2XzY0LTN3YXk6IHBlcmZvcm1hbmNlIG9uIHRoaXMg
Q1BVIHdvdWxkIGJlIHN1Ym9wdGltYWw6IGRpc2FibGluZyB0d29maXNoLXg4Nl82NC0zd2F5
LgpbICAgIDIuMjQwMjYzXSBDUFUgZmVhdHVyZSAnQVZYIHJlZ2lzdGVycycgaXMgbm90IHN1
cHBvcnRlZC4KWyAgICAyLjI0MDgwNF0gQ1BVIGZlYXR1cmUgJ0FWWCByZWdpc3RlcnMnIGlz
IG5vdCBzdXBwb3J0ZWQuClsgICAgMi4yNDEzNzZdIENQVSBmZWF0dXJlICdBVlggcmVnaXN0
ZXJzJyBpcyBub3Qgc3VwcG9ydGVkLgpbICAgIDguODUyODA5XSBJbml0aWFsaXNlIHN5c3Rl
bSB0cnVzdGVkIGtleXJpbmdzClsgICAgOC44NTQ3MTRdIHdvcmtpbmdzZXQ6IHRpbWVzdGFt
cF9iaXRzPTU2IG1heF9vcmRlcj0xNyBidWNrZXRfb3JkZXI9MApbICAgIDguODU3MjU1XSBv
cmFuZ2Vmc19kZWJ1Z2ZzX2luaXQ6IGNhbGxlZCB3aXRoIGRlYnVnIG1hc2s6IDpub25lOiA6
MDoKWyAgICA4Ljg1ODMzN10gb3JhbmdlZnNfaW5pdDogbW9kdWxlIHZlcnNpb24gdXBzdHJl
YW0gbG9hZGVkClsgICAgOC44ODA3NzddIE5FVDogUmVnaXN0ZXJlZCBwcm90b2NvbCBmYW1p
bHkgMzgKWyAgICA4Ljg4MTk5NF0gS2V5IHR5cGUgYXN5bW1ldHJpYyByZWdpc3RlcmVkClsg
ICAgOS4wMDY2MjJdIFN0cmluZyBzZWxmdGVzdHMgc3VjY2VlZGVkClsgICAgOS4wMDc0NzBd
IGdwaW9faXQ4Nzogbm8gZGV2aWNlClsgICAgOS4wMDgwNTddIGdwaW9fd2luYm9uZDogY2hp
cCBJRCBhdCAyZSBpcyBmZmZmClsgICAgOS4wMDg1MzNdIGdwaW9fd2luYm9uZDogbm90IGFu
IG91ciBjaGlwClsgICAgOS4wMDg5NjFdIGdwaW9fd2luYm9uZDogY2hpcCBJRCBhdCA0ZSBp
cyBmZmZmClsgICAgOS4wMDk0NTFdIGdwaW9fd2luYm9uZDogbm90IGFuIG91ciBjaGlwClsg
ICAgOS4wMjMyMjldIHNocGNocDogU3RhbmRhcmQgSG90IFBsdWcgUENJIENvbnRyb2xsZXIg
RHJpdmVyIHZlcnNpb246IDAuNApbICAgIDkuMDI0MDI3XSBzd2l0Y2h0ZWM6IGxvYWRlZC4K
WyAgICA5LjAyNDcwOF0gaW5wdXQ6IFBvd2VyIEJ1dHRvbiBhcyAvZGV2aWNlcy9MTlhTWVNU
TTowMC9MTlhQV1JCTjowMC9pbnB1dC9pbnB1dDAKWyAgICA5LjAzMjIzMV0gQUNQSTogUG93
ZXIgQnV0dG9uIFtQV1JGXQpbICAgIDkuMDMzMDU4XSBpbnB1dDogUG93ZXIgQnV0dG9uIGFz
IC9kZXZpY2VzL0xOWFNZU1RNOjAwL0xOWFBXUkJOOjAwL2lucHV0L2lucHV0MQpbICAgIDku
MDMzOTE4XSBBQ1BJOiBQb3dlciBCdXR0b24gW1BXUkZdClsgICAgOS4wMzQ0MTRdIFdhcm5p
bmc6IFByb2Nlc3NvciBQbGF0Zm9ybSBMaW1pdCBldmVudCBkZXRlY3RlZCwgYnV0IG5vdCBo
YW5kbGVkLgpbICAgIDkuMDM1MTUzXSBDb25zaWRlciBjb21waWxpbmcgQ1BVZnJlcSBzdXBw
b3J0IGludG8geW91ciBrZXJuZWwuClsgICAgOS4wNDk2NTBdIGlvYXRkbWE6IEludGVsKFIp
IFF1aWNrRGF0YSBUZWNobm9sb2d5IERyaXZlciA0LjAwClsgICAgOS4wNTA4MDVdIFNlcmlh
bDogODI1MC8xNjU1MCBkcml2ZXIsIDQgcG9ydHMsIElSUSBzaGFyaW5nIGRpc2FibGVkClsg
ICAgOS4wODQ1MTRdIDAwOjA1OiB0dHlTMCBhdCBJL08gMHgzZjggKGlycSA9IDQsIGJhc2Vf
YmF1ZCA9IDExNTIwMCkgaXMgYSAxNjU1MEEKWyAgICA5LjA4NzkzNV0gcHJpbnRrOiBjb25z
b2xlIFt0dHlTMF0gZGlzYWJsZWQKWyAgICA5LjExMjg3MV0gMDA6MDU6IHR0eVMwIGF0IEkv
TyAweDNmOCAoaXJxID0gNCwgYmFzZV9iYXVkID0gMTE1MjAwKSBpcyBhIDE2NTUwQQpbICAg
IDkuNDc2MTYzXSBwcmludGs6IGNvbnNvbGUgW3R0eVMwXSBlbmFibGVkClsgICAgOS41MDE1
NTZdIDAwOjA2OiB0dHlTMSBhdCBJL08gMHgyZjggKGlycSA9IDMsIGJhc2VfYmF1ZCA9IDEx
NTIwMCkgaXMgYSAxNjU1MEEKWyAgICA5LjU0MDM2N10gMDA6MDY6IHR0eVMxIGF0IEkvTyAw
eDJmOCAoaXJxID0gMywgYmFzZV9iYXVkID0gMTE1MjAwKSBpcyBhIDE2NTUwQQpbICAgIDku
NTQzNDA4XSBJbml0aWFsaXppbmcgTm96b21pIGRyaXZlciAyLjFkClsgICAgOS41NDQwMjdd
IExpbnV4IGFncGdhcnQgaW50ZXJmYWNlIHYwLjEwMwpbICAgIDkuNTQ1Mzc5XSBkdW1teS1p
cnE6IG5vIElSUSBnaXZlbi4gIFVzZSBpcnE9TgpbICAgIDkuNTQ1OTQxXSBQaGFudG9tIExp
bnV4IERyaXZlciwgdmVyc2lvbiBuMC45LjgsIGluaXQgT0sKWyAgICA5LjU0NjYyN10gU2ls
aWNvbiBMYWJzIEMyIHBvcnQgc3VwcG9ydCB2LiAwLjUxLjAgLSAoQykgMjAwNyBSb2RvbGZv
IEdpb21ldHRpClsgICAgOS41NDc2ODFdIEd1ZXN0IHBlcnNvbmFsaXR5IGluaXRpYWxpemVk
IGFuZCBpcyBpbmFjdGl2ZQpbICAgIDkuNTQ4Nzg0XSBWTUNJIGhvc3QgZGV2aWNlIHJlZ2lz
dGVyZWQgKG5hbWU9dm1jaSwgbWFqb3I9MTAsIG1pbm9yPTYxKQpbICAgIDkuNTQ5NDk3XSBJ
bml0aWFsaXplZCBob3N0IHBlcnNvbmFsaXR5ClsgICAgOS41NTEzMDZdIGxpYnBoeTogRml4
ZWQgTURJTyBCdXM6IHByb2JlZApbICAgIDkuNTUyMzAxXSB2Y2FuOiBWaXJ0dWFsIENBTiBp
bnRlcmZhY2UgZHJpdmVyClsgICAgOS41NTI3NzddIHZ4Y2FuOiBWaXJ0dWFsIENBTiBUdW5u
ZWwgZHJpdmVyClsgICAgOS41NTMyNDVdIHNsY2FuOiBzZXJpYWwgbGluZSBDQU4gaW50ZXJm
YWNlIGRyaXZlcgpbICAgIDkuNTUzNzU1XSBzbGNhbjogMTAgZHluYW1pYyBpbnRlcmZhY2Ug
Y2hhbm5lbHMuClsgICAgOS41NTQyNjJdIENBTiBkZXZpY2UgZHJpdmVyIGludGVyZmFjZQpb
ICAgIDkuNTU0Njg3XSBzamExMDAwIENBTiBuZXRkZXZpY2UgZHJpdmVyClsgICAgOS41NTUx
ODhdIHBjbmV0MzI6IHBjbmV0MzIuYzp2MS4zNSAyMS5BcHIuMjAwOCB0c2JvZ2VuZEBhbHBo
YS5mcmFua2VuLmRlClsgICAgOS41NTYwNDhdIHRodW5kZXJfeGN2LCB2ZXIgMS4wClsgICAg
OS41NTY1NTBdIHYxLjAxLWUgKDIuNCBwb3J0KSBTZXAtMTEtMjAwNiAgRG9uYWxkIEJlY2tl
ciA8YmVja2VyQHNjeWxkLmNvbT4KWyAgICA5LjU1NjU1MF0gICBodHRwOi8vd3d3LnNjeWxk
LmNvbS9uZXR3b3JrL2RyaXZlcnMuaHRtbApbICAgIDkuNTU3OTc1XSBlMTAwMDogSW50ZWwo
UikgUFJPLzEwMDAgTmV0d29yayBEcml2ZXIgLSB2ZXJzaW9uIDcuMy4yMS1rOC1OQVBJClsg
ICAgOS41NTg3MTddIGUxMDAwOiBDb3B5cmlnaHQgKGMpIDE5OTktMjAwNiBJbnRlbCBDb3Jw
b3JhdGlvbi4KWyAgICA5Ljc1NTY0MV0gUENJIEludGVycnVwdCBMaW5rIFtMTktDXSBlbmFi
bGVkIGF0IElSUSAxMQpbICAgMTAuMjAwMDUyXSBlMTAwMCAwMDAwOjAwOjAzLjAgZXRoMDog
KFBDSTozM01IejozMi1iaXQpIDUyOjU0OjAwOjEyOjM0OjU2ClsgICAxMC4yMDA4NjZdIGUx
MDAwIDAwMDA6MDA6MDMuMCBldGgwOiBJbnRlbChSKSBQUk8vMTAwMCBOZXR3b3JrIENvbm5l
Y3Rpb24KWyAgIDExLjAyMzM2NF0gZTEwMDAgMDAwMDowMDowMy4wIGV0aDA6IChQQ0k6MzNN
SHo6MzItYml0KSA1Mjo1NDowMDoxMjozNDo1NgpbICAgMTEuMDI0MTA0XSBlMTAwMCAwMDAw
OjAwOjAzLjAgZXRoMDogSW50ZWwoUikgUFJPLzEwMDAgTmV0d29yayBDb25uZWN0aW9uClsg
ICAxMS4wMjUwNTBdIFFMb2dpYy9OZXRYZW4gTmV0d29yayBEcml2ZXIgdjQuMC44MgpbICAg
MTEuMDI1NzYwXSBQUFAgZ2VuZXJpYyBkcml2ZXIgdmVyc2lvbiAyLjQuMgpbICAgMTEuMDI2
NDM1XSBNYWRnZSBBVE0gQW1iYXNzYWRvciBkcml2ZXIgdmVyc2lvbiAxLjIuNApbICAgMTEu
MDI3MDA3XSBNYWRnZSBBVE0gSG9yaXpvbiBbVWx0cmFdIGRyaXZlciB2ZXJzaW9uIDEuMi4x
ClsgICAxMS4wMjc2MTRdIGZvcmUyMDBlOiBGT1JFIFN5c3RlbXMgMjAwRS1zZXJpZXMgQVRN
IGRyaXZlciAtIHZlcnNpb24gMC4zZQpbICAgMTEuMDI4MzU3XSBhZHVtbXk6IHZlcnNpb24g
MS4wClsgICAxMS4wMjg5OTRdIGk4MDQyOiBQTlA6IFBTLzIgQ29udHJvbGxlciBbUE5QMDMw
MzpLQkQsUE5QMGYxMzpNT1VdIGF0IDB4NjAsMHg2NCBpcnEgMSwxMgpbICAgMTEuMDU4OTU1
XSBzZXJpbzogaTgwNDIgS0JEIHBvcnQgYXQgMHg2MCwweDY0IGlycSAxClsgICAxMS4wNTk3
NTRdIHNlcmlvOiBpODA0MiBBVVggcG9ydCBhdCAweDYwLDB4NjQgaXJxIDEyClsgICAxMS4w
NjA4ODZdIHJ0Yy10ZXN0IHJ0Yy10ZXN0LjA6IHJlZ2lzdGVyZWQgYXMgcnRjMApbICAgMTEu
MDYxODYyXSBydGMtdGVzdCBydGMtdGVzdC4wOiByZWdpc3RlcmVkIGFzIHJ0YzAKWyAgIDEx
LjA2Njk2MF0gcnRjIHJ0YzE6IGludmFsaWQgYWxhcm0gdmFsdWU6IDE4NDQ2NzQ0MDczNzAz
Mjk1MDIwLTA2LTAzVDA1OjI4OjI1ClsgICAxMS4wNjc4NThdIHJ0Yy10ZXN0IHJ0Yy10ZXN0
LjE6IHJlZ2lzdGVyZWQgYXMgcnRjMQpbICAgMTEuMDcyNDE1XSBpbnB1dDogQVQgVHJhbnNs
YXRlZCBTZXQgMiBrZXlib2FyZCBhcyAvZGV2aWNlcy9wbGF0Zm9ybS9pODA0Mi9zZXJpbzAv
aW5wdXQvaW5wdXQzClsgICAxMS4wNzM5MTJdIHJ0YyBydGMxOiBpbnZhbGlkIGFsYXJtIHZh
bHVlOiAxODQ0Njc0NDA3MzcwMzI5NTAyMC0wNi0wM1QwNToyODoyNQpbICAgMTEuMDc1ODMy
XSBydGMtdGVzdCBydGMtdGVzdC4xOiByZWdpc3RlcmVkIGFzIHJ0YzEKWyAgIDExLjA3Njc4
NV0gaW5wdXQ6IEFUIFRyYW5zbGF0ZWQgU2V0IDIga2V5Ym9hcmQgYXMgL2RldmljZXMvcGxh
dGZvcm0vaTgwNDIvc2VyaW8wL2lucHV0L2lucHV0NApbICAgMTEuMDgxMTk2XSBydGMgcnRj
MjogaW52YWxpZCBhbGFybSB2YWx1ZTogMTg0NDY3NDQwNzM3MDMyOTUwMjAtMDYtMDNUMDU6
Mjg6MjUKWyAgIDExLjA4MjA0Ml0gcnRjLXRlc3QgcnRjLXRlc3QuMjogcmVnaXN0ZXJlZCBh
cyBydGMyClsgICAxMS4wODc1ODFdIHJ0YyBydGMyOiBpbnZhbGlkIGFsYXJtIHZhbHVlOiAx
ODQ0Njc0NDA3MzcwMzI5NTAyMC0wNi0wM1QwNToyODoyNQpbICAgMTEuMDg4NTM1XSBydGMt
dGVzdCBydGMtdGVzdC4yOiByZWdpc3RlcmVkIGFzIHJ0YzIKWyAgIDExLjA4OTI3OV0gcGlp
eDRfc21idXMgMDAwMDowMDowMS4zOiBTTUJ1cyBIb3N0IENvbnRyb2xsZXIgYXQgMHg3MDAs
IHJldmlzaW9uIDAKWyAgIDExLjEwNDQ3Nl0gcGlpeDRfc21idXMgMDAwMDowMDowMS4zOiBT
TUJ1cyBIb3N0IENvbnRyb2xsZXIgYXQgMHg3MDAsIHJldmlzaW9uIDAKWyAgIDExLjExODY5
MV0gYjJjMi1mbGV4Y29wOiBCMkMyIEZsZXhjb3BJSS9JSShiKS9JSUkgZGlnaXRhbCBUViBy
ZWNlaXZlciBjaGlwIGxvYWRlZCBzdWNjZXNzZnVsbHkKWyAgIDExLjExOTY2N10gbmdlbmU6
IG5HZW5lIFBDSUUgYnJpZGdlIGRyaXZlciwgQ29weXJpZ2h0IChDKSAyMDA1LTIwMDcgTWlj
cm9uYXMKWyAgIDExLjEyMDQ1MF0gc2FhNzE0NjogcmVnaXN0ZXIgZXh0ZW5zaW9uICdNdWx0
aW1lZGlhIGVYdGVuc2lvbiBCb2FyZCcKWyAgIDExLjEyMTEyN10gc2FhNzE0NjogcmVnaXN0
ZXIgZXh0ZW5zaW9uICdoZXhpdW0gSFYtUENJNiBPcmlvbicKWyAgIDExLjEyMTc3M10gY3gy
NTgyMTogZHJpdmVyIGxvYWRlZApbICAgMTEuMTIyMzk1XSBwcHMgcHBzMDogbmV3IFBQUyBz
b3VyY2Uga3RpbWVyClsgICAxMS4xMjI4MzJdIHBwcyBwcHMwOiBrdGltZXIgUFBTIHNvdXJj
ZSByZWdpc3RlcmVkClsgICAxMS4xMjM0ODhdIERyaXZlciBmb3IgMS13aXJlIERhbGxhcyBu
ZXR3b3JrIHByb3RvY29sLgpbICAgMTEuMTI0MTY5XSB3MV9mMGRfaW5pdCgpClsgICAxMS4x
NDMyNjBdIGY3MTg4MmZnOiBOb3QgYSBGaW50ZWsgZGV2aWNlClsgICAxMS4xNDM3MDFdIGY3
MTg4MmZnOiBOb3QgYSBGaW50ZWsgZGV2aWNlClsgICAxMS4xOTcyNzBdIHBjODczNjA6IFBD
ODczNnggbm90IGRldGVjdGVkLCBtb2R1bGUgbm90IGluc2VydGVkClsgICAxMS4xOTc5MjBd
IHNjaDU2eHhfY29tbW9uOiBVbnN1cHBvcnRlZCBkZXZpY2UgaWQ6IDB4ZmYKWyAgIDExLjE5
ODQ4NV0gc2NoNTZ4eF9jb21tb246IFVuc3VwcG9ydGVkIGRldmljZSBpZDogMHhmZgpbICAg
MTEuMjAzMzYzXSBhZHZhbnRlY2h3ZHQ6IFdEVCBkcml2ZXIgZm9yIEFkdmFudGVjaCBzaW5n
bGUgYm9hcmQgY29tcHV0ZXIgaW5pdGlhbGlzaW5nClsgICAxMS4yMDQ0NjhdIGFkdmFudGVj
aHdkdDogaW5pdGlhbGl6ZWQuIHRpbWVvdXQ9NjAgc2VjIChub3dheW91dD0wKQpbICAgMTEu
MjA1MTIyXSBhbGltNzEwMV93ZHQ6IFN0ZXZlIEhpbGwgPHN0ZXZlQG5hdmFoby5jby51az4K
WyAgIDExLjIwNTcxMV0gYWxpbTcxMDFfd2R0OiBBTGkgTTcxMDEgUE1VIG5vdCBwcmVzZW50
IC0gV0RUIG5vdCBzZXQKWyAgIDExLjIwNjM2NV0gaWI3MDB3ZHQ6IFdEVCBkcml2ZXIgZm9y
IElCNzAwIHNpbmdsZSBib2FyZCBjb21wdXRlciBpbml0aWFsaXNpbmcKWyAgIDExLjIwNzI1
NF0gaWI3MDB3ZHQ6IFNUQVJUIG1ldGhvZCBJL08gNDQzIGlzIG5vdCBhdmFpbGFibGUKWyAg
IDExLjIwNzg0M10gaWI3MDB3ZHQ6IHByb2JlIG9mIGliNzAwd2R0IGZhaWxlZCB3aXRoIGVy
cm9yIC01ClsgICAxMS4yMDg1NTldIHdhZmVyNTgyM3dkdDogV0RUIGRyaXZlciBmb3IgV2Fm
ZXIgNTgyMyBzaW5nbGUgYm9hcmQgY29tcHV0ZXIgaW5pdGlhbGlzaW5nClsgICAxMS4yMDkz
OTddIHdhZmVyNTgyM3dkdDogSS9PIGFkZHJlc3MgMHgwNDQzIGFscmVhZHkgaW4gdXNlClsg
ICAxMS4yMTYyMDddIHdhdGNoZG9nOiBpNjMwMEVTQiB0aW1lcjogY2Fubm90IHJlZ2lzdGVy
IG1pc2NkZXYgb24gbWlub3I9MTMwIChlcnI9LTE2KS4KWyAgIDExLjIxNzAwNF0gd2F0Y2hk
b2c6IGk2MzAwRVNCIHRpbWVyOiBhIGxlZ2FjeSB3YXRjaGRvZyBtb2R1bGUgaXMgcHJvYmFi
bHkgcHJlc2VudC4KWyAgIDExLjIxOTAzMV0gaTYzMDBFU0IgdGltZXIgMDAwMDowMDowNC4w
OiBpbml0aWFsaXplZCAoMHgoX19fX3B0cnZhbF9fX18pKS4gaGVhcnRiZWF0PTMwIHNlYyAo
bm93YXlvdXQ9MCkKWyAgIDExLjIyMjU4Nl0gd2F0Y2hkb2c6IGk2MzAwRVNCIHRpbWVyOiBj
YW5ub3QgcmVnaXN0ZXIgbWlzY2RldiBvbiBtaW5vcj0xMzAgKGVycj0tMTYpLgpbICAgMTEu
MjMwNDQ3XSB3YXRjaGRvZzogaTYzMDBFU0IgdGltZXI6IGEgbGVnYWN5IHdhdGNoZG9nIG1v
ZHVsZSBpcyBwcm9iYWJseSBwcmVzZW50LgpbICAgMTEuMjMyMjY1XSBpNjMwMEVTQiB0aW1l
ciAwMDAwOjAwOjA0LjA6IGluaXRpYWxpemVkICgweChfX19fcHRydmFsX19fXykpLiBoZWFy
dGJlYXQ9MzAgc2VjIChub3dheW91dD0wKQpbICAgMTEuMjM0MzMxXSBpVENPX3dkdDogSW50
ZWwgVENPIFdhdGNoRG9nIFRpbWVyIERyaXZlciB2MS4xMQpbICAgMTEuMjM1MDE1XSB3ODM4
NzdmX3dkdDogSS9PIGFkZHJlc3MgMHgwNDQzIGFscmVhZHkgaW4gdXNlClsgICAxMS4yMzc2
MzZdIHc4Mzk3N2Zfd2R0OiBkcml2ZXIgdjEuMDAKWyAgIDExLjIzODAyNl0gdzgzOTc3Zl93
ZHQ6IGNhbm5vdCByZWdpc3RlciBtaXNjZGV2IG9uIG1pbm9yPTEzMCAoZXJyPS0xNikKWyAg
IDExLjIzOTkyOF0gbGVkc19zczQyMDA6IG5vIExFRCBkZXZpY2VzIGZvdW5kClsgICAxMS4y
NDE4MThdIGFzaG1lbTogaW5pdGlhbGl6ZWQKWyAgIDExLjI0NDM3Ml0gYXhpcy1maWZvIGRy
aXZlciBsb2FkZWQgd2l0aCBwYXJhbWV0ZXJzIHJlYWRfdGltZW91dCA9IDEwMDAsIHdyaXRl
X3RpbWVvdXQgPSAxMDAwClsgICAxMS4yNDg2MDddIEludGVsKFIpIFBDSS1FIE5vbi1UcmFu
c3BhcmVudCBCcmlkZ2UgRHJpdmVyIDIuMApbICAgMTEuMjUwMDc3XSBnbnNzOiBHTlNTIGRy
aXZlciByZWdpc3RlcmVkIHdpdGggbWFqb3IgMjM3ClsgICAxMS4yNTA4NTNdIG5ldGVtOiB2
ZXJzaW9uIDEuMwpbICAgMTEuMjUxNDAwXSBORVQ6IFJlZ2lzdGVyZWQgcHJvdG9jb2wgZmFt
aWx5IDEwClsgICAxMS4yNjM1ODZdIFNlZ21lbnQgUm91dGluZyB3aXRoIElQdjYKWyAgIDEx
LjI2NDUyNV0gc2l0OiBJUHY2LCBJUHY0IGFuZCBNUExTIG92ZXIgSVB2NCB0dW5uZWxpbmcg
ZHJpdmVyClsgICAxMS4yNjU3NTddIE5FVDogUmVnaXN0ZXJlZCBwcm90b2NvbCBmYW1pbHkg
MTcKWyAgIDExLjI2NjM0MF0gTkVUOiBSZWdpc3RlcmVkIHByb3RvY29sIGZhbWlseSAxNQpb
ICAgMTEuMjY2ODE4XSBORVQ6IFJlZ2lzdGVyZWQgcHJvdG9jb2wgZmFtaWx5IDUKWyAgIDEx
LjI2NzQyOF0gTkVUOiBSZWdpc3RlcmVkIHByb3RvY29sIGZhbWlseSA5ClsgICAxMS4yNjc5
MDddIFgyNTogTGludXggVmVyc2lvbiAwLjIKWyAgIDExLjI2ODMxNV0gY2FuOiBjb250cm9s
bGVyIGFyZWEgbmV0d29yayBjb3JlIChyZXYgMjAxNzA0MjUgYWJpIDkpClsgICAxMS4yNjg5
NjJdIE5FVDogUmVnaXN0ZXJlZCBwcm90b2NvbCBmYW1pbHkgMjkKWyAgIDExLjI2OTQ3MV0g
Y2FuOiBicm9hZGNhc3QgbWFuYWdlciBwcm90b2NvbCAocmV2IDIwMTcwNDI1IHQpClsgICAx
MS4yNzAwNzNdIGxlYzpsYW5lX21vZHVsZV9pbml0OiBsZWMuYzogaW5pdGlhbGl6ZWQKWyAg
IDExLjI4ODc5Ml0gTkVUOiBSZWdpc3RlcmVkIHByb3RvY29sIGZhbWlseSAzNQpbICAgMTEu
Mjk0NDY1XSA5cG5ldDogSW5zdGFsbGluZyA5UDIwMDAgc3VwcG9ydApbICAgMTEuMjk1MDE3
XSBORVQ6IFJlZ2lzdGVyZWQgcHJvdG9jb2wgZmFtaWx5IDM3ClsgICAxMS4yOTU1MTddIHN0
YXJ0IHBsaXN0IHRlc3QKWyAgIDExLjI5NzYxMl0gZW5kIHBsaXN0IHRlc3QKWyAgIDExLjI5
ODE2MV0gLi4uIEFQSUMgSUQ6ICAgICAgMDAwMDAwMDAgKDApClsgICAxMS4yOTg2MDddIC4u
LiBBUElDIFZFUlNJT046IDAxMDUwMDE0ClsgICAxMS4yOTg5OTZdIDAwMDAwMDAwMDAwMDAw
MDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAKWyAg
IDExLjI5OTE1MV0gMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAw
MDAwMDAwMDAwMDAwMDAwMDAwMDAwMApbICAgMTEuMzAxMTYwXSBudW1iZXIgb2YgTVAgSVJR
IHNvdXJjZXM6IDE1LgpbICAgMTEuMzAxNTk1XSBudW1iZXIgb2YgSU8tQVBJQyAjMCByZWdp
c3RlcnM6IDI0LgpbICAgMTEuMzAyMDQ5XSB0ZXN0aW5nIHRoZSBJTyBBUElDLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4KWyAgIDExLjMwMjU5NV0gSU8gQVBJQyAjMC4uLi4uLgpbICAgMTEu
MzAyODk2XSAuLi4uIHJlZ2lzdGVyICMwMDogMDAwMDAwMDAKWyAgIDExLjMwMzI5OF0gLi4u
Li4uLiAgICA6IHBoeXNpY2FsIEFQSUMgaWQ6IDAwClsgICAxMS4zMDM3MzddIC4uLi4uLi4g
ICAgOiBEZWxpdmVyeSBUeXBlOiAwClsgICAxMS4zMDQxNzJdIC4uLi4uLi4gICAgOiBMVFMg
ICAgICAgICAgOiAwClsgICAxMS4zMDQ1OTFdIC4uLi4gcmVnaXN0ZXIgIzAxOiAwMDE3MDAx
MQpbICAgMTEuMzA0OTkyXSAuLi4uLi4uICAgICA6IG1heCByZWRpcmVjdGlvbiBlbnRyaWVz
OiAxNwpbICAgMTEuMzA1NTI3XSAuLi4uLi4uICAgICA6IFBSUSBpbXBsZW1lbnRlZDogMApb
ICAgMTEuMzA1OTczXSAuLi4uLi4uICAgICA6IElPIEFQSUMgdmVyc2lvbjogMTEKWyAgIDEx
LjMwNjQ0MF0gLi4uLiByZWdpc3RlciAjMDI6IDAwMDAwMDAwClsgICAxMS4zMDY4NDRdIC4u
Li4uLi4gICAgIDogYXJiaXRyYXRpb246IDAwClsgICAxMS4zMDcyNzhdIC4uLi4gSVJRIHJl
ZGlyZWN0aW9uIHRhYmxlOgpbICAgMTEuMzA3NjgwXSBJT0FQSUMgMDoKWyAgIDExLjMwNzkz
Nl0gIHBpbjAwLCBkaXNhYmxlZCwgZWRnZSAsIGhpZ2gsIFYoMDApLCBJUlIoMCksIFMoMCks
IHBoeXNpY2FsLCBEKDAwKSwgTSgwKQpbICAgMTEuMzA4NzYwXSAgcGluMDEsIGVuYWJsZWQg
LCBlZGdlICwgaGlnaCwgVigyMiksIElSUigwKSwgUygwKSwgbG9naWNhbCAsIEQoMDIpLCBN
KDApClsgICAxMS4zMDk1OTNdICBwaW4wMiwgZW5hYmxlZCAsIGVkZ2UgLCBoaWdoLCBWKDMw
KSwgSVJSKDApLCBTKDApLCBsb2dpY2FsICwgRCgwMSksIE0oMCkKWyAgIDExLjMxMDQ1NV0g
IHBpbjAzLCBkaXNhYmxlZCwgZWRnZSAsIGhpZ2gsIFYoMDApLCBJUlIoMCksIFMoMCksIHBo
eXNpY2FsLCBEKDAwKSwgTSgwKQpbICAgMTEuMzExMjg0XSAgcGluMDQsIGRpc2FibGVkLCBl
ZGdlICwgaGlnaCwgVigwMCksIElSUigwKSwgUygwKSwgcGh5c2ljYWwsIEQoMDApLCBNKDAp
ClsgICAxMS4zMTIwNjRdICBwaW4wNSwgZGlzYWJsZWQsIGVkZ2UgLCBoaWdoLCBWKDAwKSwg
SVJSKDApLCBTKDApLCBwaHlzaWNhbCwgRCgwMCksIE0oMCkKWyAgIDExLjMxMjg1M10gIHBp
bjA2LCBkaXNhYmxlZCwgZWRnZSAsIGhpZ2gsIFYoMDApLCBJUlIoMCksIFMoMCksIHBoeXNp
Y2FsLCBEKDAwKSwgTSgwKQpbICAgMTEuMzEzNjc3XSAgcGluMDcsIGRpc2FibGVkLCBlZGdl
ICwgaGlnaCwgVigwMCksIElSUigwKSwgUygwKSwgcGh5c2ljYWwsIEQoMDApLCBNKDApClsg
ICAxMS4zMTQ1NDldICBwaW4wOCwgZGlzYWJsZWQsIGVkZ2UgLCBoaWdoLCBWKDAwKSwgSVJS
KDApLCBTKDApLCBwaHlzaWNhbCwgRCgwMCksIE0oMCkKWyAgIDExLjMxNTM3N10gIHBpbjA5
LCBlbmFibGVkICwgbGV2ZWwsIGhpZ2gsIFYoMjEpLCBJUlIoMCksIFMoMCksIGxvZ2ljYWwg
LCBEKDAyKSwgTSgwKQpbICAgMTEuMzE2MjA0XSAgcGluMGEsIGRpc2FibGVkLCBlZGdlICwg
aGlnaCwgVigwMCksIElSUigwKSwgUygwKSwgcGh5c2ljYWwsIEQoMDApLCBNKDApClsgICAx
MS4zMTcwMTVdICBwaW4wYiwgZGlzYWJsZWQsIGVkZ2UgLCBoaWdoLCBWKDAwKSwgSVJSKDAp
LCBTKDApLCBwaHlzaWNhbCwgRCgwMCksIE0oMCkKWyAgIDExLjMxNzgzOF0gIHBpbjBjLCBl
bmFibGVkICwgZWRnZSAsIGhpZ2gsIFYoMjEpLCBJUlIoMCksIFMoMCksIGxvZ2ljYWwgLCBE
KDAxKSwgTSgwKQpbICAgMTEuMzE4Njk1XSAgcGluMGQsIGRpc2FibGVkLCBlZGdlICwgaGln
aCwgVigwMCksIElSUigwKSwgUygwKSwgcGh5c2ljYWwsIEQoMDApLCBNKDApClsgICAxMS4z
MTk1MTddICBwaW4wZSwgZGlzYWJsZWQsIGVkZ2UgLCBoaWdoLCBWKDAwKSwgSVJSKDApLCBT
KDApLCBwaHlzaWNhbCwgRCgwMCksIE0oMCkKWyAgIDExLjMyMDMxNl0gIHBpbjBmLCBkaXNh
YmxlZCwgZWRnZSAsIGhpZ2gsIFYoMDApLCBJUlIoMCksIFMoMCksIHBoeXNpY2FsLCBEKDAw
KSwgTSgwKQpbICAgMTEuMzIxMTAyXSAgcGluMTAsIGRpc2FibGVkLCBlZGdlICwgaGlnaCwg
VigwMCksIElSUigwKSwgUygwKSwgcGh5c2ljYWwsIEQoMDApLCBNKDApClsgICAxMS4zMjE5
MDhdICBwaW4xMSwgZGlzYWJsZWQsIGVkZ2UgLCBoaWdoLCBWKDAwKSwgSVJSKDApLCBTKDAp
LCBwaHlzaWNhbCwgRCgwMCksIE0oMCkKWyAgIDExLjMzMTY3M10gIHBpbjEyLCBkaXNhYmxl
ZCwgZWRnZSAsIGhpZ2gsIFYoMDApLCBJUlIoMCksIFMoMCksIHBoeXNpY2FsLCBEKDAwKSwg
TSgwKQpbICAgMTEuMzMyNDc4XSAgcGluMTMsIGRpc2FibGVkLCBlZGdlICwgaGlnaCwgVigw
MCksIElSUigwKSwgUygwKSwgcGh5c2ljYWwsIEQoMDApLCBNKDApClsgICAxMS4zMzMyODBd
ICBwaW4xNCwgZGlzYWJsZWQsIGVkZ2UgLCBoaWdoLCBWKDAwKSwgSVJSKDApLCBTKDApLCBw
aHlzaWNhbCwgRCgwMCksIE0oMCkKWyAgIDExLjMzNDA5Ml0gIHBpbjE1LCBkaXNhYmxlZCwg
ZWRnZSAsIGhpZ2gsIFYoMDApLCBJUlIoMCksIFMoMCksIHBoeXNpY2FsLCBEKDAwKSwgTSgw
KQpbICAgMTEuMzM0OTE4XSAgcGluMTYsIGRpc2FibGVkLCBlZGdlICwgaGlnaCwgVigwMCks
IElSUigwKSwgUygwKSwgcGh5c2ljYWwsIEQoMDApLCBNKDApClsgICAxMS4zMzU3MzNdICBw
aW4xNywgZGlzYWJsZWQsIGVkZ2UgLCBoaWdoLCBWKDAwKSwgSVJSKDApLCBTKDApLCBwaHlz
aWNhbCwgRCgwMCksIE0oMCkKWyAgIDExLjMzNjUxOV0gSVJRIHRvIHBpbiBtYXBwaW5nczoK
WyAgIDExLjMzNjg1MV0gSVJRMCAtPiAwOjIKWyAgIDExLjMzNzExMF0gSVJRMSAtPiAwOjEK
WyAgIDExLjMzNzM3Ml0gSVJRMyAtPiAwOjMKWyAgIDExLjMzNzYyN10gSVJRNCAtPiAwOjQK
WyAgIDExLjMzNzg4MF0gSVJRNSAtPiAwOjUKWyAgIDExLjMzODE1NF0gSVJRNiAtPiAwOjYK
WyAgIDExLjMzODQwOV0gSVJRNyAtPiAwOjcKWyAgIDExLjMzODY2MV0gSVJROCAtPiAwOjgK
WyAgIDExLjMzODkxM10gSVJROSAtPiAwOjkKWyAgIDExLjMzOTE4MV0gSVJRMTAgLT4gMDox
MApbICAgMTEuMzM5NDUyXSBJUlExMSAtPiAwOjExClsgICAxMS4zMzk3MjJdIElSUTEyIC0+
IDA6MTIKWyAgIDExLjMzOTk5Ml0gSVJRMTMgLT4gMDoxMwpbICAgMTEuMzQwMjc0XSBJUlEx
NCAtPiAwOjE0ClsgICAxMS4zNDA1NDZdIElSUTE1IC0+IDA6MTUKWyAgIDExLjM0MDgxNV0g
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uIGRvbmUuClsgICAxMS4zNDE3
MzBdIHNjaGVkX2Nsb2NrOiBNYXJraW5nIHN0YWJsZSAoMTExOTQxOTc5MjEsIDE0NzEzNjg3
NCktPigxMTU0MjIxOTM1NCwgLTIwMDg4NDU1OSkKWyAgIDExLjM0MzY1N10gcmVnaXN0ZXJl
ZCB0YXNrc3RhdHMgdmVyc2lvbiAxClsgICAxMS4zNDQwODVdIExvYWRpbmcgY29tcGlsZWQt
aW4gWC41MDkgY2VydGlmaWNhdGVzClsgICAxMS4zNTk5NjNdIEtleSB0eXBlIGJpZ19rZXkg
cmVnaXN0ZXJlZApbICAgMTEuMzYxNDYxXSBLZXkgdHlwZSBlbmNyeXB0ZWQgcmVnaXN0ZXJl
ZApbICAgMTEuMzYyNDUyXSAgIE1hZ2ljIG51bWJlcjogNzo5ODQ6MzQKWyAgIDExLjM3NzI5
Nl0gVW5yZWdpc3RlciBwdiBzaGFyZWQgbWVtb3J5IGZvciBjcHUgMApbICAgMTEuMzc4MTU0
XSBudW1hX3JlbW92ZV9jcHUgY3B1IDAgbm9kZSAwOiBtYXNrIG5vdyAxClsgICAxMS4zODAy
ODBdIENQVSAwIGlzIG5vdyBvZmZsaW5lClsgICAxMS4zODE4MTRdIEZyZWVpbmcgdW51c2Vk
IGtlcm5lbCBpbWFnZSBtZW1vcnk6IDExMDhLClsgICAxMS4zODQyMThdIFdyaXRlIHByb3Rl
Y3RpbmcgdGhlIGtlcm5lbCByZWFkLW9ubHkgZGF0YTogMTg0MzJrClsgICAxMS4zODYwOTld
IEZyZWVpbmcgdW51c2VkIGtlcm5lbCBpbWFnZSBtZW1vcnk6IDIwMzZLClsgICAxMS4zODY4
MjVdIEZyZWVpbmcgdW51c2VkIGtlcm5lbCBpbWFnZSBtZW1vcnk6IDIyNEsKWyAgIDExLjM4
NzM3N10gUnVuIC9pbml0IGFzIGluaXQgcHJvY2VzcwpbICAgMTEuNDEwNjY3XSByYW5kb206
IGluaXQ6IHVuaW5pdGlhbGl6ZWQgdXJhbmRvbSByZWFkICgxMiBieXRlcyByZWFkKQpLZXJu
ZWwgdGVzdHM6IEJvb3QgT0shClsgICAxMS40ODE3NTVdIGluaXQ6IHBseW1vdXRoIG1haW4g
cHJvY2VzcyAoMTY1KSBraWxsZWQgYnkgU0VHViBzaWduYWwKWyAgIDExLjQ5NjY4OF0gcmFu
ZG9tOiB0cmluaXR5OiB1bmluaXRpYWxpemVkIHVyYW5kb20gcmVhZCAoNCBieXRlcyByZWFk
KQpbICAgMTEuNTQxOTQxXSBpbml0OiBtb3VudGVkLXByb2MgbWFpbiBwcm9jZXNzICgxNzkp
IHRlcm1pbmF0ZWQgd2l0aCBzdGF0dXMgMQptb3VudGFsbDogRXZlbnQgZmFpbGVkClsgICAx
MS41NTQ5MDddIHJhbmRvbTogbW91bnRhbGw6IHVuaW5pdGlhbGl6ZWQgdXJhbmRvbSByZWFk
ICgxMiBieXRlcyByZWFkKQpbICAgMTEuNzE3MjUzXSBpbml0OiBwbHltb3V0aC1sb2cgbWFp
biBwcm9jZXNzICgyMjEpIHRlcm1pbmF0ZWQgd2l0aCBzdGF0dXMgMQpbICAgMTEuNzM1MDA2
XSB1ZGV2ZFsyMzBdOiBzdGFydGluZyB2ZXJzaW9uIDE3NQp1ZGV2ZFsyMzddOiBmYWlsZWQg
dG8gZXhlY3V0ZSAnL3NiaW4vbW9kcHJvYmUnICcvc2Jpbi9tb2Rwcm9iZSAtYnYgYWNwaTpM
TlhTWVNUTTonOiBObyBzdWNoIGZpbGUgb3IgZGlyZWN0b3J5CnVkZXZkWzI0Nl06IGZhaWxl
ZCB0byBleGVjdXRlICcvc2Jpbi9tb2Rwcm9iZScgJy9zYmluL21vZHByb2JlIC1idiBwY2k6
djAwMDA4MDg2ZDAwMDAxMjM3c3YwMDAwMUFGNHNkMDAwMDExMDBiYzA2c2MwMGkwMCc6IE5v
IHN1Y2ggZmlsZSBvciBkaXJlY3RvcnkKdWRldmRbMjQ3XTogZmFpbGVkIHRvIGV4ZWN1dGUg
Jy9zYmluL21vZHByb2JlJyAnL3NiaW4vbW9kcHJvYmUgLWJ2IHBjaTp2MDAwMDgwODZkMDAw
MDcwMTBzdjAwMDAxQUY0c2QwMDAwMTEwMGJjMDFzYzAxaTgwJzogTm8gc3VjaCBmaWxlIG9y
IGRpcmVjdG9yeQp1ZGV2ZFsyNDldOiBmYWlsZWQgdG8gZXhlY3V0ZSAnL3NiaW4vbW9kcHJv
YmUnICcvc2Jpbi9tb2Rwcm9iZSAtYnYgYWNwaTpMTlhTWUJVUzonOiBObyBzdWNoIGZpbGUg
b3IgZGlyZWN0b3J5CnVkZXZkWzI1MF06IGZhaWxlZCB0byBleGVjdXRlICcvc2Jpbi9tb2Rw
cm9iZScgJy9zYmluL21vZHByb2JlIC1idiBhY3BpOkxOWFNZQlVTOic6IE5vIHN1Y2ggZmls
ZSBvciBkaXJlY3RvcnkKdWRldmRbMjUxXTogZmFpbGVkIHRvIGV4ZWN1dGUgJy9zYmluL21v
ZHByb2JlJyAnL3NiaW4vbW9kcHJvYmUgLWJ2IHBjaTp2MDAwMDgwODZkMDAwMDcwMDBzdjAw
MDAxQUY0c2QwMDAwMTEwMGJjMDZzYzAxaTAwJzogTm8gc3VjaCBmaWxlIG9yIGRpcmVjdG9y
eQp1ZGV2ZFsyNTJdOiBmYWlsZWQgdG8gZXhlY3V0ZSAnL3NiaW4vbW9kcHJvYmUnICcvc2Jp
bi9tb2Rwcm9iZSAtYnYgaW5wdXQ6YjAwMTl2MDAwMHAwMDAxZTAwMDAtZTAsMSxrNzQscmFt
bHNmdyc6IE5vIHN1Y2ggZmlsZSBvciBkaXJlY3RvcnkKdWRldmRbMjUzXTogZmFpbGVkIHRv
IGV4ZWN1dGUgJy9zYmluL21vZHByb2JlJyAnL3NiaW4vbW9kcHJvYmUgLWJ2IGFjcGk6UUVN
VTAwMDI6JzogTm8gc3VjaCBmaWxlIG9yIGRpcmVjdG9yeQp1ZGV2ZFsyNTRdOiBmYWlsZWQg
dG8gZXhlY3V0ZSAnL3NiaW4vbW9kcHJvYmUnICcvc2Jpbi9tb2Rwcm9iZSAtYnYgcGNpOnYw
MDAwMTIzNGQwMDAwMTExMXN2MDAwMDFBRjRzZDAwMDAxMTAwYmMwM3NjMDBpMDAnOiBObyBz
dWNoIGZpbGUgb3IgZGlyZWN0b3J5CnVkZXZkWzI1N106IGZhaWxlZCB0byBleGVjdXRlICcv
c2Jpbi9tb2Rwcm9iZScgJy9zYmluL21vZHByb2JlIC1idiBhY3BpOkFDUEkwMDEwOlBOUDBB
MDU6JzogTm8gc3VjaCBmaWxlIG9yIGRpcmVjdG9yeQp1ZGV2ZFsyNThdOiBmYWlsZWQgdG8g
ZXhlY3V0ZSAnL3NiaW4vbW9kcHJvYmUnICcvc2Jpbi9tb2Rwcm9iZSAtYnYgYWNwaTpQTlAw
MTAzOic6IE5vIHN1Y2ggZmlsZSBvciBkaXJlY3RvcnkKdWRldmRbMjU5XTogZmFpbGVkIHRv
IGV4ZWN1dGUgJy9zYmluL21vZHByb2JlJyAnL3NiaW4vbW9kcHJvYmUgLWJ2IGFjcGk6UE5Q
MEEwMzonOiBObyBzdWNoIGZpbGUgb3IgZGlyZWN0b3J5CnVkZXZkWzI2MF06IGZhaWxlZCB0
byBleGVjdXRlICcvc2Jpbi9tb2Rwcm9iZScgJy9zYmluL21vZHByb2JlIC1idiBwbGF0Zm9y
bTpGaXhlZCBNRElPIGJ1cyc6IE5vIHN1Y2ggZmlsZSBvciBkaXJlY3RvcnkKdWRldmRbMjY5
XTogZmFpbGVkIHRvIGV4ZWN1dGUgJy9zYmluL21vZHByb2JlJyAnL3NiaW4vbW9kcHJvYmUg
LWJ2IGFjcGk6UE5QMEEwNjonOiBObyBzdWNoIGZpbGUgb3IgZGlyZWN0b3J5CnVkZXZkWzI2
M106IGZhaWxlZCB0byBleGVjdXRlICcvc2Jpbi9tb2Rwcm9iZScgJy9zYmluL21vZHByb2Jl
IC1idiBhY3BpOlBOUDBDMEY6JzogTm8gc3VjaCBmaWxlIG9yIGRpcmVjdG9yeQp1ZGV2ZFsy
NjRdOiBmYWlsZWQgdG8gZXhlY3V0ZSAnL3NiaW4vbW9kcHJvYmUnICcvc2Jpbi9tb2Rwcm9i
ZSAtYnYgYWNwaTpQTlAwQzBGOic6IE5vIHN1Y2ggZmlsZSBvciBkaXJlY3RvcnkKdWRldmRb
MjY2XTogZmFpbGVkIHRvIGV4ZWN1dGUgJy9zYmluL21vZHByb2JlJyAnL3NiaW4vbW9kcHJv
YmUgLWJ2IGFjcGk6TE5YQ1BVOic6IE5vIHN1Y2ggZmlsZSBvciBkaXJlY3RvcnkKdWRldmRb
MjY3XTogZmFpbGVkIHRvIGV4ZWN1dGUgJy9zYmluL21vZHByb2JlJyAnL3NiaW4vbW9kcHJv
YmUgLWJ2IGFjcGk6TE5YQ1BVOic6IE5vIHN1Y2ggZmlsZSBvciBkaXJlY3RvcnkKdWRldmRb
MjY4XTogZmFpbGVkIHRvIGV4ZWN1dGUgJy9zYmluL21vZHByb2JlJyAnL3NiaW4vbW9kcHJv
YmUgLWJ2IGFjcGk6UE5QMEEwNjonOiBObyBzdWNoIGZpbGUgb3IgZGlyZWN0b3J5CnVkZXZk
WzI3MF06IGZhaWxlZCB0byBleGVjdXRlICcvc2Jpbi9tb2Rwcm9iZScgJy9zYmluL21vZHBy
b2JlIC1idiBhY3BpOlBOUDBBMDY6JzogTm8gc3VjaCBmaWxlIG9yIGRpcmVjdG9yeQp1ZGV2
ZFsyNzFdOiBmYWlsZWQgdG8gZXhlY3V0ZSAnL3NiaW4vbW9kcHJvYmUnICcvc2Jpbi9tb2Rw
cm9iZSAtYnYgYWNwaTpRRU1VMDAwMjonOiBObyBzdWNoIGZpbGUgb3IgZGlyZWN0b3J5CnVk
ZXZkWzI3NF06IGZhaWxlZCB0byBleGVjdXRlICcvc2Jpbi9tb2Rwcm9iZScgJy9zYmluL21v
ZHByb2JlIC1idiBhY3BpOlBOUDBDMEY6JzogTm8gc3VjaCBmaWxlIG9yIGRpcmVjdG9yeQp1
ZGV2ZFsyNzVdOiBmYWlsZWQgdG8gZXhlY3V0ZSAnL3NiaW4vbW9kcHJvYmUnICcvc2Jpbi9t
b2Rwcm9iZSAtYnYgYWNwaTpQTlAwQzBGOic6IE5vIHN1Y2ggZmlsZSBvciBkaXJlY3RvcnkK
CnVkZXZkWzI3Nl06IGZhaWxlZCB0byBleGVjdXRlICcvc2Jpbi9tb2Rwcm9iZScgJy9zYmlu
L21vZHByb2JlIC1idiBhY3BpOlBOUDAxMDM6JzogTm8gc3VjaCBmaWxlIG9yIGRpcmVjdG9y
eQp1ZGV2ZFsyNzddOiBmYWlsZWQgdG8gZXhlY3V0ZSAnL3NiaW4vbW9kcHJvYmUnICcvc2Jp
bi9tb2Rwcm9iZSAtYnYgYWNwaTpQTlAwQzBGOic6IE5vIHN1Y2ggZmlsZSBvciBkaXJlY3Rv
cnkKdWRldmRbMzE3XTogZmFpbGVkIHRvIGV4ZWN1dGUgJy9zYmluL21vZHByb2JlJyAnL3Ni
aW4vbW9kcHJvYmUgLWJ2IGFjcGk6UE5QMDUwMTonOiBObyBzdWNoIGZpbGUgb3IgZGlyZWN0
b3J5CnVkZXZkWzMxOF06IGZhaWxlZCB0byBleGVjdXRlICcvc2Jpbi9tb2Rwcm9iZScgJy9z
YmluL21vZHByb2JlIC1idiBhY3BpOlBOUDA3MDA6JzogTm8gc3VjaCBmaWxlIG9yIGRpcmVj
dG9yeQp1ZGV2ZFszMTZdOiBmYWlsZWQgdG8gZXhlY3V0ZSAnL3NiaW4vbW9kcHJvYmUnICcv
c2Jpbi9tb2Rwcm9iZSAtYnYgYWNwaTpQTlAwNTAxOic6IE5vIHN1Y2ggZmlsZSBvciBkaXJl
Y3RvcnkKdWRldmRbMzE5XTogZmFpbGVkIHRvIGV4ZWN1dGUgJy9zYmluL21vZHByb2JlJyAn
L3NiaW4vbW9kcHJvYmUgLWJ2IGFjcGk6UE5QMEIwMDonOiBObyBzdWNoIGZpbGUgb3IgZGly
ZWN0b3J5CnVkZXZkWzMxNV06IGZhaWxlZCB0byBleGVjdXRlICcvc2Jpbi9tb2Rwcm9iZScg
Jy9zYmluL21vZHByb2JlIC1idiBhY3BpOlBOUDA0MDA6JzogTm8gc3VjaCBmaWxlIG9yIGRp
cmVjdG9yeQp1ZGV2ZFszMjBdOiBmYWlsZWQgdG8gZXhlY3V0ZSAnL3NiaW4vbW9kcHJvYmUn
ICcvc2Jpbi9tb2Rwcm9iZSAtYnYgYWNwaTpQTlAwRjEzOic6IE5vIHN1Y2ggZmlsZSBvciBk
aXJlY3RvcnkKdWRldmRbMzE0XTogZmFpbGVkIHRvIGV4ZWN1dGUgJy9zYmluL21vZHByb2Jl
JyAnL3NiaW4vbW9kcHJvYmUgLWJ2IGFjcGk6UE5QMDMwMzonOiBObyBzdWNoIGZpbGUgb3Ig
ZGlyZWN0b3J5CnVkZXZkWzMyMV06IGZhaWxlZCB0byBleGVjdXRlICcvc2Jpbi9tb2Rwcm9i
ZScgJy9zYmluL21vZHByb2JlIC1idiBwbGF0Zm9ybTppNWtfYW1iJzogTm8gc3VjaCBmaWxl
IG9yIGRpcmVjdG9yeQp1ZGV2ZFszMjJdOiBmYWlsZWQgdG8gZXhlY3V0ZSAnL3NiaW4vbW9k
cHJvYmUnICcvc2Jpbi9tb2Rwcm9iZSAtYnYgcGxhdGZvcm06cGNzcGtyJzogTm8gc3VjaCBm
aWxlIG9yIGRpcmVjdG9yeQp1ZGV2ZFszMjRdOiBmYWlsZWQgdG8gZXhlY3V0ZSAnL3NiaW4v
bW9kcHJvYmUnICcvc2Jpbi9tb2Rwcm9iZSAtYnYgcGxhdGZvcm06cGxhdGZvcm0tZnJhbWVi
dWZmZXInOiBObyBzdWNoIGZpbGUgb3IgZGlyZWN0b3J5ClsgICAxMi4yMjg2MjJdIHJhdzog
ZmZmZmZmZmZmZmZmZmZmZiBmZmZmZmZmZmZmZmZmZmZmIGZmZmZmZmZmZmZmZmZmZmYKWyAg
IDEyLjIzMTQ3NF0gcGFnZSBkdW1wZWQgYmVjYXVzZTogVk1fQlVHX09OX1BBR0UoUGFnZVBv
aXNvbmVkKHApKQpbICAgMTIuMjMyMTM1XSAtLS0tLS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0t
LS0tLS0tLS0KWyAgIDEyLjIzMjY0OV0ga2VybmVsIEJVRyBhdCBpbmNsdWRlL2xpbnV4L21t
Lmg6MTAyMCEKWyAgIDEyLjI1ODExNV0gaW52YWxpZCBvcGNvZGU6IDAwMDAgWyMxXSBQUkVF
TVBUIFNNUCBQVEkKWyAgIDEyLjI1ODY2OF0gQ1BVOiAxIFBJRDogMjM2IENvbW06IHVkZXZk
IE5vdCB0YWludGVkIDUuMC4wLXJjNC0wMDE1MC1nYjUyM2FiMSAjMQpbICAgMTIuMjU5NDAz
XSBIYXJkd2FyZSBuYW1lOiBRRU1VIFN0YW5kYXJkIFBDIChpNDQwRlggKyBQSUlYLCAxOTk2
KSwgQklPUyAxLjEwLjItMSAwNC8wMS8yMDE0ClsgICAxMi4yNjAyNDFdIFJJUDogMDAxMDpp
c19tZW1fc2VjdGlvbl9yZW1vdmFibGUrMHgyNGMvMHgyYzAKWyAgIDEyLjI2MDgwMF0gQ29k
ZTogNzQgMzEgNDggODEgYzMgMDAgNzAgMDAgMDAgNDkgMzkgZGMgNzYgNGUgNDggOGIgMDMg
NDggODMgZjggZmYgMGYgODUgYjYgZmUgZmYgZmYgNDggYzcgYzYgYzAgOTkgMGIgODIgNDgg
ODkgZGYgZTggYTQgNTEgZmQgZmYgPDBmPiAwYiA1YiAzMSBjMCA1ZCA0MSA1YyBjMyA0OCA4
YiA0YiAyOCA4ZCA0MSBmNyA4MyBmOCAwMSA3NyBjMyBiOApbICAgMTIuMjYyNjQ4XSBSU1A6
IDAwMTg6ZmZmZjg4ODAxZmExZmQxMCBFRkxBR1M6IDAwMDEwMjg2ClsgICAxMi4yNjMxNjdd
IFJBWDogMDAwMDAwMDAwMDAwMDAzNCBSQlg6IGZmZmY4ODgwMWU1YzAwMDAgUkNYOiAwMDAw
MDAwMDAwMDAwMDAwClsgICAxMi4yNjM4OTldIFJEWDogMDAwMDAwMDAwMDAwMDAwMCBSU0k6
IGZmZmZmZmZmODIxNzBlNDYgUkRJOiAwMDAwMDAwMDAwMDAwMDAxClsgICAxMi4yNjQ2MjVd
IFJCUDogNmRiNmRiNmRiNmRiNmRiNyBSMDg6IGZmZmY4ODgwMWZhMTg4ZTggUjA5OiAwMDAw
MDAwMDkyZTZlYTUwClsgICAxMi4yNjUzNTZdIFIxMDogZmZmZjg4ODAxZmExZmNmOCBSMTE6
IDAwMDAwMDAwMDAwMDAwMDAgUjEyOiBmZmZmODg4MDFlNjQwMDAwClsgICAxMi4yNjYwNTFd
IFIxMzogMDAwMDAwMDAwMDAwMDAwMSBSMTQ6IGZmZmY4ODgwMWYxMjMxMDggUjE1OiAwMDAw
MDAwMDAwMDAwMDAxClsgICAxMi4yNjY3NTNdIEZTOiAgMDAwMDdmMWM4OTVmMTdjMCgwMDAw
KSBHUzpmZmZmODg4MDFkZDAwMDAwKDAwMDApIGtubEdTOjAwMDAwMDAwMDAwMDAwMDAKWyAg
IDEyLjI2NzU0N10gQ1M6ICAwMDEwIERTOiAwMDAwIEVTOiAwMDAwIENSMDogMDAwMDAwMDA4
MDA1MDAzMwpbICAgMTIuMjY4MTI3XSBDUjI6IDAwMDA3ZjFjODk1ZjYwMDAgQ1IzOiAwMDAw
MDAwMDFmYTNlMDAwIENSNDogMDAwMDAwMDAwMDAwMDZhMApbICAgMTIuMjY4ODUwXSBDYWxs
IFRyYWNlOgpbICAgMTIuMjY5MTU0XSAgcmVtb3ZhYmxlX3Nob3crMHg4Ny8weGEwClsgICAx
Mi4yNjk2MDVdICBkZXZfYXR0cl9zaG93KzB4MjUvMHg2MApbICAgMTIuMjY5OTY2XSAgc3lz
ZnNfa2Zfc2VxX3Nob3crMHhiYS8weDExMApbICAgMTIuMjcwNDEwXSAgc2VxX3JlYWQrMHgx
OTYvMHgzZjAKWyAgIDEyLjI3MDc0NV0gIF9fdmZzX3JlYWQrMHgzNC8weDE4MApbICAgMTIu
MjcxMDg4XSAgPyBsb2NrX2FjcXVpcmUrMHhiNi8weDFlMApbICAgMTIuMjcxNDkyXSAgdmZz
X3JlYWQrMHhhMC8weDE1MApbICAgMTIuMjcxODMwXSAga3N5c19yZWFkKzB4NDQvMHhiMApb
ICAgMTIuMjcyMjE5XSAgPyBkb19zeXNjYWxsXzY0KzB4MWYvMHg0YTAKWyAgIDEyLjI3MjYx
N10gIGRvX3N5c2NhbGxfNjQrMHg1ZS8weDRhMApbICAgMTIuMjcyOTk5XSAgPyB0cmFjZV9o
YXJkaXJxc19vZmZfdGh1bmsrMHgxYS8weDFjClsgICAxMi4yNzM1MjddICBlbnRyeV9TWVND
QUxMXzY0X2FmdGVyX2h3ZnJhbWUrMHg0OS8weGJlClsgICAxMi4yNzQwNDVdIFJJUDogMDAz
MzoweDdmMWM4OGNkODBhMApbICAgMTIuMjc5NDgwXSBDb2RlOiA3MyAwMSBjMyA0OCA4YiAw
ZCBhMCAwZCAyZCAwMCAzMSBkMiA0OCAyOSBjMiA2NCA4OSAxMSA0OCA4MyBjOCBmZiBlYiBl
YSA5MCA5MCA4MyAzZCAzZCA3MSAyZCAwMCAwMCA3NSAxMCBiOCAwMCAwMCAwMCAwMCAwZiAw
NSA8NDg+IDNkIDAxIGYwIGZmIGZmIDczIDMxIGMzIDQ4IDgzIGVjIDA4IGU4IDNlIGIxIDAx
IDAwIDQ4IDg5IDA0IDI0ClsgICAxMi4yODEzNThdIFJTUDogMDAyYjowMDAwN2ZmZGExMTk1
YWI4IEVGTEFHUzogMDAwMDAyNDYgT1JJR19SQVg6IDAwMDAwMDAwMDAwMDAwMDAKWyAgIDEy
LjI4MjEyN10gUkFYOiBmZmZmZmZmZmZmZmZmZmRhIFJCWDogMDAwMDAwMDAwMDAwMDAwNSBS
Q1g6IDAwMDA3ZjFjODhjZDgwYTAKWyAgIDEyLjI4Mjg3M10gUkRYOiAwMDAwMDAwMDAwMDAx
MDAwIFJTSTogMDAwMDdmZmRhMTE5NWI1OCBSREk6IDAwMDAwMDAwMDAwMDAwMDUKWyAgIDEy
LjI4MzYxOF0gUkJQOiAwMDAwNTU3ODI4Yjg5YWMzIFIwODogNzM3OTczMmY3MzY1NjM2OSBS
MDk6IDZmNmQ2NTZkMmY2ZDY1NzQKWyAgIDEyLjI4NDM5M10gUjEwOiA3MjZmNmQ2NTZkMmY3
OTcyIFIxMTogMDAwMDAwMDAwMDAwMDI0NiBSMTI6IDAwMDAwMDAwMDAwMDAwMDAKWyAgIDEy
LjI4NTA5OV0gUjEzOiAwMDAwNTU3ODI4Yjg4MGYwIFIxNDogMDAwMDAwMDAwMDAwMDAwMCBS
MTU6IDAwMDA3ZmZkYTExOWI5MDgKWyAgIDEyLjI4NTgyMl0gTW9kdWxlcyBsaW5rZWQgaW46
Cgp1ZGV2ZFszMjNdOiBmYWlsZWQgdG8gZXhlY3V0ZSAnL3NiaW4vbW9kcHJvYmUnICcvc2Jp
bi9tb2Rwcm9iZSAtYnYgaW5wdXQ6YjAwMTF2MDAwMXAwMDAxZUFCNDEtZTAsMSw0LDExLDE0
LGs3MSw3Miw3Myw3NCw3NSw3Niw3Nyw3OSw3QSw3Qiw3Qyw3RCw3RSw3Riw4MCw4Qyw4RSw4
Riw5Qiw5Qyw5RCw5RSw5RixBMyxBNCxBNSxBNixBQyxBRCxCNyxCOCxCOSxEOSxFMixyYW00
LGwwLDEsMixzZncnOiBObyBzdWNoIGZpbGUgb3IgZGlyZWN0b3J5CnVkZXZkWzMyNV06IGZh
aWxlZCB0byBleGVjdXRlICcvc2Jpbi9tb2Rwcm9iZScgJy9zYmluL21vZHByb2JlIC1idiBz
ZXJpbzp0eTAxcHIwMGlkMDBleDAwJzogTm8gc3VjaCBmaWxlIG9yIGRpcmVjdG9yeQp1ZGV2
ZFszMjZdOiBmYWlsZWQgdG8gZXhlY3V0ZSAnL3NiaW4vbW9kcHJvYmUnICcvc2Jpbi9tb2Rw
cm9iZSAtYnYgZG1pOmJ2blNlYUJJT1M6YnZyMS4xMC4yLTE6YmQwNC8wMS8yMDE0OnN2blFF
TVU6cG5TdGFuZGFyZFBDKGk0NDBGWCtQSUlYLDE5OTYpOnB2cnBjLWk0NDBmeC0yLjg6Y3Zu
UUVNVTpjdDE6Y3ZycGMtaTQ0MGZ4LTIuODonOiBObyBzdWNoIGZpbGUgb3IgZGlyZWN0b3J5
ClsgICAxMi4zNTk4NDldIC0tLVsgZW5kIHRyYWNlIDI3NDY5NzUxNjdmYzM1OWEgXS0tLQpb
ICAgMTIuMzYyNzc1XSBSSVA6IDAwMTA6aXNfbWVtX3NlY3Rpb25fcmVtb3ZhYmxlKzB4MjRj
LzB4MmMwClsgICAxMi4zNjUxODJdIENvZGU6IDc0IDMxIDQ4IDgxIGMzIDAwIDcwIDAwIDAw
IDQ5IDM5IGRjIDc2IDRlIDQ4IDhiIDAzIDQ4IDgzIGY4IGZmIDBmIDg1IGI2IGZlIGZmIGZm
IDQ4IGM3IGM2IGMwIDk5IDBiIDgyIDQ4IDg5IGRmIGU4IGE0IDUxIGZkIGZmIDwwZj4gMGIg
NWIgMzEgYzAgNWQgNDEgNWMgYzMgNDggOGIgNGIgMjggOGQgNDEgZjcgODMgZjggMDEgNzcg
YzMgYjgKWyAgIDEyLjQyNjYzMl0gUlNQOiAwMDE4OmZmZmY4ODgwMWZhMWZkMTAgRUZMQUdT
OiAwMDAxMDI4NgpbICAgMTIuNDI3MjQ0XSBSQVg6IDAwMDAwMDAwMDAwMDAwMzQgUkJYOiBm
ZmZmODg4MDFlNWMwMDAwIFJDWDogMDAwMDAwMDAwMDAwMDAwMApbICAgMTIuNDI3OTQ2XSBS
RFg6IDAwMDAwMDAwMDAwMDAwMDAgUlNJOiBmZmZmZmZmZjgyMTcwZTQ2IFJESTogMDAwMDAw
MDAwMDAwMDAwMQpbICAgMTIuNDI4OTI2XSBSQlA6IDZkYjZkYjZkYjZkYjZkYjcgUjA4OiBm
ZmZmODg4MDFmYTE4OGU4IFIwOTogMDAwMDAwMDA5MmU2ZWE1MApbICAgMTIuNDM4MjcyXSBS
MTA6IGZmZmY4ODgwMWZhMWZjZjggUjExOiAwMDAwMDAwMDAwMDAwMDAwIFIxMjogZmZmZjg4
ODAxZTY0MDAwMApbICAgMTIuNDM5MDEzXSBSMTM6IDAwMDAwMDAwMDAwMDAwMDEgUjE0OiBm
ZmZmODg4MDFmMTIzMTA4IFIxNTogMDAwMDAwMDAwMDAwMDAwMQpbICAgMTIuNDM5Nzk4XSBG
UzogIDAwMDA3ZjFjODk1ZjE3YzAoMDAwMCkgR1M6ZmZmZjg4ODAxZGQwMDAwMCgwMDAwKSBr
bmxHUzowMDAwMDAwMDAwMDAwMDAwClsgICAxMi40NDA2NDBdIENTOiAgMDAxMCBEUzogMDAw
MCBFUzogMDAwMCBDUjA6IDAwMDAwMDAwODAwNTAwMzMKWyAgIDEyLjQ0MTI0OF0gQ1IyOiAw
MDAwN2ZjMWEzYmUzMjgwIENSMzogMDAwMDAwMDAxZmEzZTAwMCBDUjQ6IDAwMDAwMDAwMDAw
MDA2YTAKWyAgIDEyLjQ0MTk0N10gS2VybmVsIHBhbmljIC0gbm90IHN5bmNpbmc6IEZhdGFs
IGV4Y2VwdGlvbgpbICAgMTIuNDQyNTE4XSBLZXJuZWwgT2Zmc2V0OiBkaXNhYmxlZAoKRWxh
cHNlZCB0aW1lOiAyMAoKa3ZtPSgKCXFlbXUtc3lzdGVtLXg4Nl82NAoJLWVuYWJsZS1rdm0K
CS1jcHUga3ZtNjQKCS1rZXJuZWwgJGtlcm5lbAoJLWluaXRyZCAvb3NpbWFnZS9xdWFudGFs
L3F1YW50YWwtdHJpbml0eS14ODZfNjQuY2d6CgktbSA1MTIKCS1zbXAgMgoJLWRldmljZSBl
MTAwMCxuZXRkZXY9bmV0MAoJLW5ldGRldiB1c2VyLGlkPW5ldDAKCS1ib290IG9yZGVyPW5j
Cgktbm8tcmVib290Cgktd2F0Y2hkb2cgaTYzMDBlc2IKCS13YXRjaGRvZy1hY3Rpb24gZGVi
dWcKCS1ydGMgYmFzZT1sb2NhbHRpbWUKCS1zZXJpYWwgc3RkaW8KCS1kaXNwbGF5IG5vbmUK
CS1tb25pdG9yIG51bGwKKQoKYXBwZW5kPSgKCXJvb3Q9L2Rldi9yYW0wCglodW5nX3Rhc2tf
cGFuaWM9MQoJZGVidWcKCWFwaWM9ZGVidWcKCXN5c3JxX2Fsd2F5c19lbmFibGVkCglyY3Vw
ZGF0ZS5yY3VfY3B1X3N0YWxsX3RpbWVvdXQ9MTAwCgluZXQuaWZuYW1lcz0wCglwcmludGsu
ZGV2a21zZz1vbgoJcGFuaWM9LTEKCXNvZnRsb2NrdXBfcGFuaWM9MQoJbm1pX3dhdGNoZG9n
PXBhbmljCglvb3BzPXBhbmljCglsb2FkX3JhbWRpc2s9MgoJcHJvbXB0X3JhbWRpc2s9MAoJ
ZHJiZC5taW5vcl9jb3VudD04CglzeXN0ZW1kLmxvZ19sZXZlbD1lcnIKCWlnbm9yZV9sb2ds
ZXZlbAoJY29uc29sZT10dHkwCgllYXJseXByaW50az10dHlTMCwxMTUyMDAKCWNvbnNvbGU9
dHR5UzAsMTE1MjAwCgl2Z2E9bm9ybWFsCglydwoJYnJhbmNoPWxpbnV4LWRldmVsL2ZpeHVw
LWVmYWQ0ZTQ3NWMzMTI0NTZlZGIzYzc4OWQwOTk2ZDEyZWQ3NDRjMTMKCUJPT1RfSU1BR0U9
L3BrZy9saW51eC94ODZfNjQtcmFuZGNvbmZpZy1zMi0wMjE3MjMxOC9nY2MtNi9iNTIzYWIx
YjhjZTU5NTkyY2IzMmQ2MjI1MDMyMTcwNzdjZjA3ZTRkL3ZtbGludXotNS4wLjAtcmM0LTAw
MTUwLWdiNTIzYWIxCglkcmJkLm1pbm9yX2NvdW50PTgKCXJjdXBlcmYuc2h1dGRvd249MAop
CgoiJHtrdm1bQF19IiAtYXBwZW5kICIke2FwcGVuZFsqXX0iCg==
--------------8AA4B2326A15E0CDFA751ECC--

