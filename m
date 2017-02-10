Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE436B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 02:51:51 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d185so38335303pgc.2
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 23:51:51 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 68si944969pga.48.2017.02.09.23.51.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 23:51:50 -0800 (PST)
Date: Fri, 10 Feb 2017 08:51:49 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/3 staging-next] android: Collect statistics from
 lowmemorykiller
Message-ID: <20170210075149.GA17166@kroah.com>
References: <9febd4f7-a0a7-5f52-e67b-df3163814ac5@sonymobile.com>
 <20170209192640.GC31906@dhcp22.suse.cz>
 <20170209200737.GB11098@kroah.com>
 <20170209205407.GF31906@dhcp22.suse.cz>
 <845d420f-dd26-fb48-c8ef-10ca1995daf8@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <845d420f-dd26-fb48-c8ef-10ca1995daf8@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sonymobile.com>
Cc: Michal Hocko <mhocko@kernel.org>, devel@driverdev.osuosl.org, Riley Andrews <riandrews@android.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, Feb 10, 2017 at 08:21:32AM +0100, peter enderborg wrote:
> Im not speaking for google, but I think there is a work ongoing to
> replace this with user-space code.

Really?  I have not heard this at all, any pointers to whom in Google is
doing it?

> Until then we have to polish this version as good as we can. It is
> essential for android as it is now.

But if no one is willing to do the work to fix the reported issues, why
should it remain?  Can you do the work here?  You're already working on
fixing some of the issues in a differnt way, why not do the "real work"
here instead for everyone to benifit from?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
