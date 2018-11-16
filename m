Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4AAD06B0946
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 06:57:30 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id j18so15544482oth.11
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 03:57:30 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 4si13406934otq.38.2018.11.16.03.57.29
        for <linux-mm@kvack.org>;
        Fri, 16 Nov 2018 03:57:29 -0800 (PST)
Subject: Re: [PATCH 2/5] mm: lower the printk loglevel for __dump_page
 messages
References: <20181116083020.20260-1-mhocko@kernel.org>
 <20181116083020.20260-3-mhocko@kernel.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <77da3b3f-9f3e-560f-1f00-0eb8523447ef@arm.com>
Date: Fri, 16 Nov 2018 17:27:24 +0530
MIME-Version: 1.0
In-Reply-To: <20181116083020.20260-3-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>



On 11/16/2018 02:00 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __dump_page messages use KERN_EMERG resp. KERN_ALERT loglevel (this is
> the case since 2004). Most callers of this function are really detecting
> a critical page state and BUG right after. On the other hand the
> function is called also from contexts which just want to inform about
> the page state and those would rather not disrupt logs that much (e.g.
> some systems route these messages to the normal console).
> 
> Reduce the loglevel to KERN_WARNING to make dump_page easier to reuse
> for other contexts while those messages will still make it to the kernel
> log in most setups. Even if the loglevel setup filters warnings away
> those paths that are really critical already print the more targeted
> error or panic and that should make it to the kernel log.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
