Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8BBA76B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 15:23:56 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 204so20437593pfx.1
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 12:23:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b11si215214plk.176.2017.02.09.12.23.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 12:23:55 -0800 (PST)
Date: Thu, 9 Feb 2017 21:07:37 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/3 staging-next] android: Collect statistics from
 lowmemorykiller
Message-ID: <20170209200737.GB11098@kroah.com>
References: <9febd4f7-a0a7-5f52-e67b-df3163814ac5@sonymobile.com>
 <20170209192640.GC31906@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170209192640.GC31906@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: peter enderborg <peter.enderborg@sonymobile.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Riley Andrews <riandrews@android.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Thu, Feb 09, 2017 at 08:26:41PM +0100, Michal Hocko wrote:
> On Thu 09-02-17 14:21:45, peter enderborg wrote:
> > This collects stats for shrinker calls and how much
> > waste work we do within the lowmemorykiller.
> 
> This doesn't explain why do we need this information and who is going to
> use it. Not to mention it exports it in /proc which is considered a
> stable user API. This is a no-go, especially for something that is still
> lingering in the staging tree without any actuall effort to make it
> fully supported MM feature. I am actually strongly inclined to simply
> drop lmk from the tree completely.

I thought that someone was working to get the "native" mm features to
work properly with the lmk "feature"  Do you recall if that work got
rejected, or just never happened?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
