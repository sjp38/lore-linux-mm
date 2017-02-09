Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8CCED6B0388
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 15:54:11 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id c7so3247549wjb.7
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 12:54:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d27si1760046wrc.260.2017.02.09.12.54.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 12:54:10 -0800 (PST)
Date: Thu, 9 Feb 2017 21:54:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3 staging-next] android: Collect statistics from
 lowmemorykiller
Message-ID: <20170209205407.GF31906@dhcp22.suse.cz>
References: <9febd4f7-a0a7-5f52-e67b-df3163814ac5@sonymobile.com>
 <20170209192640.GC31906@dhcp22.suse.cz>
 <20170209200737.GB11098@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170209200737.GB11098@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: peter enderborg <peter.enderborg@sonymobile.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Riley Andrews <riandrews@android.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Thu 09-02-17 21:07:37, Greg KH wrote:
> On Thu, Feb 09, 2017 at 08:26:41PM +0100, Michal Hocko wrote:
> > On Thu 09-02-17 14:21:45, peter enderborg wrote:
> > > This collects stats for shrinker calls and how much
> > > waste work we do within the lowmemorykiller.
> > 
> > This doesn't explain why do we need this information and who is going to
> > use it. Not to mention it exports it in /proc which is considered a
> > stable user API. This is a no-go, especially for something that is still
> > lingering in the staging tree without any actuall effort to make it
> > fully supported MM feature. I am actually strongly inclined to simply
> > drop lmk from the tree completely.
> 
> I thought that someone was working to get the "native" mm features to
> work properly with the lmk "feature"  Do you recall if that work got
> rejected, or just never happened?

Never happened AFAIR. There were some attempts to tune the current
behavior which has been rejected for one reason or another but I am not
really aware of anybody working on moving the code from staging area.

I already have this in the to-send queue, just didn't get to post it yet
because I planned to polish the reasoning some more.
---
