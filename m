Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 315204403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 15:26:38 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id r129so229231390wmr.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 12:26:38 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gk5si19835231wjb.9.2016.02.04.12.26.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 12:26:37 -0800 (PST)
Date: Thu, 4 Feb 2016 15:25:46 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: vmpressure: make vmpressure_window a tunable.
Message-ID: <20160204202546.GB8208@cmpxchg.org>
References: <001a114b360c7fdb9b052adb91d6@google.com>
 <20160203161910.GA10440@cmpxchg.org>
 <CA+_MTtwE5NYV2SURj3j1X-RYDL=a0CHZ_UnEi9Giofy9i-JtDA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+_MTtwE5NYV2SURj3j1X-RYDL=a0CHZ_UnEi9Giofy9i-JtDA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martijn Coenen <maco@google.com>
Cc: linux-mm@kvack.org, Anton Vorontsov <anton@enomsg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>

On Thu, Feb 04, 2016 at 12:18:34PM +0100, Martijn Coenen wrote:
> I like this idea; I'm happy to come up with a window size and scaling
> factors that we think works well, and get your feedback on that. My
> only concern again would be that what works well for us may not work
> well for others.

Thanks for doing this. There is a good chance that this will work just
fine for others as well, so I think it's preferable to speculatively
change the implementation than adding ABI for potentially no reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
