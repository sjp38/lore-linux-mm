Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 175BD6B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 09:36:48 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id p10so14327665wes.0
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 06:36:47 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dh2si6927977wjc.47.2015.01.20.06.36.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 06:36:45 -0800 (PST)
Date: Tue, 20 Jan 2015 15:36:44 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm: memcontrol: default hierarchy interface for memory
 fix - "none"
Message-ID: <20150120143644.GL25342@dhcp22.suse.cz>
References: <1421508107-29377-1-git-send-email-hannes@cmpxchg.org>
 <20150120133711.GI25342@dhcp22.suse.cz>
 <20150120143002.GB11181@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150120143002.GB11181@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 20-01-15 09:30:02, Johannes Weiner wrote:
[...]
> Another possibility would be "infinity",

yes infinity definitely sounds much better to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
