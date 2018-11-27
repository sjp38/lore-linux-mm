Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B49576B4815
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:17:09 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c53so10956842edc.9
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 05:17:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r23-v6si774558ejb.173.2018.11.27.05.17.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 05:17:08 -0800 (PST)
Date: Tue, 27 Nov 2018 14:17:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm, proc: report PR_SET_THP_DISABLE in proc
Message-ID: <20181127131707.GW12455@dhcp22.suse.cz>
References: <20181120103515.25280-1-mhocko@kernel.org>
 <20181120103515.25280-4-mhocko@kernel.org>
 <0ACDD94B-75AD-4DD0-B2E3-32C0EDFBAA5E@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0ACDD94B-75AD-4DD0-B2E3-32C0EDFBAA5E@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: linux-api@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 26-11-18 17:33:32, William Kucharski wrote:
> 
> 
> This determines whether the page can theoretically be THP-mapped , but
> is the intention to also check for proper alignment and/or preexisting
> PAGESIZE page cache mappings for the address range?

This is only about the process wide flag to disable THP. I do not see
how this can be alighnement related. I suspect you wanted to ask in the
smaps patch?

> I'm having to deal with both these issues in the text page THP
> prototype I've been working on for some time now.

Could you be more specific about the issue and how the alignment comes
into the game? The only thing I can think of is to not report VMAs
smaller than the THP as eligible. Is this what you are looking for?
-- 
Michal Hocko
SUSE Labs
