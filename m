Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D76C6B2019
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 06:41:38 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id z10so1135657edz.15
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 03:41:38 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 50si1206392eds.372.2018.11.20.03.41.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 03:41:37 -0800 (PST)
Date: Tue, 20 Nov 2018 12:41:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/3] mm, proc: be more verbose about unstable VMA
 flags in /proc/<pid>/smaps
Message-ID: <20181120114136.GE22247@dhcp22.suse.cz>
References: <20181120103515.25280-1-mhocko@kernel.org>
 <20181120103515.25280-2-mhocko@kernel.org>
 <20181120105135.GF8842@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181120105135.GF8842@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-api@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, David Rientjes <rientjes@google.com>

On Tue 20-11-18 11:51:35, Jan Kara wrote:
> Honestly, it just shows that no amount of documentation is going to stop
> userspace from abusing API that's exposing too much if there's no better
> alternative.

Yeah, I agree. And we should never expose such a low level stuff in the
first place. But, well, this ship has already sailed...

> But this is a good clarification regardless. So feel free to
> add:
> 
> Acked-by: Jan Kara <jack@suse.cz>

Thanks!
-- 
Michal Hocko
SUSE Labs
