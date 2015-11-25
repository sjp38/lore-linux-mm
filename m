Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4901E6B0255
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 13:03:53 -0500 (EST)
Received: by wmww144 with SMTP id w144so190608644wmw.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 10:03:52 -0800 (PST)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id t132si7387777wmt.17.2015.11.25.10.03.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 10:03:52 -0800 (PST)
Received: by wmuu63 with SMTP id u63so148463160wmu.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 10:03:52 -0800 (PST)
Date: Wed, 25 Nov 2015 19:03:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmstat: retrieve more accurate vmstat value
Message-ID: <20151125180350.GT27283@dhcp22.suse.cz>
References: <1448346123-2699-1-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.20.1511240934130.20512@east.gentwo.org>
 <20151125025735.GC9563@js1304-P5Q-DELUXE>
 <alpine.DEB.2.20.1511251002380.31590@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1511251002380.31590@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 25-11-15 10:04:44, Christoph Lameter wrote:
> On Wed, 25 Nov 2015, Joonsoo Kim wrote:
> 
> > I think that maintaining duplicate counter to guarantee accuracy isn't
> > reasonable solution. It would cause more overhead to the system.
> 
> Simply remove the counter from the vmstat handling and do it differently
> then.

We definitely do not want yet another set of counters. vmstat counters
are not only to be exported into the userspace. We have in kernel users
as well. I do agree that there are users who can cope with some level of
imprecision though and those which depend on the accuracy can use
zone_page_state_snapshot which doesn't impose any overhead on others.
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
