Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5694C6B0006
	for <linux-mm@kvack.org>; Wed, 23 May 2018 05:26:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a127-v6so1988322wmh.6
        for <linux-mm@kvack.org>; Wed, 23 May 2018 02:26:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x58-v6si3352820edx.338.2018.05.23.02.26.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 May 2018 02:26:30 -0700 (PDT)
Date: Wed, 23 May 2018 11:26:28 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC] trace when adding memory to an offline nod
Message-ID: <20180523092628.GM20441@dhcp22.suse.cz>
References: <20180523080108.GA30350@techadventures.net>
 <20180523083756.GJ20441@dhcp22.suse.cz>
 <20180523084342.GK20441@dhcp22.suse.cz>
 <20180523091914.GA31306@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523091914.GA31306@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: linux-mm@kvack.org, vbabka@suse.cz, pasha.tatashin@oracle.com, dan.j.williams@intel.com

On Wed 23-05-18 11:19:14, Oscar Salvador wrote:
[...]
> For what is worth it:
> 
> Tested-by: Oscar Salvador <osalvador@techadventures.net>

Thanks for testing. I will repost with the other issue you have noticed.
-- 
Michal Hocko
SUSE Labs
