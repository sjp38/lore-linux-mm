Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 622EE6B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 10:59:34 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so4178925pdj.0
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 07:59:34 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id br6si27304709pdb.251.2015.01.13.07.59.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jan 2015 07:59:33 -0800 (PST)
Date: Tue, 13 Jan 2015 18:59:24 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 1/2] mm: page_counter: pull "-1" handling out of
 page_counter_memparse()
Message-ID: <20150113155924.GB11264@esperanza>
References: <1420776904-8559-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1420776904-8559-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jan 08, 2015 at 11:15:03PM -0500, Johannes Weiner wrote:
> It was convenient to have the generic function handle it, as all
> callsites agreed.  Subsequent patches will add new user interfaces
> that do not want to support the "-1" special string.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
