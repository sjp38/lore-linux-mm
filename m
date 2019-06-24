Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.7 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D506FC4646C
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:12:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B7D620674
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:12:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="jvgv4lXq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B7D620674
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47EF18E0006; Mon, 24 Jun 2019 11:12:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 456C88E0002; Mon, 24 Jun 2019 11:12:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3450C8E0006; Mon, 24 Jun 2019 11:12:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7318E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 11:12:22 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id k21so22365343ioj.3
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 08:12:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=i6RP5sEIUQVe7K2Xxca+vDWdrwxXZnb7gXo4fjhFOrI=;
        b=PSaxTXM9z9Ts/p2NCy0hgaiZBMX0f/No/66cmwy/G1RbrnJUVZNsIo8kKxSVkkiKZA
         DPQRY8IzFYccNSwrOJe5wljXrUZghD1/r7jy+QUj5UDReZfrlwFfA7qQGmYe0yvElSXQ
         ICaOTPhnlmTXClDdzNMjfF93/sEF4BrvVLAs8g+KXMYScHBry/i3PqCoX6MfCNXex/Vl
         znmVxohtrpEcBpqp4hmLyL8xSBTdc1jYdQW+jJmmi+lA4JbKukxJF+ZseDV4DFti0ORZ
         11LCrrhnXfQuBXHkTx/T0FfSiR6gb23zieuhm+NWy2HEXzQzxwb4gQp3q+q9lgYgsdwf
         IQkA==
X-Gm-Message-State: APjAAAXqyL8jHGtE098zXLR2YQDJ4Gqu7RJHC5WEqyU/QeauYAoN0gCW
	XzSe2GyVHXkCe+IkmHsze3z44ZY4lPKdFQRlgtmgVGFrpIshbvo/cO1m57dTJ+AVlMT4yGR7RH9
	hOWRpjD0HqcRJwWRzm0663Lkv41LC9HgNuEFHa4CGxSk/5ALXpd1tu/I3nu/4k7RX7g==
X-Received: by 2002:a6b:e315:: with SMTP id u21mr17119062ioc.14.1561389141854;
        Mon, 24 Jun 2019 08:12:21 -0700 (PDT)
X-Received: by 2002:a6b:e315:: with SMTP id u21mr17118991ioc.14.1561389141159;
        Mon, 24 Jun 2019 08:12:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561389141; cv=none;
        d=google.com; s=arc-20160816;
        b=sHcQ4Mrp2A70ZEbv2En4Oqcy4o4o4YT0r3/2lFKeuAsD4vQpO7Qd8eb44DX/jYl1n0
         0B+AX+w56xLstJoLtESzLuAI0vPv6q9McAEu6JwFqVPxpmEywqG/NpXWYBSKQ4XheUjm
         Kti7lbq0bvi9TmuiegfJB277a98HFfdJHFG+3crs+AS/Y32MdIXS5Kt5TRyJNOP8frZd
         zsE2MqwNAXOZSHS2YNtWNZMaB+UMjRpMjKf3F56NX/3WXWAKkpza6WYuqadBsbGvBJR/
         fjtRqOb9K9PO0EEw7Mwt/sAcmCrIg0QZcy5q8w30ypgfor0/O4aXCIzI3DvGCEkx2dVE
         pCJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=i6RP5sEIUQVe7K2Xxca+vDWdrwxXZnb7gXo4fjhFOrI=;
        b=bW5IFr9IFbLneo8/m/ey8bAmHCO56OlNhW9qnXaf2iWHwT14rsznbiQkOo6IGyz7MP
         J9Xe0688jj2qQo18spythQJVof80Do2wFPoMSoUa1xKwCaZBQzMXsuK1zSE/aWjWSmcc
         QYkUil0aq17xeJN60aDKq6voGkNHYeeXNVvyzs9o3qgZ0KfheFS0P8IXVm5VLdcZK2b7
         IFg/pEWQcgsL9sFLMkP+OULc+TwsZjfGK+D6Zj9Tai9ym65e4KfdxFfwzUcIKvvz7T/F
         vVXn6lvz4CWTbJeMKOR9kaoPpuR2IYSbrnx0mdg08NLTIXAVMn5Mx7hxhBf7X5sRYd7p
         aeQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jvgv4lXq;
       spf=pass (google.com: domain of zwisler@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r3sor29693412jai.10.2019.06.24.08.12.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 08:12:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of zwisler@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jvgv4lXq;
       spf=pass (google.com: domain of zwisler@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zwisler@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=i6RP5sEIUQVe7K2Xxca+vDWdrwxXZnb7gXo4fjhFOrI=;
        b=jvgv4lXqQaoTaUCCgSqFt7dA1UG8exJvGDZ8+KtKxJ/F1Y3nXoRjm3mDxBFqek2yPa
         6+vxZZK7y20j65gwxGP1TZgLx/GKaAMRMeotexYhGiKkgr37FscTGeHpnWfkup4MQBr7
         kVxvBPx8VMwMyBZCYCSMzStUhOKfpSYUOOQNP1hG5P9YNsNt6Hqx3aziwKkU0BVMlqW5
         XwuM0TSzS42G1XJIYxd1+xd1q7vW9P7SovoLT4e4ilPznQYjhpoSBkE7NXsIzj1AHE0l
         W1m+hPlUxfwPUS1qbPsmfFXhOaK94yklTADYhpuaQtZALjOAMeIsSx6O8N77qkEgoEW0
         dCVw==
X-Google-Smtp-Source: APXvYqxhCdDitnoCJq15metdrBXJXKIUUa7soKbJdiR2x1Uo/Def9XZLDCqSPhNc0JhCX6SVb8UL6w==
X-Received: by 2002:a02:2a8f:: with SMTP id w137mr127594244jaw.50.1561389140370;
        Mon, 24 Jun 2019 08:12:20 -0700 (PDT)
Received: from google.com ([2620:15c:183:200:855f:8919:84a7:4794])
        by smtp.gmail.com with ESMTPSA id f17sm25760614ioc.2.2019.06.24.08.12.19
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 24 Jun 2019 08:12:19 -0700 (PDT)
Date: Mon, 24 Jun 2019 09:12:17 -0600
From: Ross Zwisler <zwisler@google.com>
To: kbuild test robot <lkp@intel.com>
Cc: Ross Zwisler <zwisler@chromium.org>, kbuild-all@01.org,
	linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>,
	linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Fletcher Woodruff <fletcherw@google.com>,
	Justin TerAvest <teravest@google.com>, Jan Kara <jack@suse.cz>,
	stable@vger.kernel.org
Subject: Re: [PATCH v2 3/3] ext4: use jbd2_inode dirty range scoping
Message-ID: <20190624151217.GA249955@google.com>
References: <20190620151839.195506-4-zwisler@google.com>
 <201906240244.12r4nktI%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201906240244.12r4nktI%lkp@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 02:54:49AM +0800, kbuild test robot wrote:
> Hi Ross,
> 
> Thank you for the patch! Yet something to improve:
> 
> [auto build test ERROR on linus/master]
> [also build test ERROR on v5.2-rc6 next-20190621]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Ross-Zwisler/mm-add-filemap_fdatawait_range_keep_errors/20190623-181603
> config: x86_64-rhel-7.6 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
> 
> All errors (new ones prefixed by >>):
> 
> >> ERROR: "jbd2_journal_inode_ranged_wait" [fs/ext4/ext4.ko] undefined!
> >> ERROR: "jbd2_journal_inode_ranged_write" [fs/ext4/ext4.ko] undefined!

Yep, this is caused by the lack of EXPORT_SYMBOL() calls for these two new
jbd2 functions.  Ted also pointed this out and fixed this up when he was
committing:

https://patchwork.kernel.org/patch/11007139/#22717091

Thank you for the report!

