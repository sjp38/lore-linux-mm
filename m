Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02F5AC28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:51:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6670F20866
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:51:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="1kvyh/lh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6670F20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00D036B0003; Wed,  5 Jun 2019 09:51:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFFED6B000D; Wed,  5 Jun 2019 09:51:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E15746B000E; Wed,  5 Jun 2019 09:51:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 795BE6B0003
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 09:51:42 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id m4so4102706lji.5
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 06:51:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:subject:to:message-id:date
         :user-agent:mime-version:content-language:content-transfer-encoding;
        bh=IrflhE8QTVLvAUZbNa4CJKo6kCQj/0hU43yCa3MGsqM=;
        b=gGTruHZef4juD8ZNzOs2zfUqut9ALR5tNX7pCOTEgjz3Y6bgmzE7sAYzw1HcWOOd7c
         OZtv56Gmo45qrMfBvBw2a3HHHZwbQdi4EJy1P8ixeGHZPMM/oe80hCFCOBZXN0jFUlFB
         22xMEuy6X9Zd7plKxp5Md3vxcFtK6GAgCe4I9tlBEuZyHNruqd/LEgU/WyZ0zYL17MY6
         sgu+4ASs3obqmfhqFgxPyi9ro76/BCEYFuYMScJOoJq8DekJSnVmsvgr/RrNpghK1TXg
         6gc1aFq+KFZCzHUebxquMevkAkZw+/sw16JNnFCjEMtgB3anAERL6buuG5vrIljthnt5
         2k/Q==
X-Gm-Message-State: APjAAAXYeyA+gruf8vSy2DvwncsT0wsamUWkB9T55A/OxV30qKiJhETs
	hh5eW5XmG8ySudxvxLdWGcuTepTXkqtiZR6V5TGUCIFYT2IGCMP47kUxiRgVSz9KXai9V9rWJqF
	z703LLSq/A3EL6yjrsERGaoHgvSGc6D0qpc6aJ2GSjPxTfGpOR1jtMI3l7figIiPFoQ==
X-Received: by 2002:a2e:9e07:: with SMTP id e7mr3265994ljk.55.1559742701580;
        Wed, 05 Jun 2019 06:51:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZ+FdTajRNp5NQE+IXuz3u4AflMUBRi7qCc2az7pbjYvqklL+znlaQ9yCVVVejglk2p2K9
X-Received: by 2002:a2e:9e07:: with SMTP id e7mr3265941ljk.55.1559742700712;
        Wed, 05 Jun 2019 06:51:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559742700; cv=none;
        d=google.com; s=arc-20160816;
        b=Roryt0UwRXxliYlNsPQCs7IXY/KZoqb9ReF5RJ4wrnLx7AeZYIKcCgahD8NkHVBaWH
         KBp3fk0brhoMvIVBbdiIR148E9WwKSqg2zpk9HGL93eHPDh03WDEaro7Qu2jTj7urgLq
         +Bg7LOchle1Mj8GmT0ds9XA0ku2rw9/Yb5ZNx/ZynYPhtIVGbj5nQrvk1qg1iVT+/a3Z
         vaZlstUCHLuxt26kVn0ROJUpAgSPifT0ttbzfs1eRrWlrPWkfHfHFDQ+vmwYYHFrG9oq
         ktGGWTZLUJLcJSgOkJXUcmyHQHtJJ7eonUfJGJy4ybXV6JBxlCJBL/Mz67UlVqUjnFAv
         8paw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:to:subject:from:dkim-signature;
        bh=IrflhE8QTVLvAUZbNa4CJKo6kCQj/0hU43yCa3MGsqM=;
        b=GFrkCoKMZp8S04ImRsgwFlyCV06ws+SEmHpzPmx5g77OMV1g5R31MPnL949eFtbMA5
         HPf6ouLh5rK80SocP3+O3bp44KXGFlYrKOSgki9nePWZsP17qUG47W2LYUfI9PD6A99q
         vzdnOspDR69PF3TmbJkOws9jRD8efazkrYIgINDZYIGi3mqvezwu6EhHHmxwz6mrgWau
         Udnzj3sz4NAMAwT6n+ZN7Mh3zAONYuSVHo6tdDc/yQvmPkZYQ5PLvxQ99KXMjylAKQGo
         qQnEdM+d1ua9QR8BPLmTHEstK0kwCWFjkAeR5qI4HMyCiQmAotehTFjD73Hf98KHcRZu
         bonQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b="1kvyh/lh";
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net. [2a02:6b8:0:1619::183])
        by mx.google.com with ESMTPS id q3si6858965lfp.138.2019.06.05.06.51.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 06:51:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) client-ip=2a02:6b8:0:1619::183;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b="1kvyh/lh";
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1g.mail.yandex.net (mxbackcorp1g.mail.yandex.net [IPv6:2a02:6b8:0:1402::301])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id C8A582E14BE;
	Wed,  5 Jun 2019 16:51:39 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp1g.mail.yandex.net (nwsmtp/Yandex) with ESMTP id MwaVXp0t7H-pdl8LjvU;
	Wed, 05 Jun 2019 16:51:39 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1559742699; bh=IrflhE8QTVLvAUZbNa4CJKo6kCQj/0hU43yCa3MGsqM=;
	h=Date:Message-ID:Subject:From:To;
	b=1kvyh/lhpIH0gxPMrRkJpnhWUOwZBiojX8U+j69t+cCp3UXkowDoCB+3Yi7BTZR/K
	 hKRewCaT53bZ5JJnNKzVBI3Ur4nI1X7KYbNo9PNZtq0ETBxEu9QRf5LSPB642Qy9g1
	 Wt4od409KQVY9xVTJaIq6WiIyV02Pb6cbibgD2yY=
Authentication-Results: mxbackcorp1g.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:b19a:10ab:8629:85d9])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id YZ0kbb9Zza-pde0J8Sd;
	Wed, 05 Jun 2019 16:51:39 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
X-Mozilla-News-Host: news://news.gmane.org:119
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [BUG?] without memory pressure negative dentries overpopulate dcache
To: linux-kernel <linux-kernel@vger.kernel.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm <linux-mm@kvack.org>
Message-ID: <ff0993a2-9825-304c-6a5b-2e9d4b940032@yandex-team.ru>
Date: Wed, 5 Jun 2019 16:51:38 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I've seen problem on large server where horde of negative dentries
slowed down all lookups significantly:

watchdog: BUG: soft lockup - CPU#25 stuck for 22s! [atop:968884] at __d_lookup_rcu+0x6f/0x190

slabtop:

   OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
85118166 85116916   0%    0.19K 2026623       42  16212984K dentry
16577106 16371723   0%    0.10K 425054       39   1700216K buffer_head
935850 934379   0%    1.05K  31195       30    998240K ext4_inode_cache
663740 654967   0%    0.57K  23705       28    379280K radix_tree_node
399987 380055   0%    0.65K   8163       49    261216K proc_inode_cache
226380 168813   0%    0.19K   5390       42     43120K cred_jar
  70345  65721   0%    0.58K   1279       55     40928K inode_cache
105927  43314   0%    0.31K   2077       51     33232K filp
630972 601503   0%    0.04K   6186      102     24744K ext4_extent_status
   5848   4269   0%    3.56K    731        8     23392K task_struct
  16224  11531   0%    1.00K    507       32     16224K kmalloc-1024
   6752   5833   0%    2.00K    422       16     13504K kmalloc-2048
199680 158086   0%    0.06K   3120       64     12480K anon_vma_chain
156128 154751   0%    0.07K   2788       56     11152K Acpi-Operand

Total RAM is 256 GB

These dentries came from temporary files created and deleted by postgres.
But this could be easily reproduced by lookup of non-existent files.

Of course, memory pressure easily washes them away.

Similar problem happened before around proc sysctl entries:
https://lkml.org/lkml/2017/2/10/47

This one does not concentrate in one bucket and needs much more memory.

Looks like dcache needs some kind of background shrinker started
when dcache size or fraction of negative dentries exceeds some threshold.

