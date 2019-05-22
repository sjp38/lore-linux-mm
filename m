Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07EECC282DD
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 19:33:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD3282089E
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 19:33:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="VBk26ou6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD3282089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 419756B000A; Wed, 22 May 2019 15:33:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A3896B000C; Wed, 22 May 2019 15:33:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2918A6B000D; Wed, 22 May 2019 15:33:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id F24836B000A
	for <linux-mm@kvack.org>; Wed, 22 May 2019 15:33:16 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e69so2251371pgc.7
        for <linux-mm@kvack.org>; Wed, 22 May 2019 12:33:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NVmFnhEc6T7q/G2QkECz53StEYBc2Etm5D1NuDVEJYM=;
        b=ge88nEcA216E+O5EBMwujCozh4Gw9KTJo22gdAGGddhGT321JYXGK9YLwE1ZNgTWM5
         CEQGPd+CHWdQcWVdYIediED09q6hOYpncBtoxejoh4r/IeRAMUFX6E3Va33vUxduE7aS
         vEAPF3DSx9N0Rb+DCjwcGOXihn6bisxafSvfdIOZEYv5MVofqSX6ldTI12dIeLlS+8YO
         kf8btjNpNMBYUxeShWQuPGoEjWPvFt0IE/0WXtvblMbKZyndQXi30FnoI0gM/CXWG9tU
         U2bRq3/ypYh6tAmUFdzihD/xz2F4LitDLdYEdknXGQ21EXkvOvkXhZTSImKB32Fco75k
         fYUA==
X-Gm-Message-State: APjAAAUmARFaqZW3rETt7RakUfgqWaiQ1sAow9Wnvmb8GnMvBYPx/uPs
	szog6QtMZ8yU0cHF6daMyjVn4QC38Yv+jMjrz1AVnT7hb/ObkDqiHx32gTwoY3nV3fyZlYFj9sE
	xTlAdJWbK+7GXwXRRoG89t0Os44yxSQn9jwCzOp86iEOu6aLAQgA9S0ye88BkXes92A==
X-Received: by 2002:a62:2c17:: with SMTP id s23mr67358946pfs.51.1558553596637;
        Wed, 22 May 2019 12:33:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+/ZugSGnf28cfY76R5VpTw0spuCHN62wuEDl/qIZ6NwQITTqMbVPn3fbW0vXlPtOzPNIa
X-Received: by 2002:a62:2c17:: with SMTP id s23mr67358874pfs.51.1558553595923;
        Wed, 22 May 2019 12:33:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558553595; cv=none;
        d=google.com; s=arc-20160816;
        b=WU8zS/pLmm3vqp+i1bbI/jFpI2prRoKeyImR69igelty/uFR676LkJHYx6iPd9ZZgy
         1yUOUrflCRJceU+chmNLN3FtDHUkZm4u6AkeNOCFej8la1vl3Rt7Y4QOa/CdZtz43DKr
         fAnrdwoZYaJmMwKynqfD4M1vSu2NWDU7v8OYHq5+t892UMhBmzkXu7p1FHtQNHwbVSeF
         SqOT9lJFd7tVRkgHH+pWv6vDvE4om/vF3sOtWxsbPj5xA8HiMM08t+DYzZwlSNyO2fmT
         FWwYt2BpnzPleaKvJs0BryLKD9MVrdPrnvRKscyeD0WArJYpC8iJNmWStHgeVUZky0YK
         19rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=NVmFnhEc6T7q/G2QkECz53StEYBc2Etm5D1NuDVEJYM=;
        b=PjYJIzI2kyHEThU8Sm5bT83i9eCm/fdwB3ujqINK1reZ+G/C8hX9iY9fJK4WVKFJ3E
         0PovNDlihbNxQsuGhj1UQtaeSgMd9RBTwNER5unHvJm6pnsQGxayFx9qCehFbpMwpRn7
         2Sxbh+tg8uc9NQkalTkgNt6uD5FssQEI39R70N8A7ZJslCIpHb7jSuyhMinJYjzkc0TP
         XMOjZ+8Vxl/eWF0czQLCsSc430aV8qceyLcDwRhPP3zpcv26HrH4om0m1OMWvtvJCcob
         JmeovHkgXl93lDiZhjzbfZPXIw9MfVvONnSpFesUZAxfruZNXWKe35rWhot5nxuK/dzC
         ckUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=VBk26ou6;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m4si30718396pfb.134.2019.05.22.12.33.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 12:33:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=VBk26ou6;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 580E22081C;
	Wed, 22 May 2019 19:33:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558553595;
	bh=6qKU+B/1sLWcpfUDU4BTAWbTNsNaXNjYvd5KmtBg83g=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=VBk26ou6dZVk+4grpdhByS7aR1CjwbLWb4irfv9IlBIyD9Jhwsri03YCDRfCP1B6k
	 Cpsw+1GSshZluumcBnSbDzcBwMLtQgvuul3Shs1xU0YX9290UpJ6s1H6qbzj5wnrJ2
	 76gsPU1MsWwvAtWMibxKbokqGx4V8/C9PCvxy4s8=
Date: Wed, 22 May 2019 12:33:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: 9erthalion6@gmail.com, mhocko@suse.com, shaoyafang@didiglobal.com,
 linux-mm@kvack.org
Subject: Re: [PATCH v2] mm/vmscan: expose cgroup_ino for memcg reclaim
 tracepoints
Message-Id: <20190522123314.e17fc708ff6548b9b621d6ad@linux-foundation.org>
In-Reply-To: <1557649528-11676-1-git-send-email-laoar.shao@gmail.com>
References: <1557649528-11676-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 12 May 2019 16:25:28 +0800 Yafang Shao <laoar.shao@gmail.com> wrote:

> We can use the exposed cgroup_ino to trace specified cgroup.
> 
> For example,
> step 1, get the inode of the specified cgroup
> 	$ ls -di /tmp/cgroupv2/foo
> step 2, set this inode into tracepoint filter to trace this cgroup only
> 	(assume the inode is 11)
> 	$ cd /sys/kernel/debug/tracing/events/vmscan/
> 	$ echo 'cgroup_ino == 11' > mm_vmscan_memcg_reclaim_begin/filter
> 	$ echo 'cgroup_ino == 11' > mm_vmscan_memcg_reclaim_end/filter

Seems straightforward enough.

But please explain the value of such a change.  What is wrong with the
current situation and how does this change improve things?  A simple
use-case scenario would be good.

I can guess why it is beneficial, but I'd rather not guess!

Thanks.

