Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4D4126B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 18:37:35 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id n128so12429353pfn.3
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 15:37:35 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id kw9si18386353pab.63.2016.01.20.15.37.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 15:37:34 -0800 (PST)
Received: by mail-pa0-x22e.google.com with SMTP id yy13so12260153pab.3
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 15:37:34 -0800 (PST)
Date: Wed, 20 Jan 2016 15:37:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm: make apply_to_page_range more robust
In-Reply-To: <569F184D.8020602@nextfour.com>
Message-ID: <alpine.DEB.2.10.1601201536040.18155@chino.kir.corp.google.com>
References: <569F184D.8020602@nextfour.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-600493671-1453333053=:18155"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Mika_Penttil=C3=A4?= <mika.penttila@nextfour.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-600493671-1453333053=:18155
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Wed, 20 Jan 2016, Mika PenttilA? wrote:

> Recent changes (4.4.0+) in module loader triggered oops on ARM. 
>     
> can be 0 triggering the bug  BUG_ON(addr >= end);.
> 
> The call path is SyS_init_module()->set_memory_xx()->apply_to_page_range(),
> and apply_to_page_range gets zero length resulting in triggering :
>    
>   BUG_ON(addr >= end)
> 
> This is a consequence of changes in module section handling (Rusty CC:ed).
> This may be triggable only with certain modules and/or gcc versions. 
> 

Well, what module are you loading to cause this crash?  Why would it be 
passing size == 0 to apply_to_page_range()?  Again, that sounds like a 
problem that we _want_ to know about since it is probably the result of 
buggy code and this patch would be covering it up.

Please elaborate on the problem that you are seeing, preferably with a 
stack trace of the BUG so we can fix the problem instead of papering over 
it.
--397176738-600493671-1453333053=:18155--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
