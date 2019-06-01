Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D389C28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 09:26:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 337EF271B4
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 09:26:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 337EF271B4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=chris-wilson.co.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0F0B6B0005; Sat,  1 Jun 2019 05:26:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B99316B0006; Sat,  1 Jun 2019 05:26:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD50A6B0007; Sat,  1 Jun 2019 05:26:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC3C6B0005
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 05:26:46 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id k18so5238572wrl.4
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 02:26:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:to:from:in-reply-to:cc:references
         :message-id:user-agent:subject:date;
        bh=0NTF6YWWF/C/GPt4rO/hlTmPqTjZ3wSj4q0O8XaZv8g=;
        b=HPPY28t2v2Q7ibKq9eh7PFv8kiNYWydygnDwihE6zBJwblf47DdizStWQsMeY/Rcmx
         hzUUtipMD95mdX7vpQc8uHVG8VAxNSIuQwuCOF7QIyvJfGCVLncGftMOrLmJjl9virKj
         HdX37+BDK5s+OCsZEpOwD21VyMkC7d/+FydzrtPOXJIxCqkPFUKljU8JKkl/qVjibvQd
         BGQAlDfHAVgSFmEWvZZaB73hFAxJkKjBZyGi1U0OE+MVc6oCnwLxqjQ85LokbVzYEy7f
         Ox4o6VqsNIm7a0V1oB4cQE+YCW5Hz5o71fThHdqO+GfhBwlmu4/FkxaNrhNlQYmuwyXF
         vfJw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Gm-Message-State: APjAAAXIl1yhxLeAUrCrCwmLSSIEakOaLHkio9ITngZmSFA+vXpf2TFb
	ZX8LFtJ5WyrH98yLnCNQekQ1qP5Q90MdxouMXl10uSL+OYnOy+/6rt04tcagw7DgSoIS5r73DaW
	fTbxy5J4mnB/Ekn6M94RmWQ75yfy14hZj7v939nDkq1E9IA8S6I81cW1wyoHXg5s=
X-Received: by 2002:a5d:5501:: with SMTP id b1mr9339789wrv.222.1559381205893;
        Sat, 01 Jun 2019 02:26:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwspEBbxwdl8xoQTP5swiJzK19pMRCk9pkFFPHXksuAMBxssLB4SaBcxQC4EArVyJtqYfnd
X-Received: by 2002:a5d:5501:: with SMTP id b1mr9339739wrv.222.1559381204907;
        Sat, 01 Jun 2019 02:26:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559381204; cv=none;
        d=google.com; s=arc-20160816;
        b=VKA+vnP0BmX/g01CTMBoIlukpsUJ9NPuyQXmyIqQ6dgrEf6FG/vrXq9NIE5fSspKr0
         99RRJk8BXuM2BuxWL/ExROsTQJn7gU/m7hNKDAc+p0G9xtlmUNt35hB8nON/SNq4K3+Y
         IClPOTPG8F8K8TAUxNzpLFnLzvGrCyqKH2xd6yAHibmau4I/C8yefFApMKH73XGKclZn
         Db/086958U174RopGdvZ6nF1zik67SGRNjXltG6ESpJy8hs6cTHUTvshMqIZhq22mfk4
         bYbkbsQyuJ5hIwBV6iih+LpNVMoqcVC27pcRhL1L0xsdMDYd7nuyxNoGO6veZbXNBaSH
         VHjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:subject:user-agent:message-id:references:cc:in-reply-to:from
         :to:content-transfer-encoding:mime-version;
        bh=0NTF6YWWF/C/GPt4rO/hlTmPqTjZ3wSj4q0O8XaZv8g=;
        b=VGy2IzdG1aOzvOhyOtaxMbgdvgqXyjCsJc2fr0qU3/gjN04MeOTCGJfmemOBryTUAe
         zJoDiJlf+vCX1YWs6aDGa1lFbWVpUHkBTchBNiUjN+dnMhE6vu9npSFJIaJRqM8OsMNY
         k8Jea88i0dx0jegkZNzi+BNebvv7At/vYhZu07qTqoMslF4jxNKo7dRdXsMGup3SNJ7X
         UN9wYZ9yM51veioKV+j+Vecehepxzka9tRnDwTDgqxRUPFeQBUVzRjl4DbjhH+t55T7H
         ol6jC6FvJi71nAfo/Xc0zVn1uspGkEz4vUQbn0SgxoBaj/ZoAA3jwJK9uh9p1/Dsl13t
         uX3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id z13si6233796wrq.58.2019.06.01.02.26.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 02:26:44 -0700 (PDT)
Received-SPF: neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) client-ip=109.228.58.192;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Default-Received-SPF: pass (skip=forwardok (res=PASS)) x-ip-name=78.156.65.138;
Received: from localhost (unverified [78.156.65.138]) 
	by fireflyinternet.com (Firefly Internet (M1)) with ESMTP (TLS) id 16757666-1500050 
	for multiple; Sat, 01 Jun 2019 10:26:25 +0100
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
To: Andrew Morton <akpm@linux-foundation.org>,
 Matthew Wilcox <willy@infradead.org>, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20190307153051.18815-1-willy@infradead.org>
Cc: Matthew Wilcox <willy@infradead.org>,
 "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>,
 Jan Kara <jack@suse.cz>, Song Liu <liu.song.a23@gmail.com>
References: <20190307153051.18815-1-willy@infradead.org>
Message-ID: <155938118174.22493.11599751119608173366@skylake-alporthouse-com>
User-Agent: alot/0.6
Subject: Re: [PATCH v4] page cache: Store only head pages in i_pages
Date: Sat, 01 Jun 2019 10:26:21 +0100
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Quoting Matthew Wilcox (2019-03-07 15:30:51)
> Transparent Huge Pages are currently stored in i_pages as pointers to
> consecutive subpages.  This patch changes that to storing consecutive
> pointers to the head page in preparation for storing huge pages more
> efficiently in i_pages.
> =

> Large parts of this are "inspired" by Kirill's patch
> https://lore.kernel.org/lkml/20170126115819.58875-2-kirill.shutemov@linux=
.intel.com/
> =

> Signed-off-by: Matthew Wilcox <willy@infradead.org>
> Acked-by: Jan Kara <jack@suse.cz>
> Reviewed-by: Kirill Shutemov <kirill@shutemov.name>
> Reviewed-and-tested-by: Song Liu <songliubraving@fb.com>
> Tested-by: William Kucharski <william.kucharski@oracle.com>
> Reviewed-by: William Kucharski <william.kucharski@oracle.com>

I've bisected some new softlockups under THP mempressure to this patch.
They are all rcu stalls that look similar to:
[  242.645276] rcu: INFO: rcu_preempt detected stalls on CPUs/tasks:
[  242.645293] rcu: 	Tasks blocked on level-0 rcu_node (CPUs 0-3): P828
[  242.645301] 	(detected by 1, t=3D5252 jiffies, g=3D55501, q=3D221)
[  242.645307] gem_syslatency  R  running task        0   828    815 0x0000=
4000
[  242.645315] Call Trace:
[  242.645326]  ? __schedule+0x1a0/0x440
[  242.645332]  ? preempt_schedule_irq+0x27/0x50
[  242.645337]  ? apic_timer_interrupt+0xa/0x20
[  242.645342]  ? xas_load+0x3c/0x80
[  242.645347]  ? xas_load+0x8/0x80
[  242.645353]  ? find_get_entry+0x4f/0x130
[  242.645358]  ? pagecache_get_page+0x2b/0x210
[  242.645364]  ? lookup_swap_cache+0x42/0x100
[  242.645371]  ? do_swap_page+0x6f/0x600
[  242.645375]  ? unmap_region+0xc2/0xe0
[  242.645380]  ? __handle_mm_fault+0x7a9/0xfa0
[  242.645385]  ? handle_mm_fault+0xc2/0x1c0
[  242.645393]  ? __do_page_fault+0x198/0x410
[  242.645399]  ? page_fault+0x5/0x20
[  242.645404]  ? page_fault+0x1b/0x20

Any suggestions as to what information you might want?
-Chris

