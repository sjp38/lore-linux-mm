Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D401C6B0007
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 09:28:41 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id w10so11732055wrg.2
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 06:28:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 90si4642506wrq.373.2018.02.26.06.28.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Feb 2018 06:28:40 -0800 (PST)
Date: Mon, 26 Feb 2018 15:28:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Hangs in balance_dirty_pages with arm-32 LPAE + highmem
Message-ID: <20180226142839.GB16842@dhcp22.suse.cz>
References: <b77a6596-3b35-84fe-b65b-43d2e43950b3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b77a6596-3b35-84fe-b65b-43d2e43950b3@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-block@vger.kernel.org

On Fri 23-02-18 11:51:41, Laura Abbott wrote:
> Hi,
> 
> The Fedora arm-32 build VMs have a somewhat long standing problem
> of hanging when running mkfs.ext4 with a bunch of processes stuck
> in D state. This has been seen as far back as 4.13 but is still
> present on 4.14:
> 
[...]
> This looks like everything is blocked on the writeback completing but
> the writeback has been throttled. According to the infra team, this problem
> is _not_ seen without LPAE (i.e. only 4G of RAM). I did see
> https://patchwork.kernel.org/patch/10201593/ but that doesn't seem to
> quite match since this seems to be completely stuck. Any suggestions to
> narrow the problem down?

How much dirtyable memory does the system have? We do allow only lowmem
to be dirtyable by default on 32b highmem systems. Maybe you have the
lowmem mostly consumed by the kernel memory. Have you tried to enable
highmem_is_dirtyable?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
