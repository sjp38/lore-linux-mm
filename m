Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EA6C06B4905
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:29:19 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c3so11248090eda.3
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:29:19 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b6si33995edc.315.2018.11.27.08.29.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 08:29:17 -0800 (PST)
Date: Tue, 27 Nov 2018 17:29:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: warn only once if page table misaccounting is
 detected
Message-ID: <20181127162916.GB6923@dhcp22.suse.cz>
References: <20181127083603.39041-1-heiko.carstens@de.ibm.com>
 <20181127131916.GX12455@dhcp22.suse.cz>
 <20181127143638.GE3625@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181127143638.GE3625@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill@shutemov.name>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue 27-11-18 15:36:38, Heiko Carstens wrote:
> On Tue, Nov 27, 2018 at 02:19:16PM +0100, Michal Hocko wrote:
> > On Tue 27-11-18 09:36:03, Heiko Carstens wrote:
> > > Use pr_alert_once() instead of pr_alert() if page table misaccounting
> > > has been detected.
> > > 
> > > If this happens once it is very likely that there will be numerous
> > > other occurrence as well, which would flood dmesg and the console with
> > > hardly any added information. Therefore print the warning only once.
> > 
> > Have you actually experience a flood of these messages? Is one per mm
> > message really that much?
> 
> Yes, I did. Since in this case all compat processes caused the message
> to appear, I saw thousands of these messages.

This means something went colossally wrong and seeing an avalanche of
messages might be actually helpful because you can at least see the
pattern. I wonder whether the underlying issue would be obvious from a
single instance.

Maybe we want ratelimit instead?
 
> > If yes why rss counters do not exhibit the same problem?
> 
> No rss counter messages appeared. Or do you suggest that the other
> pr_alert() within check_mm() should also be changed?

Whatever we go with (and I do not have a strong opinion here) we should
be consistent I believe.

-- 
Michal Hocko
SUSE Labs
