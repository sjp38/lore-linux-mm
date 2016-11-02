Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0896B0274
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:00:46 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u144so16325215wmu.1
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:00:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kb8si4206746wjb.260.2016.11.02.12.00.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Nov 2016 12:00:44 -0700 (PDT)
Subject: Re: Softlockup during memory allocation
References: <e3177ea6-a921-dac9-f4f3-952c14e2c4df@kyup.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <89ee3413-71a3-403d-48fa-af325d40f8db@suse.cz>
Date: Wed, 2 Nov 2016 20:00:31 +0100
MIME-Version: 1.0
In-Reply-To: <e3177ea6-a921-dac9-f4f3-952c14e2c4df@kyup.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>, Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On 11/01/2016 09:12 AM, Nikolay Borisov wrote:
> In addition to that I believe there is something wrong
> with the NR_PAGES_SCANNED stats since they are being negative. 
> I haven't looked into the code to see how this value is being 
> synchronized and if there is a possibility of it temporary going negative. 

This is because there's a shared counter and percpu diffs, and crash
only looks at the shared counter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
