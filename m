Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C3C02280850
	for <linux-mm@kvack.org>; Sun, 21 May 2017 12:35:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w79so20587636wme.7
        for <linux-mm@kvack.org>; Sun, 21 May 2017 09:35:09 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id n21si9714103wrn.252.2017.05.21.09.35.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 May 2017 09:35:07 -0700 (PDT)
Date: Sun, 21 May 2017 09:35:06 -0700
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [v4 1/1] mm: Adaptive hash table scaling
Message-ID: <20170521163506.GA8096@two.firstfloor.org>
References: <1495300013-653283-1-git-send-email-pasha.tatashin@oracle.com>
 <1495300013-653283-2-git-send-email-pasha.tatashin@oracle.com>
 <87h90faroe.fsf@firstfloor.org>
 <a09bba26-8461-653d-6b43-2df897a238f0@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a09bba26-8461-653d-6b43-2df897a238f0@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org

On Sun, May 21, 2017 at 08:58:25AM -0400, Pasha Tatashin wrote:
> Hi Andi,
> 
> Thank you for looking at this. I mentioned earlier, I would not want to
> impose a cap. However, if you think that for example dcache needs a cap,
> there is already a mechanism for that via high_limit argument, so the client

Lots of arguments are not the solution. Today this only affects a few
highend systems, but we'll see much more large memory systems in the
future. We don't want to have all these users either waste their memory,
or apply magic arguments.

> can be changed to provide that cap. However, this particular patch addresses
> scaling problem for everyone by making it scale with memory at a slower
> pace.

Yes your patch goes in the right direction and should be applied.

Just could be even more aggressive.

Long term probably all these hash tables need to be converted to rhash
to dynamically resize.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
