Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 41E8B28025F
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 07:48:10 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id u3so8725081pgn.3
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 04:48:10 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id f4si832073plf.618.2017.11.16.04.48.07
        for <linux-mm@kvack.org>;
        Thu, 16 Nov 2017 04:48:08 -0800 (PST)
Subject: Re: [PATCH 1/3] lockdep: Apply crossrelease to PG_locked locks
References: <1510802067-18609-1-git-send-email-byungchul.park@lge.com>
 <1510802067-18609-2-git-send-email-byungchul.park@lge.com>
 <20171116120216.nxbwkj5y3kvim6cj@dhcp22.suse.cz>
From: Byungchul Park <byungchul.park@lge.com>
Message-ID: <cf8aa555-7435-ea00-a4ee-3dcfd33ab5a0@lge.com>
Date: Thu, 16 Nov 2017 21:48:05 +0900
MIME-Version: 1.0
In-Reply-To: <20171116120216.nxbwkj5y3kvim6cj@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com, jack@suse.cz, jlayton@redhat.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, npiggin@gmail.com, rgoldwyn@suse.com, vbabka@suse.cz, pombredanne@nexb.com, vinmenon@codeaurora.org, gregkh@linuxfoundation.org

On 11/16/2017 9:02 PM, Michal Hocko wrote:
> for each struct page. So you are doubling the size. Who is going to
> enable this config option? You are moving this to page_ext in a later
> patch which is a good step but it doesn't go far enough because this
> still consumes those resources. Is there any problem to make this
> kernel command line controllable? Something we do for page_owner for
> example?

Sure. I will add it.

> Also it would be really great if you could give us some measures about
> the runtime overhead. I do not expect it to be very large but this is

The major overhead would come from the amount of additional memory
consumption for 'lockdep_map's.

Do you want me to measure the overhead by the additional memory
consumption?

Or do you expect another overhead?

Could you tell me what kind of result you want to get?

> something people are usually interested in when enabling debugging
> features.

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
