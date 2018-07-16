Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB5FA6B0010
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 12:23:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d30-v6so10170101edd.0
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 09:23:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m2-v6si10166510edi.372.2018.07.16.09.23.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 09:23:38 -0700 (PDT)
Date: Mon, 16 Jul 2018 18:23:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Caching/buffers become useless after some time
Message-ID: <20180716162337.GY17280@dhcp22.suse.cz>
References: <CADF2uSrW=Z=7NeA4qRwStoARGeT1y33QSP48Loc1u8XSdpMJOA@mail.gmail.com>
 <20180712113411.GB328@dhcp22.suse.cz>
 <CADF2uSqDDt3X_LHEQnc5xzHpqJ66E5gncogwR45bmZsNHxV55A@mail.gmail.com>
 <CADF2uSr-uFz+AAhcwP7ORgGgtLohayBtpDLxx9kcADDxaW8hWw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADF2uSr-uFz+AAhcwP7ORgGgtLohayBtpDLxx9kcADDxaW8hWw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: linux-mm@kvack.org

On Mon 16-07-18 17:53:42, Marinko Catovic wrote:
> I can provide further data now, monitoring vmstat:
> 
> https://pastebin.com/j0dMGBe4 .. 1 day later, 600MB/13GB in use, 35GB free
> https://pastebin.com/N011kYyd .. 1 day later, 300MB/10GB in use, 40GB free,
> performance becomes even worse
> 
> the issue raises up again, I would have to drop caches by now to restore
> normal usage for another day or two.
> 
> Afaik there should be no reason at all to not have the buffers/cache fill
> up the entire memory, isn't that true?
> There is to my knowledge almost no O_DIRECT involved, also as mentioned
> before: when dropping caches
> the buffers/cache usage would eat up all RAM within the hour as usual for
> 1-2 days until it starts to go crazy again.
> 
> As mentioned, the usage oscillates up and down instead of up until all RAM
> is consumed.
> 
> Please tell me if there is anything else I can do to help investigate this.

Do you have periodic /proc/vmstat snapshots I have asked before?
-- 
Michal Hocko
SUSE Labs
