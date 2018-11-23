Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 29B666B3158
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 09:48:18 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id n10-v6so5611389oib.5
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 06:48:18 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id r128si6399934oig.167.2018.11.23.06.48.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 06:48:16 -0800 (PST)
Subject: Re: [PATCH] mm: debug: Fix a width vs precision bug in printk
References: <20181123072135.gqvblm2vdujbvfjs@kili.mountain>
 <20181123090125.GC8625@dhcp22.suse.cz> <20181123143605.GB2970@unbuntlaptop>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <ddbf19fb-1d73-40ca-b421-4c171466833b@I-love.SAKURA.ne.jp>
Date: Fri, 23 Nov 2018 23:48:06 +0900
MIME-Version: 1.0
In-Reply-To: <20181123143605.GB2970@unbuntlaptop>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On 2018/11/23 23:36, Dan Carpenter wrote:
> On Fri, Nov 23, 2018 at 10:01:25AM +0100, Michal Hocko wrote:
>> On Fri 23-11-18 10:21:35, Dan Carpenter wrote:
>>> We had intended to only print dentry->d_name.len characters but there is
>>> a width vs precision typo so if the name isn't NUL terminated it will
>>> read past the end of the buffer.
>>
>> OK, it took me quite some time to grasp what you mean here. The code
>> works as expected because d_name.len and dname.name are in sync so there
>> no spacing going to happen. Anyway what you propose is formally more
>> correct I guess.
>>  
> 
> Yeah.  If we are sure that the name has a NUL terminator then this
> change has no effect.

There seems to be %pd which is designed for printing "struct dentry".
