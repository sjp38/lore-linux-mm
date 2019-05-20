Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4360C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 21:36:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40A3E21479
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 21:36:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40A3E21479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.ee
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA54E6B000A; Mon, 20 May 2019 17:36:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2F386B000C; Mon, 20 May 2019 17:36:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F67B6B000D; Mon, 20 May 2019 17:36:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 27ED06B000A
	for <linux-mm@kvack.org>; Mon, 20 May 2019 17:36:55 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id l10so2707013ljj.18
        for <linux-mm@kvack.org>; Mon, 20 May 2019 14:36:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=AtXPUGcu1n6mp0mjfjwW8K0Kq+x/jYMgKBeLWoG8OFU=;
        b=rFJNZYa/aLwDA4XlJQsnnPREbhwf5qrXbT7pAt3iknezmVOOi+8eMiewueJJS8vvf0
         1XwAWCaZbxeScrkFOKJKbV23XLKM5mQX0V7uQIuDCStmvKKDv2jdaoldik5vGpXuVBR5
         Xglf9us/Zz1WEpPN8WBmwa9RPA/O9YQciZfPcDuoG54/OMY+es02mhJk4vqWBbj3+W7A
         uH52k7k/ZhF0pkbx+rJnfojr4vSN86cZRDkj4NoAyfoissXU75KXMpodgQR3Qdf67B0n
         2DHrCphTwA5jpRreggWKQhnqM4BP/WUtsETfxrM9o57VmqcD7trsyT5vWzFRYJQX5cNw
         W7HQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
X-Gm-Message-State: APjAAAU7F9r4y0LSrr/giQoUEKposhEaapu2TIbh+og2gixjcGUvnPW9
	WlKW0WbDjwKTdTOpNoe5gBfEDxo3La+vW7wtdJn9VudABb4Ps2TVPFp8yt8l7GsVp2XRGvjoDu4
	I9O2Hv5SBFnYYlnXaI6EUwmM0xn6oGgUHbrNY119c2SoJ2Ez63LnlwLKtQSDg0rE=
X-Received: by 2002:ac2:482a:: with SMTP id 10mr23892191lft.51.1558388214566;
        Mon, 20 May 2019 14:36:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztNi+MgltGHJIByYCqYEWeLDH1is+DqbVd1p0bN/QKJ0GZDeY+i9e1Re1Tce3JNgXlrnh5
X-Received: by 2002:ac2:482a:: with SMTP id 10mr23892148lft.51.1558388213507;
        Mon, 20 May 2019 14:36:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558388213; cv=none;
        d=google.com; s=arc-20160816;
        b=Jkh9gLA7oMsb00aFpNfrqTku7SPAx+Dxf+d0X7O4xQtn7IqRutO/IMqX+0V+GIOEPK
         QBxJfiLZTYjw0VSwMsRf4GhltqfEBZvvhX8GSWo2EEvFQBsFnw+ANZlEake434MT9cva
         3g3A4Psqiy26adN4TSN/qaPr58rvG0o9vNZP3SnyCMMoGiqKBHjgvhm2rmM6VmzSoW8p
         59AhJ/qaZWkwCZB8icNBUURdfVTCgzEKi35nhV2F9ZFR31DqEhfoaItLemLUwjmoF4tk
         /R54Vs4JTBypla0/GiUmTtjKIcBpm8CLSQjB8hxvqfOU+KQQmZMH92zObkzYSFoddKs8
         WERg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=AtXPUGcu1n6mp0mjfjwW8K0Kq+x/jYMgKBeLWoG8OFU=;
        b=fTQskIQks2zZMhv+dLFPYMSV3TIOmWpnF7DQ6jj7OlJ3n++uehTvLugBzfT5Xn2W7/
         /s34NsViwKNl6iq9LKfr+h+DgKyKLOmM8cCLq3rbgh6qvz29GmSQX7pBLqPyD20hm+qm
         P2YuvE5UKbSOF1BWFunKvYcEEi43QOh4KT6DDWI/KOzId4NFmo4UaJOJqPBqF+rqTGcD
         XrAZEVJNhEDhmOFmVU+nfhvNp6U6Qe+GIXkT2n3NgvmiDk1rCygw7UPs4JHzGONjP7Nk
         xHWb6pBO8tlV7nDbXHRS0tWklUIUQe1IwOvbAYSKyOZghIS/KvLpN3yTdGW4c2XJo3hz
         l6iQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
Received: from mx2.cyber.ee (mx2.cyber.ee. [193.40.6.72])
        by mx.google.com with ESMTPS id x18si14574334lfc.83.2019.05.20.14.36.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 14:36:53 -0700 (PDT)
Received-SPF: neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) client-ip=193.40.6.72;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
Subject: Re: [PATCH v2] vmalloc: Fix issues with flush flag
To: Rick Edgecombe <rick.p.edgecombe@intel.com>,
 linux-kernel@vger.kernel.org, peterz@infradead.org,
 sparclinux@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: dave.hansen@intel.com, namit@vmware.com, Meelis Roos <mroos@linux.ee>,
 "David S. Miller" <davem@davemloft.net>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>
References: <20190520200703.15997-1-rick.p.edgecombe@intel.com>
From: Meelis Roos <mroos@linux.ee>
Message-ID: <90f8a4e1-aa71-0c10-1a91-495ba0cb329b@linux.ee>
Date: Tue, 21 May 2019 00:36:22 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190520200703.15997-1-rick.p.edgecombe@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: et-EE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Switch VM_FLUSH_RESET_PERMS to use a regular TLB flush intead of
> vm_unmap_aliases() and fix calculation of the direct map for the
> CONFIG_ARCH_HAS_SET_DIRECT_MAP case.
> 
> Meelis Roos reported issues with the new VM_FLUSH_RESET_PERMS flag on a
> sparc machine. On investigation some issues were noticed:
> 
> 1. The calculation of the direct map address range to flush was wrong.
> This could cause problems on x86 if a RO direct map alias ever got loaded
> into the TLB. This shouldn't normally happen, but it could cause the
> permissions to remain RO on the direct map alias, and then the page
> would return from the page allocator to some other component as RO and
> cause a crash.
> 
> 2. Calling vm_unmap_alias() on vfree could potentially be a lot of work to
> do on a free operation. Simply flushing the TLB instead of the whole
> vm_unmap_alias() operation makes the frees faster and pushes the heavy
> work to happen on allocation where it would be more expected.
> In addition to the extra work, vm_unmap_alias() takes some locks including
> a long hold of vmap_purge_lock, which will make all other
> VM_FLUSH_RESET_PERMS vfrees wait while the purge operation happens.
> 
> 3. page_address() can have locking on some configurations, so skip calling
> this when possible to further speed this up.
> 
> Fixes: 868b104d7379 ("mm/vmalloc: Add flag for freeing of special permsissions")
> Reported-by: Meelis Roos<mroos@linux.ee>
> Cc: Meelis Roos<mroos@linux.ee>
> Cc: Peter Zijlstra<peterz@infradead.org>
> Cc: "David S. Miller"<davem@davemloft.net>
> Cc: Dave Hansen<dave.hansen@intel.com>
> Cc: Borislav Petkov<bp@alien8.de>
> Cc: Andy Lutomirski<luto@kernel.org>
> Cc: Ingo Molnar<mingo@redhat.com>
> Cc: Nadav Amit<namit@vmware.com>
> Signed-off-by: Rick Edgecombe<rick.p.edgecombe@intel.com>
> ---
> 
> Changes since v1:
>   - Update commit message with more detail
>   - Fix flush end range on !CONFIG_ARCH_HAS_SET_DIRECT_MAP case

It does not work on my V445 where the initial problem happened.

[   46.582633] systemd[1]: Detected architecture sparc64.

Welcome to Debian GNU/Linux 10 (buster)!

[   46.759048] systemd[1]: Set hostname to <v445>.
[   46.831383] systemd[1]: Failed to bump fs.file-max, ignoring: Invalid argument
[   67.989695] rcu: INFO: rcu_sched detected stalls on CPUs/tasks:
[   68.074706] rcu:     0-...!: (0 ticks this GP) idle=5c6/1/0x4000000000000000 softirq=33/33 fqs=0
[   68.198443] rcu:     2-...!: (0 ticks this GP) idle=e7e/1/0x4000000000000000 softirq=67/67 fqs=0
[   68.322198]  (detected by 1, t=5252 jiffies, g=-939, q=108)
[   68.402204]   CPU[  0]: TSTATE[0000000080001603] TPC[000000000043f298] TNPC[000000000043f29c] TASK[systemd-debug-g:89]
[   68.556001]              TPC[smp_synchronize_tick_client+0x18/0x1a0] O7[0xfff000010000691c] I7[xcall_sync_tick+0x1c/0x2c] RPC[alloc_set_pte+0xf4/0x300]
[   68.750973]   CPU[  2]: TSTATE[0000000080001600] TPC[000000000043f298] TNPC[000000000043f29c] TASK[systemd-cryptse:88]
[   68.904741]              TPC[smp_synchronize_tick_client+0x18/0x1a0] O7[filemap_map_pages+0x3cc/0x3e0] I7[xcall_sync_tick+0x1c/0x2c] RPC[handle_mm_fault+0xa0/0x180]
[   69.115991] rcu: rcu_sched kthread starved for 5252 jiffies! g-939 f0x0 RCU_GP_WAIT_FQS(5) ->state=0x402 ->cpu=3
[   69.262239] rcu: RCU grace-period kthread stack dump:
[   69.334741] rcu_sched       I    0    10      2 0x06000000
[   69.413495] Call Trace:
[   69.448501]  [000000000093325c] schedule+0x1c/0xc0
[   69.517253]  [0000000000936c74] schedule_timeout+0x154/0x260
[   69.598514]  [00000000004b65a4] rcu_gp_kthread+0x4e4/0xac0
[   69.677261]  [000000000047ecfc] kthread+0xfc/0x120
[   69.746018]  [00000000004060a4] ret_from_fork+0x1c/0x2c
[   69.821014]  [0000000000000000] 0x0

and hangs here, software watchdog kicks in soon.

-- 
Meelis Roos

