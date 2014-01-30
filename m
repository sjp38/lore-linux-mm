Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id EB0806B0031
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 04:08:06 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id b13so5736878wgh.7
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 01:08:06 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id be6si2790159wib.13.2014.01.30.01.08.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 01:08:05 -0800 (PST)
Date: Thu, 30 Jan 2014 09:08:02 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: /proc/pid/numa_maps no longer shows "default" policy
Message-ID: <20140130090802.GH6732@suse.de>
References: <20140130173457.115a30f8@kryten>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140130173457.115a30f8@kryten>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: linux-mm@kvack.org

On Thu, Jan 30, 2014 at 05:34:57PM +1100, Anton Blanchard wrote:
> 
> Hi Mel,
> 
> We recently noticed that /proc/pid/numa_maps used to show default
> policy mappings as such:
> 
> cat /proc/self/numa_maps 
> 00100000 default mapped=1 mapmax=339 active=0 N0=1
> 
> But now it shows them as prefer:X:
> 
> cat /proc/self/numa_maps
> 10000000 prefer:1 file=/usr/bin/cat mapped=1 N0=1
> 
> It looks like this was caused by 5606e387 (mm: numa: Migrate on
> reference policy). I'm not sure if this is expected, but we don't have
> CONFIG_NUMA_BALANCING enabled on ppc64 so I wasn't expecting processes
> to have a particular node affinity by default.
> 

https://lkml.org/lkml/2014/1/25/182

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
