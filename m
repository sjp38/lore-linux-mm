Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 668328E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 17:48:52 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id ay11so2460187plb.20
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:48:52 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e188si20404908pfa.16.2018.12.20.14.48.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 14:48:51 -0800 (PST)
Date: Thu, 20 Dec 2018 14:48:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH] mm, memory_hotplug: do not clear numa_node
 association after hot_remove
Message-Id: <20181220144849.375f554ed6d1f968807aa6db@linux-foundation.org>
In-Reply-To: <f9dd3dd0-3b20-446f-a131-70180fb733bf@arm.com>
References: <20181108100413.966-1-mhocko@kernel.org>
	<20181108102917.GV27423@dhcp22.suse.cz>
	<048c04ae-7394-d03f-813e-42acdc965dd2@arm.com>
	<20181109075914.GD18390@dhcp22.suse.cz>
	<f9dd3dd0-3b20-446f-a131-70180fb733bf@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Oscar Salvador <OSalvador@suse.com>, LKML <linux-kernel@vger.kernel.org>, Miroslav Benes <mbenes@suse.cz>, Vlastimil Babka <vbabka@suse.cz>

On Fri, 9 Nov 2018 16:34:29 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:

> > 
> > Do you see any problems with the patch as is?
> 
> No, this patch does remove an erroneous node-cpu map update which help solve
> a real crash.

I think I'll take that as an ack.
