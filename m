Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id ABE316B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 11:23:08 -0500 (EST)
Received: by wiwl15 with SMTP id l15so16142407wiw.3
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 08:23:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hl10si19439333wib.6.2015.03.02.08.23.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 08:23:07 -0800 (PST)
Message-ID: <54F48E68.6070706@suse.cz>
Date: Mon, 02 Mar 2015 17:23:04 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch v2 1/3] mm: remove GFP_THISNODE
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com> <54F469C1.9090601@suse.cz> <alpine.DEB.2.11.1503020944200.5540@gentwo.org> <54F48980.3090008@suse.cz> <alpine.DEB.2.11.1503021007030.6245@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1503021007030.6245@gentwo.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>, Jarno Rajahalme <jrajahalme@nicira.com>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, dev@openvswitch.org

On 03/02/2015 05:08 PM, Christoph Lameter wrote:
> On Mon, 2 Mar 2015, Vlastimil Babka wrote:
>
>>> You are thinking about an opportunistic allocation attempt in SLAB?
>>>
>>> AFAICT SLAB allocations should trigger reclaim.
>>>
>>
>> Well, let me quote your commit 952f3b51beb5:
>
> This was about global reclaim. Local reclaim is good and that can be
> done via zone_reclaim.

Right, so the patch is a functional change for zone_reclaim_mode == 1, 
where !__GFP_WAIT will prevent it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
