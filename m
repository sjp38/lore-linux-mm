Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 344766B0038
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 17:48:33 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so9146491pab.37
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 14:48:32 -0800 (PST)
Received: from mail-pb0-x234.google.com (mail-pb0-x234.google.com [2607:f8b0:400e:c01::234])
        by mx.google.com with ESMTPS id cf2si15619725pad.227.2014.02.04.14.48.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 14:48:31 -0800 (PST)
Received: by mail-pb0-f52.google.com with SMTP id jt11so9077776pbb.39
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 14:48:31 -0800 (PST)
Message-ID: <1391554110.10160.3.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [PATCH] fdtable: Avoid triggering OOMs from alloc_fdmem
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 04 Feb 2014 14:48:30 -0800
In-Reply-To: <87r47ik8ou.fsf@xmission.com>
References: <87r47jsb2p.fsf@xmission.com>
	 <1391530721.4301.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <871tzirdwf.fsf@xmission.com>
	 <1391539464.10160.1.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87r47ik8ou.fsf@xmission.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Tue, 2014-02-04 at 10:57 -0800, Eric W. Biederman wrote:

> As I have heard it described one tcp connection per small requestion,
> and someone goofed and started creating new connections when the server
> was bogged down.  But since all of the requests and replies were small I
> don't expect even TCP would allocate more than a 4KiB page in that
> worload.

Right, small writes uses regular skb (no page fragments).

> 
> I had oodles of 4KiB and 8KiB pages.  What size of memory allocation did
> you see failing?  

We got some reports of order-3 allocations failing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
