Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7A45F6B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 04:43:44 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c78so5468260wme.1
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:43:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 125si1638688wmg.78.2016.10.12.01.43.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 01:43:43 -0700 (PDT)
Date: Wed, 12 Oct 2016 10:43:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM in v4.8
Message-ID: <20161012084342.GF17128@dhcp22.suse.cz>
References: <20161012065423.GA16092@aaronlu.sh.intel.com>
 <20161012074411.GA9523@dhcp22.suse.cz>
 <20161012080022.GA17128@dhcp22.suse.cz>
 <24ea68df-8b6c-5319-a8ef-9c4f237cfc2a@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <24ea68df-8b6c-5319-a8ef-9c4f237cfc2a@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, lkp@01.org, Huang Ying <ying.huang@intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed 12-10-16 16:24:47, Aaron Lu wrote:
> On 10/12/2016 04:00 PM, Michal Hocko wrote:
[...]
> > which is an atomic high order request that failed which is not all that
> > unexpected when the system is low on memory. The allocation failure
> > report is hard to read because of unexpected end-of-lines but I suspect
> 
> Sorry about that, I'll try to find out why dmesg is saved so ugly on
> that test box.

Not your fault. This seems to be 4bcc595ccd80 ("printk: reinstate
KERN_CONT for printing continuation lines")

> > that again we are not able to allocate because of the CMA standing in
> > the way. I wouldn't call the above failure critical though.
>  
> I'll test that commit and v4.8 again with cma=0 added to cmdline.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
