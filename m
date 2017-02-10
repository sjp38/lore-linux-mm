Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 17BCA6B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 02:59:52 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id gt1so6432553wjc.0
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 23:59:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g2si1134094wrc.134.2017.02.09.23.59.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 23:59:51 -0800 (PST)
Date: Fri, 10 Feb 2017 08:59:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3 staging-next] android: Collect statistics from
 lowmemorykiller
Message-ID: <20170210075949.GB10893@dhcp22.suse.cz>
References: <9febd4f7-a0a7-5f52-e67b-df3163814ac5@sonymobile.com>
 <20170209192640.GC31906@dhcp22.suse.cz>
 <20170209200737.GB11098@kroah.com>
 <20170209205407.GF31906@dhcp22.suse.cz>
 <845d420f-dd26-fb48-c8ef-10ca1995daf8@sonymobile.com>
 <20170210075149.GA17166@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170210075149.GA17166@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: peter enderborg <peter.enderborg@sonymobile.com>, devel@driverdev.osuosl.org, Riley Andrews <riandrews@android.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri 10-02-17 08:51:49, Greg KH wrote:
> On Fri, Feb 10, 2017 at 08:21:32AM +0100, peter enderborg wrote:
[...]
> > Until then we have to polish this version as good as we can. It is
> > essential for android as it is now.
> 
> But if no one is willing to do the work to fix the reported issues, why
> should it remain?  Can you do the work here?  You're already working on
> fixing some of the issues in a differnt way, why not do the "real work"
> here instead for everyone to benifit from?

Well, to be honest, I do not think that the current code is easily
fixable. The approach was wrong from the day 1. Abusing slab shrinkers
is just a bad place to stick this logic. This all belongs to the
userspace. For that we need a proper mm pressure notification which is
supposed to be vmpressure but that one also doesn't seem to work all
that great. So rather than trying to fix unfixable I would stronly
suggest focusing on making vmpressure work reliably.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
