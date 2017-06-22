Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E630683292
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 16:58:54 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 23so1448613wry.4
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 13:58:54 -0700 (PDT)
Received: from mail-wr0-x22b.google.com (mail-wr0-x22b.google.com. [2a00:1450:400c:c0c::22b])
        by mx.google.com with ESMTPS id e14si2236232wrd.321.2017.06.22.13.58.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 13:58:53 -0700 (PDT)
Received: by mail-wr0-x22b.google.com with SMTP id 77so39597989wrb.1
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 13:58:53 -0700 (PDT)
Subject: Re: [Bug 196157] New: 100+ times slower disk writes on
 4.x+/i386/16+RAM, compared to 3.x
References: <bug-196157-27@https.bugzilla.kernel.org/>
 <20170622123736.1d80f1318eac41cd661b7757@linux-foundation.org>
From: Alkis Georgopoulos <alkisg@gmail.com>
Message-ID: <7e1fbca4-919a-a161-20ec-e95527b58979@gmail.com>
Date: Thu, 22 Jun 2017 23:58:50 +0300
MIME-Version: 1.0
In-Reply-To: <20170622123736.1d80f1318eac41cd661b7757@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>

IGBPI?I1I? 22/06/2017 10:37 I 1/4 I 1/4 , I? Andrew Morton I-I3I?I+-I?Iu:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> hm, that's news to me.
> 
> Does anyone have access to a large i386 setup?  Interested in
> reproducing this and figuring out what's going wrong?
> 


I can arrange ssh/vnc access to an i386 box with 16 GB RAM that has the 
issue, if some kernel dev wants to work on that. Please PM me for 
details - also tell me your preferred distro.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
