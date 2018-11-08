Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4676B05CB
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 05:14:03 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id g16-v6so9106601eds.20
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 02:14:03 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o27-v6si1649157eje.53.2018.11.08.02.14.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 02:14:02 -0800 (PST)
Date: Thu, 8 Nov 2018 11:14:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 4/4] mm: Remove managed_page_count spinlock
Message-ID: <20181108101400.GU27423@dhcp22.suse.cz>
References: <1541665398-29925-1-git-send-email-arunks@codeaurora.org>
 <1541665398-29925-5-git-send-email-arunks@codeaurora.org>
 <20181108083400.GQ27423@dhcp22.suse.cz>
 <4e5e2923a424ab2e2c50e56b2e538a3c@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4e5e2923a424ab2e2c50e56b2e538a3c@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: akpm@linux-foundation.org, keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On Thu 08-11-18 15:33:06, Arun KS wrote:
> On 2018-11-08 14:04, Michal Hocko wrote:
> > On Thu 08-11-18 13:53:18, Arun KS wrote:
> > > Now totalram_pages and managed_pages are atomic varibles. No need
> > > of managed_page_count spinlock.
> > 
> > As explained earlier. Please add a motivation here. Feel free to reuse
> > wording from
> > http://lkml.kernel.org/r/20181107103630.GF2453@dhcp22.suse.cz
> 
> Sure. Will add in next spin.

Andrew usually updates changelogs if you give him the full wording.
I would wait few days before resubmitting, if that is needed at all.
0day will throw a lot of random configs which can reveal some leftovers.
-- 
Michal Hocko
SUSE Labs
