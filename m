Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AF6658E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 15:32:40 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id t2so17412739edb.22
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 12:32:40 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 94si236343edc.413.2018.12.19.12.32.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 12:32:39 -0800 (PST)
Date: Wed, 19 Dec 2018 21:32:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 0/6] mm: Randomize free memory
Message-ID: <20181219203236.GA5689@dhcp22.suse.cz>
References: <154510700291.1941238.817190985966612531.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154510700291.1941238.817190985966612531.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Keith Busch <keith.busch@intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Kees Cook <keescook@chromium.org>, x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andy Lutomirski <luto@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de

On Mon 17-12-18 20:23:23, Dan Williams wrote:
> Andrew, this needs at least an ack from Michal, or Mel before it moves
> forward. It would be a nice surprise / present to see it move forward
> before the holidays, but I suspect it may need to simmer until the new
> year. This series is against v4.20-rc6.

I am sorry but I am unlikely to look into this before the end of the
year and I do not want to promise early days in new year either because
who knows how much stuff piles up by then. But this is definitely on my
radar.
-- 
Michal Hocko
SUSE Labs
