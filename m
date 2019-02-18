Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDCADC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 09:11:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5A0E2177E
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 09:11:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5A0E2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 563098E0005; Mon, 18 Feb 2019 04:11:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 513008E0002; Mon, 18 Feb 2019 04:11:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 429CA8E0005; Mon, 18 Feb 2019 04:11:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 020B38E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 04:11:33 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id f125so11575123pgc.20
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 01:11:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=EZZ/8dfgVaiF2eo4dRJG/EaPSnkFxmK8ZYA4vLec4sI=;
        b=qBe1y22VJoQmh/ex2m6/mVkS8aduVAydr8+LorJidgwQpOFCnc1rUdckciOLOa877m
         hFX68k59X4SBSx3LiB8+TNgIla8ZQF3dgqJsyA0LoK4o40mxdYbjyLbYKCh8hxll8q6d
         PZFWy3AOuGUlXDDYgcqK0JZJq0WsBF5vZYPWXM9+wXkDVgFtsniVumZHUu4iKrQzL/3J
         bBpkslCq7MBhsex2K/wF/0r5JlXh5i5wGu157I4fqBfryVreXh2dmKHtubYWtuzDKxXr
         DKBWX64mIBzcf1KSqZ3mt8u552thVui7FczqSKTqx9DfJXA8CAUNYq2LbsV69V5D1kOX
         LMFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rong.a.chen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAua1AT6KNiEMVdlbM+J6a6nMgF/ebMq1Ici+q3SqF+siQHWwWSxg
	eqeyRCEXRjbsetkI4NCnIfpMbwmMi43i9tSfB66N6TCIKZLHXwDPz98/oyW+wmuql3sAiRZfcGA
	yB+TPE1GgpJSCNq32dC94s3crLbsMqeSwHE4rBEszKTVT0XK3ki61XgWIXQIVJwjxJw==
X-Received: by 2002:aa7:8186:: with SMTP id g6mr4253115pfi.138.1550481093647;
        Mon, 18 Feb 2019 01:11:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbM7iM+uTaoiOxHK6jbTC6Ne07W0ufSK2O/IDaHFesr0KwrbGkOV153pcVbgnKhyjqRNktY
X-Received: by 2002:aa7:8186:: with SMTP id g6mr4253060pfi.138.1550481092800;
        Mon, 18 Feb 2019 01:11:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550481092; cv=none;
        d=google.com; s=arc-20160816;
        b=bXVdzkgAGPU9wpxqfQCJ49/BO6Znz+jZZDOdxAIgXtDeSzbntwaK68QHONruwPqLXV
         Qi/fJXDj6UHhNvp+hXX6WmFq+IbgaAB9kDjWzOC6xsHtI+1Uua99G+XegHG1pxlMp/g6
         Dktk36E3+IY+oXs2/nHzsbafbkwsrmYFl9er0D0PRjwrATeQ+2EIHFIsm+KwdJqdqGDb
         WhpZ5iLJGdcKV2GDO5AnEmj3FwRdgoxzR2T0UThg1MTBIlxwHS2YF8YQV2/DESmw9Zg9
         ayOkdnsqyOJYmKnv5WqcSIn+7uYfHrTSru0d7NU8pDa57RFF99Q7sp5TT14BGGInKr15
         CNbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=EZZ/8dfgVaiF2eo4dRJG/EaPSnkFxmK8ZYA4vLec4sI=;
        b=CrYF6YLzG/lt3ldLfOEJ33GHM96DXAl5A8prhnkH2ojYwmacec0V5zdaIAoR7VG/Tn
         XmfvfOvXQ8VkdS/cEmJStnYIOCZgJHabyzjgGaO5TJtpMjExe9Md3g7/VPJNV2pTFj/x
         SL4v4XA8+JB4+suKb5uKxRh4q4i0XVwz7aoqPjWGT3KUuw0Hs57zbE/PtLOTNknCeemT
         gC2qGgkHE01y5erZxeuwLa6P6svMnhVq1Pgpm3fS2+3niBMPSCaG5DLLa4NXiBsw2CwK
         WR5tDhstAiTaq/8CgHLpL/Hf5WUxQoOlKErX2MOuVI7/1nmqwpjIuWVE7Juj50ik/6NC
         0cVA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rong.a.chen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id d16si6634237pll.236.2019.02.18.01.11.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 01:11:32 -0800 (PST)
Received-SPF: pass (google.com: domain of rong.a.chen@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rong.a.chen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rong.a.chen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Feb 2019 01:11:32 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,384,1544515200"; 
   d="scan'208";a="321251592"
Received: from shao2-debian.sh.intel.com (HELO [10.239.13.107]) ([10.239.13.107])
  by fmsmga005.fm.intel.com with ESMTP; 18 Feb 2019 01:11:31 -0800
Subject: Re: [LKP] efad4e475c [ 40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
To: Michal Hocko <mhocko@kernel.org>
Cc: Oscar Salvador <osalvador@suse.de>,
 Andrew Morton <akpm@linux-foundation.org>,
 Linux Memory Management List <linux-mm@kvack.org>,
 linux-kernel@vger.kernel.org, LKP <lkp@01.org>
References: <20190218052823.GH29177@shao2-debian>
 <20190218070844.GC4525@dhcp22.suse.cz>
 <79a3d305-1d96-3938-dc14-617a9e475648@intel.com>
 <20190218090310.GE4525@dhcp22.suse.cz>
From: Rong Chen <rong.a.chen@intel.com>
Message-ID: <f688387a-6052-6481-57f4-d3b20b2ea3bb@intel.com>
Date: Mon, 18 Feb 2019 17:11:49 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190218090310.GE4525@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2/18/19 5:03 PM, Michal Hocko wrote:
> On Mon 18-02-19 16:47:26, Rong Chen wrote:
>> On 2/18/19 3:08 PM, Michal Hocko wrote:
>>> On Mon 18-02-19 13:28:23, kernel test robot wrote:
> [...]
>>>> [   40.305212] PGD 0 P4D 0
>>>> [   40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
>>>> [   40.313055] CPU: 1 PID: 239 Comm: udevd Not tainted 5.0.0-rc4-00149-gefad4e4 #1
>>>> [   40.321348] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
>>>> [   40.330813] RIP: 0010:page_mapping+0x12/0x80
>>>> [   40.335709] Code: 5d c3 48 89 df e8 0e ad 02 00 85 c0 75 da 89 e8 5b 5d c3 0f 1f 44 00 00 53 48 89 fb 48 8b 43 08 48 8d 50 ff a8 01 48 0f 45 da <48> 8b 53 08 48 8d 42 ff 83 e2 01 48 0f 44 c3 48 83 38 ff 74 2f 48
>>>> [   40.356704] RSP: 0018:ffff88801fa87cd8 EFLAGS: 00010202
>>>> [   40.362714] RAX: ffffffffffffffff RBX: fffffffffffffffe RCX: 000000000000000a
>>>> [   40.370798] RDX: fffffffffffffffe RSI: ffffffff820b9a20 RDI: ffff88801e5c0000
>>>> [   40.378830] RBP: 6db6db6db6db6db7 R08: ffff88801e8bb000 R09: 0000000001b64d13
>>>> [   40.386902] R10: ffff88801fa87cf8 R11: 0000000000000001 R12: ffff88801e640000
>>>> [   40.395033] R13: ffffffff820b9a20 R14: ffff88801f145258 R15: 0000000000000001
>>>> [   40.403138] FS:  00007fb2079817c0(0000) GS:ffff88801dd00000(0000) knlGS:0000000000000000
>>>> [   40.412243] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>>> [   40.418846] CR2: 0000000000000006 CR3: 000000001fa82000 CR4: 00000000000006a0
>>>> [   40.426951] Call Trace:
>>>> [   40.429843]  __dump_page+0x14/0x2c0
>>>> [   40.433947]  is_mem_section_removable+0x24c/0x2c0
>>> This looks like we are stumbling over an unitialized struct page again.
>>> Something this patch should prevent from. Could you try to apply [1]
>>> which will make __dump_page more robust so that we do not blow up there
>>> and give some more details in return.
>>
>> Hi Hocko,
>>
>> I have applied [1] and attached the dmesg file.
> Thanks so the log confirms that this is really an unitialized struct
> page
> [   12.228622] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff
> [   12.231474] page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> [   12.232135] ------------[ cut here ]------------
> [   12.232649] kernel BUG at include/linux/mm.h:1020!
>
> So now, we have to find out what has been left behind. Please see my
> other email. Also could you give me faddr2line of the
> is_mem_section_removable offset please? I assume it is
> is_pageblock_removable_nolock:
> 	if (!node_online(page_to_nid(page)))
> 		return false;


faddr2line result:

is_mem_section_removable+0x24c/0x2c0:
page_to_nid at include/linux/mm.h:1020
(inlined by) is_pageblock_removable_nolock at mm/memory_hotplug.c:1221
(inlined by) is_mem_section_removable at mm/memory_hotplug.c:1241

Best Regards,
Rong Chen


