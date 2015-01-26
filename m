Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id F22416B0070
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 13:35:20 -0500 (EST)
Received: by mail-qc0-f175.google.com with SMTP id c9so8369309qcz.6
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 10:35:20 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id 38si14201348qgj.49.2015.01.26.10.35.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 10:35:20 -0800 (PST)
Date: Mon, 26 Jan 2015 12:35:19 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in
 too_many_isolated
In-Reply-To: <20150126172832.GC22681@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.11.1501261235030.16786@gentwo.org>
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org> <20150114165036.GI4706@dhcp22.suse.cz> <54B7F7C4.2070105@codeaurora.org> <20150116154922.GB4650@dhcp22.suse.cz> <54BA7D3A.40100@codeaurora.org> <alpine.DEB.2.11.1501171347290.25464@gentwo.org>
 <20150126172832.GC22681@dhcp22.suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org

On Mon, 26 Jan 2015, Michal Hocko wrote:
> >From 12d00a8066e336d3e1311600b50fa9b588798448 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Mon, 26 Jan 2015 18:07:51 +0100
> Subject: [PATCH] vmstat: Do not use deferrable delayed work for vmstat_update

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
