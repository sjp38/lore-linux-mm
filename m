Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1CC8C6B007B
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 05:18:57 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id l18so3228370wgh.40
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 02:18:56 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x7si3770766wiw.14.2014.11.20.02.18.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 02:18:56 -0800 (PST)
Date: Thu, 20 Nov 2014 11:18:55 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: =?utf-8?B?562U5aSN?= =?utf-8?Q?=3A?= low memory killer
Message-ID: <20141120101855.GB24575@dhcp22.suse.cz>
References: <AF7C0ADF1FEABA4DABABB97411952A2EC91E38@CN-MBX02.HTC.COM.TW>
 <20141120095802.GA24575@dhcp22.suse.cz>
 <AF7C0ADF1FEABA4DABABB97411952A2EC91EF5@CN-MBX02.HTC.COM.TW>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AF7C0ADF1FEABA4DABABB97411952A2EC91EF5@CN-MBX02.HTC.COM.TW>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhiyuan_zhu@htc.com
Cc: hannes@cmpxchg.org, Future_Zhou@htc.com, Rachel_Zhang@htc.com, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, cgroups@vger.kernel.org, linux-mm@kvack.org, greg@kroah.com

On Thu 20-11-14 10:09:25, zhiyuan_zhu@htc.com wrote:
> Hi Michal
> Thanks for your kindly support.
> I got a device, and dump the /proc/meminfo and /proc/vmstat files,
> they are the Linux standard proc files. 
> I found that: Cached = 339880 KB, but nr_free_pages=14675*4 = 58700KB
> and nr_shmem = 508*4=2032KB
>
> nr_shmem is just a little memory, and nr free pages + nr_shmem is
> largely less than Cached.  So why nr_free_pages is largely less than
> Cached? Thank you.

nr_free_pages refers to pages which are not allocated. Cached referes to
a used memory which is easily reclaimable so it can be reused should
there be a need and free memory drops down. So this is a normal
situation. How is this related to the lowmemory killer question posted
previously?

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
