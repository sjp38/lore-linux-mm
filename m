Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 838A6C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:34:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3392320872
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:34:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="l99SQJzt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3392320872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B19F76B02BE; Tue, 16 Apr 2019 11:34:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEF636B02BF; Tue, 16 Apr 2019 11:34:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E1606B02C0; Tue, 16 Apr 2019 11:34:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC036B02BE
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 11:34:52 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 77so18185560qkd.9
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 08:34:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=t/nJ62zGfBhASAqt8Wb9pZGiyJgukG4A6dg+njiVp48=;
        b=gcOn3hiuK6dpsSJG165ylG/lCUNTJyNMNa/U7E7vb3cmCVxzPiGcsU6sgY8gtaInrt
         W1vkCtMvBgQzHu7MAqtAY6ue3rvI9/TcJTroabiiJUPoO79zTl+WHv+gl1+Q2heUmtHx
         dqMWsF9lbqA1KIGEg+Ptqdthk+TPd472GDk5wEwGePiOimxQUJPz/WLHS73wysRo+gq0
         L4NJLdPFOdPDv9FerNXWqJGA6btxyHYEe3LL3l3shbhsDW8jAcgULCGHal0U68xfyY9+
         AZavD4pCA6nmPnhjG85VMFMdaK3hxAjORGjQ+y6ZU67z44+9qaEuDyRoWyUSv8a2/+tC
         nXJQ==
X-Gm-Message-State: APjAAAV0EwkufLq/xRSaUP2OHn4NyURawTP7k9Rdr2DXpF57Y8WdgdAT
	jrTaq0CN6cyQrs1yvgxqoTUR5X39FLKOVPxC5GCEkwsAuzkLzNttXG45h+KWVcArNG8pquKi1xY
	S3q1FzgJpNGN5xmh4srZGCHY94E4Husi0ddktzZ07XER7e8v4UgOmaYvb8om1yHzamQ==
X-Received: by 2002:ac8:f5c:: with SMTP id l28mr65654988qtk.249.1555428892256;
        Tue, 16 Apr 2019 08:34:52 -0700 (PDT)
X-Received: by 2002:ac8:f5c:: with SMTP id l28mr65654931qtk.249.1555428891589;
        Tue, 16 Apr 2019 08:34:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555428891; cv=none;
        d=google.com; s=arc-20160816;
        b=CFEuJP9dzfsVRpH2H2NB5C0V7nh4mBQ0GUGoKad6IdihbU1gm+yO1dGAytFx9DtpMc
         mShyPZN3lDR0Bcw4QkjDkZ6XuzWsVuVwvhKBjNsvRgXFJoGBHy9l0BLNf8P78Q/HK5Wz
         mcClzSOmruEJ/xVLAUCCF9TYWJaeOBIpe/gTlrLUg/EmmhY7Vu+bMh5Nhc/NjJTZS4b1
         XpBoYba6FcyrNZjew/bYIpxhP99xTwYPEUc6ZnSs4LxvJbn7zCuzZy71I1mb4THlrCeO
         Ov3xv7N25IATVCVbWsdi+9e5RdTkU9R5JDt3N2iu89Elr2bnurXlM5a+N9JrowrKbjLR
         EZFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=t/nJ62zGfBhASAqt8Wb9pZGiyJgukG4A6dg+njiVp48=;
        b=0PMB5kcM2WQei94Hsw9tm8wGAnjN1LC9MPUSJpczYhWK1QZ9bcsfd4iyMZ9rQrEUox
         50STbTJRUfs+ssQ2AFePO9St3/W1Hln1xQlhZD1G0DKiwUfu12gTzx69ezTi5mlBYuNC
         LU+FRxxg+D+ydgsXffKLW3EwCnPFUTn9QipoHKm05yYT9nxXL+zL0g84+Al5Wf1B/4US
         QyoKQa6Aj0KZzt08cIH6lmkx6uXehGSZAZdlQ++0yRh22kh1WZYhxi8JfVOdtKYOMvGK
         DhD1dzDJHd0azcv21Zr7GOgI6FQxL2XldvS67fNS5HQFeN3Af9jQ2Lnb08rX58sPbr2L
         gCKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=l99SQJzt;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y7sor30680482qke.2.2019.04.16.08.34.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 08:34:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=l99SQJzt;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=t/nJ62zGfBhASAqt8Wb9pZGiyJgukG4A6dg+njiVp48=;
        b=l99SQJztWsx18t5a8lNhbvbfGFaHPwjTF8bM8BlWOTlgVZmSy5bw+SPoOtaYnLjO8+
         9t5NTTE/Cr5+wtrCrxpLjNVIg9YEwxQVuQ5WceIdc5Q1w7Dbaiv/sOgUsr7UX/SgktcI
         UNqa1BA0Uw2IcZzp+aKmvW2YEfU0GrakEnIybE9hqRd4Psid6RAqHgBv6hsJYwPwVY0h
         mBF3VNpZbh+emJbhjkTZsu+jy06tvDgV22vmBYXhCpkqRtGknRq2GjLqOmdLIDWAb0z5
         w1uaL1wSUEEx1jhBVS05NgRofOGZ7KRlsJfgkvRVJtn4UIo2pxwEys6pXVmCUS42X0jU
         Ifkw==
X-Google-Smtp-Source: APXvYqx7/swZjLqc3SlEHh9S5oV8lv2RLc+PSZLxuIHStt2JIvmtiVkJ03zLHyIKfToBYDWvgIGxuA==
X-Received: by 2002:a37:a64b:: with SMTP id p72mr63826720qke.144.1555428891272;
        Tue, 16 Apr 2019 08:34:51 -0700 (PDT)
Received: from ovpn-120-81.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id a20sm29689919qth.88.2019.04.16.08.34.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 08:34:50 -0700 (PDT)
Subject: Re: [PATCH] slab: remove store_stackinfo()
To: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org
Cc: luto@kernel.org, jpoimboe@redhat.com, sean.j.christopherson@intel.com,
 penberg@kernel.org, rientjes@google.com, tglx@linutronix.de,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190416142258.18694-1-cai@lca.pw>
 <902fed9c-9655-a241-677d-5fa11b6c95a1@suse.cz>
From: Qian Cai <cai@lca.pw>
Message-ID: <332fc776-65fa-eee6-e15d-2d872bd9d220@lca.pw>
Date: Tue, 16 Apr 2019 11:34:49 -0400
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <902fed9c-9655-a241-677d-5fa11b6c95a1@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/16/19 11:25 AM, Vlastimil Babka wrote:
> On 4/16/19 4:22 PM, Qian Cai wrote:
>> store_stackinfo() does not seem used in actual SLAB debugging.
>> Potentially, it could be added to check_poison_obj() to provide more
>> information, but this seems like an overkill due to the declining
>> popularity of the SLAB, so just remove it instead.
>>
>> Signed-off-by: Qian Cai <cai@lca.pw>
> 
> I've acked Thomas' version already which was narrower, but no objection
> to remove more stuff on top of that. Linus (and I later in another
> thread) already pointed out /proc/slab_allocators. It only takes a look
> at add_caller() there to not regret removing that one.

Well, with the 2 patches I sent a while back, /proc/slab_allocators is back to
life on all arches (arm64, powerpc, and x86) which provides a little information
that may still useful for debugging until SLAB is gone entirely.

# cat /proc/slab_allocators
xfs_ili: 92 kmem_zone_alloc+0x6c/0x100 [xfs]
xfs_ifork: 2539 kmem_zone_alloc+0x6c/0x100 [xfs]
xfs_log_ticket: 3 kmem_zone_alloc+0x6c/0x100 [xfs]
sd_ext_cdb: 2 mempool_alloc_slab+0x1c/0x30
ip_fib_trie: 7 fib_insert_alias+0x11a/0x2b0
ip_fib_alias: 9 fib_table_insert+0x16d/0x510
eventpoll_pwq: 5 ep_ptable_queue_proc+0x3f/0xc0
inotify_inode_mark: 8 __x64_sys_inotify_add_watch+0x225/0x340
khugepaged_mm_slot: 6 __khugepaged_enter+0x36/0x190
file_lock_ctx: 23 locks_get_lock_context+0xf2/0x180
fsnotify_mark_connector: 79 fsnotify_add_mark_locked+0x117/0x460
task_delay_info: 509 __delayacct_tsk_init+0x1e/0x50
sigqueue: 2 __sigqueue_alloc+0xa8/0x130
kernfs_iattrs_cache: 122 __kernfs_iattrs+0x5c/0xf0
kernfs_node_cache: 28234 __kernfs_new_node.constprop.6+0x65/0x200
buffer_head: 1 alloc_buffer_head+0x21/0x70
nsproxy: 4 create_new_namespaces+0x36/0x1c0
vm_area_struct: 17 vm_area_alloc+0x1e/0x60
anon_vma_chain: 16 __anon_vma_prepare+0x3d/0x160
anon_vma: 18 __anon_vma_prepare+0xd2/0x160
Acpi-Operand: 2931 acpi_ut_allocate_object_desc_dbg+0x3e/0x69
Acpi-Namespace: 1618 acpi_ns_create_node+0x37/0x46
numa_policy: 47 __mpol_dup+0x3c/0x170
kmemleak_scan_area: 994 kmemleak_scan_area+0xa0/0x1e0
kmemleak_object: 513426 create_object+0x48/0x2c0
trace_event_file: 1650 trace_create_new_event+0x22/0x90
ftrace_event_field: 3198 __trace_define_field+0x36/0xc0
vmap_area: 890 alloc_vmap_area+0xaf/0x880
vmap_area: 663 alloc_vmap_area+0x2a3/0x880
vmap_area: 6 pcpu_get_vm_areas+0x277/0xbe0
vmap_area: 1 pcpu_get_vm_areas+0x689/0xbe0
vmap_area: 1 vmalloc_init+0x23d/0x26e
debug_objects_cache: 15917 __debug_object_init+0x444/0x4e0
debug_objects_cache: 999 debug_objects_mem_init+0x7b/0x5a2
page->ptl: 1526 ptlock_alloc+0x1e/0x40

