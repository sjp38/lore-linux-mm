Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 727C56B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 09:11:44 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r202so4792127wmd.17
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 06:11:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m48si836468wrf.445.2017.10.20.06.11.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Oct 2017 06:11:43 -0700 (PDT)
Date: Fri, 20 Oct 2017 15:11:42 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [rfc 1/2] mm/hmm: Allow smaps to see zone device public pages
Message-ID: <20171020131142.z7kxvmlukg4z2shv@dhcp22.suse.cz>
References: <20171018063123.21983-1-bsingharora@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171018063123.21983-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: jglisse@redhat.com, linux-mm@kvack.org

On Wed 18-10-17 17:31:22, Balbir Singh wrote:
> vm_normal_page() normally does not return zone device public
> pages. In the absence of the visibility the output from smaps
> is limited and confusing. It's hard to figure out where the
> pages are. This patch uses _vm_normal_page() to expose them
> for accounting

Maybe I am missing something but does this patch make any sense without
patch 2? If no why they are not folded into a single one?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
