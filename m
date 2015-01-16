Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 68EB26B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 12:57:50 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id n3so4104032wiv.1
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 09:57:49 -0800 (PST)
Received: from mail-we0-x235.google.com (mail-we0-x235.google.com. [2a00:1450:400c:c03::235])
        by mx.google.com with ESMTPS id l6si5331719wic.97.2015.01.16.09.57.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 Jan 2015 09:57:49 -0800 (PST)
Received: by mail-we0-f181.google.com with SMTP id q58so21592456wes.12
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 09:57:49 -0800 (PST)
Date: Fri, 16 Jan 2015 18:57:45 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in
 too_many_isolated
Message-ID: <20150116175745.GA22136@dhcp22.suse.cz>
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org>
 <20150114165036.GI4706@dhcp22.suse.cz>
 <54B7F7C4.2070105@codeaurora.org>
 <20150116154922.GB4650@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150116154922.GB4650@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org, Christoph Lameter <cl@gentwo.org>

On Fri 16-01-15 16:49:22, Michal Hocko wrote:
[...]
> Why cannot we simply update the global counters from vmstat_shepherd
> directly?

OK, I should have checked the updating paths... This would be racy, so
update from remote is not an option without additional trickery (like
retries etc.) :/
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
