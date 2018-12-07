Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 08C648E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 05:55:58 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id i55so1793710ede.14
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 02:55:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m48si1592695edc.130.2018.12.07.02.55.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 02:55:56 -0800 (PST)
Date: Fri, 7 Dec 2018 11:55:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/3] THP eligibility reporting via proc
Message-ID: <20181207105554.GX1286@dhcp22.suse.cz>
References: <20181120103515.25280-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181120103515.25280-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-api@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, David Rientjes <rientjes@google.com>, Jan Kara <jack@suse.cz>

On Tue 20-11-18 11:35:12, Michal Hocko wrote:
> Hi,
> this series of three patches aims at making THP eligibility reporting
> much more robust and long term sustainable. The trigger for the change
> is a regression report [1] and the long follow up discussion. In short
> the specific application didn't have good API to query whether a particular
> mapping can be backed by THP so it has used VMA flags to workaround that.
> These flags represent a deep internal state of VMAs and as such they should
> be used by userspace with a great deal of caution.
> 
> A similar has happened for [2] when users complained that VM_MIXEDMAP is
> no longer set on DAX mappings. Again a lack of a proper API led to an
> abuse.
> 
> The first patch in the series tries to emphasise that that the semantic
> of flags might change and any application consuming those should be really
> careful.
> 
> The remaining two patches provide a more suitable interface to address [1]
> and provide a consistent API to query the THP status both for each VMA
> and process wide as well.

Are there any other comments on these? I haven't heard any pushback so
far so I will re-send with RFC dropped early next week.

> 
> [1] http://lkml.kernel.org/r/http://lkml.kernel.org/r/alpine.DEB.2.21.1809241054050.224429@chino.kir.corp.google.com
> [2] http://lkml.kernel.org/r/20181002100531.GC4135@quack2.suse.cz
> 

-- 
Michal Hocko
SUSE Labs
