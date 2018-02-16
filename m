Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id DE8826B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 09:28:13 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id q5so2283215pll.17
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 06:28:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d2si1434003pgn.504.2018.02.16.06.28.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Feb 2018 06:28:12 -0800 (PST)
Date: Fri, 16 Feb 2018 15:28:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: don't defer struct page initialization for Xen pv
 guests
Message-ID: <20180216142808.GS7275@dhcp22.suse.cz>
References: <20180216133726.30813-1-jgross@suse.com>
 <20180216135940.GQ7275@dhcp22.suse.cz>
 <1424bb25-7d6a-ee21-83b4-0e90369d6132@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1424bb25-7d6a-ee21-83b4-0e90369d6132@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, akpm@linux-foundation.org, stable@vger.kernel.org, Pavel Tatashin <pasha.tatashin@oracle.com>

On Fri 16-02-18 15:02:17, Juergen Gross wrote:
> On 16/02/18 14:59, Michal Hocko wrote:
> > [CC Pavel]
> > 
> > On Fri 16-02-18 14:37:26, Juergen Gross wrote:
> >> Commit f7f99100d8d95dbcf09e0216a143211e79418b9f ("mm: stop zeroing
> >> memory during allocation in vmemmap") broke Xen pv domains in some
> >> configurations, as the "Pinned" information in struct page of early
> >> page tables could get lost.
> > 
> > Could you be more specific please?
> 
> In which way? Do you want to see the resulting crash in the commit
> message or some more background information?

ideally both.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
