Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id AEDD16B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 18:18:13 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id l9so6770481plt.7
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 15:18:13 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c4si10713445pll.412.2018.11.14.15.18.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 15:18:12 -0800 (PST)
Date: Wed, 14 Nov 2018 15:18:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH] mm, memory_hotplug: do not clear numa_node
 association after hot_remove
Message-Id: <20181114151809.06c43a508cc773d3a5ee04f4@linux-foundation.org>
In-Reply-To: <20181114071442.GB23419@dhcp22.suse.cz>
References: <20181108100413.966-1-mhocko@kernel.org>
	<20181114071442.GB23419@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Oscar Salvador <OSalvador@suse.com>, LKML <linux-kernel@vger.kernel.org>, Wen Congyang <tangchen@cn.fujitsu.com>, Tang Chen <wency@cn.fujitsu.com>, Miroslav Benes <mbenes@suse.cz>, Vlastimil Babka <vbabka@suse.cz>

On Wed, 14 Nov 2018 08:14:42 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> It seems there were no objections here. So can we have it in linux-next
> for a wider testing a possibly target the next merge window?
> 

top-posting sucks!

I already have this queued for 4.21-rc1.
