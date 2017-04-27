Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F9FF6B0038
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 10:37:25 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id t189so1396046wme.15
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 07:37:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 132si3614077wmh.131.2017.04.27.07.37.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 07:37:23 -0700 (PDT)
Date: Thu, 27 Apr 2017 16:37:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm: Uncharge poisoned pages
Message-ID: <20170427143721.GK4706@dhcp22.suse.cz>
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

On Tue 25-04-17 16:27:51, Laurent Dufour wrote:
> When page are poisoned, they should be uncharged from the root memory
> cgroup.
> 
> This is required to avoid a BUG raised when the page is onlined back:
> BUG: Bad page state in process mem-on-off-test  pfn:7ae3b
> page:f000000001eb8ec0 count:0 mapcount:0 mapping:          (null)
> index:0x1
> flags: 0x3ffff800200000(hwpoison)

My knowledge of memory poisoning is very rudimentary but aren't those
pages supposed to leak and never come back? In other words isn't the
hoplug code broken because it should leave them alone?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
