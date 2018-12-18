Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id DB3698E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 16:46:48 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id o23so12978175pll.0
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 13:46:48 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u184si14189493pgd.262.2018.12.18.13.46.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 13:46:47 -0800 (PST)
Date: Tue, 18 Dec 2018 13:46:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm, page_alloc: Fix has_unmovable_pages for
 HugePages
Message-Id: <20181218134644.6770936603f7640f415918a7@linux-foundation.org>
In-Reply-To: <20181218073655.GB30879@dhcp22.suse.cz>
References: <20181217225113.17864-1-osalvador@suse.de>
	<20181217150726.6eea4942005516d565dae488@linux-foundation.org>
	<20181218073655.GB30879@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oscar Salvador <osalvador@suse.de>, vbabka@suse.cz, pavel.tatashin@microsoft.com, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 18 Dec 2018 08:36:55 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> > > Signed-off-by: Oscar Salvador <osalvador@suse.de>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks.

> > cc:stable?
> 
> See http://lkml.kernel.org/r/20181217152936.GR30879@dhcp22.suse.cz. I
> believe nobody is simply using gigantic pages and hotplug at the same
> time and those pages do not seem to cross cma regions as well. At least
> not since hugepage_migration_supported stops reporting giga pages as
> migrateable.
> 
> That being said, I do not think we really need it in stable but it
> should be relatively easy to backport so no objection from me to put it
> there.

OK, done.  Sasha would have grabbed it anyway :(
