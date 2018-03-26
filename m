Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3094D6B0006
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 19:15:41 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v8so10180292pgs.9
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 16:15:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w26sor4196190pge.69.2018.03.26.16.15.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Mar 2018 16:15:39 -0700 (PDT)
Date: Tue, 27 Mar 2018 07:15:31 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 1/2] mm/sparse: pass the __highest_present_section_nr + 1
 to alloc_func()
Message-ID: <20180326231531.GA79994@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20180326081956.75275-1-richard.weiyang@gmail.com>
 <alpine.DEB.2.20.1803261356380.251389@chino.kir.corp.google.com>
 <20180326223034.GA78976@WeideMacBook-Pro.local>
 <alpine.DEB.2.20.1803261546240.99792@chino.kir.corp.google.com>
 <20180326225621.GA79778@WeideMacBook-Pro.local>
 <alpine.DEB.2.20.1803261557280.101300@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803261557280.101300@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, dave.hansen@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org

On Mon, Mar 26, 2018 at 03:58:28PM -0700, David Rientjes wrote:
>On Tue, 27 Mar 2018, Wei Yang wrote:
>
>> >Lol.  I think it would make more sense for the second patch to come before 
>> >the first
>> 
>> Thanks for your comment.
>> 
>> Do I need to reorder the patch and send v2?
>> 
>
>I think we can just ask Andrew to apply backwards, but it's not crucial.  
>The ordering of patch 2 before patch 1 simply helped me to understand the 
>boundaries better.

Ah, got it.

Actually, the original order is what you expected. While for some mysterious
reasons, I reordered them :-(

Maybe you are right, it would be more easy to understand with patch 2 before
patch 1. :-)

Have a good day~

-- 
Wei Yang
Help you, Help me
