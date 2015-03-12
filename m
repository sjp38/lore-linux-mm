Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4E2188299B
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 11:09:41 -0400 (EDT)
Received: by qgea108 with SMTP id a108so18721621qge.8
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 08:09:41 -0700 (PDT)
Received: from mail-qg0-x22e.google.com (mail-qg0-x22e.google.com. [2607:f8b0:400d:c04::22e])
        by mx.google.com with ESMTPS id g81si6741128qge.102.2015.03.12.08.09.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Mar 2015 08:09:40 -0700 (PDT)
Received: by qgdq107 with SMTP id q107so18722602qgd.6
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 08:09:39 -0700 (PDT)
Date: Thu, 12 Mar 2015 11:09:37 -0400
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: committed memory, mmaps and shms
Message-ID: <20150312150937.GA13256@dhcp22.suse.cz>
References: <20150311181044.GC14481@diablo.grulicueva.local>
 <20150312124053.GA30035@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150312124053.GA30035@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcos Dione <mdione@grulic.org.ar>
Cc: linux-kernel@vger.kernel.org, marcos-david.dione@amadeus.com, linux-mm@kvack.org

On Thu 12-03-15 08:40:53, Michal Hocko wrote:
[...]
> I think it would make more sense to add something like easily
> reclaimable chache to the output of free (pagecache-shmem-dirty
> basically). That would give an admin a better view on immediatelly
> re-usable memory.

Ohh, I have just learned that /proc/meminfo already provides such an
information. It's MemAvailable and should give you an idea about how
much memory is re-usable.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
