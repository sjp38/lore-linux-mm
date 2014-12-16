Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1F9006B0032
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 00:44:10 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so13107464pdb.24
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 21:44:09 -0800 (PST)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com. [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id ri7si16866014pbc.145.2014.12.15.21.44.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Dec 2014 21:44:08 -0800 (PST)
Received: by mail-pd0-f176.google.com with SMTP id r10so11221752pdi.21
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 21:44:07 -0800 (PST)
Date: Tue, 16 Dec 2014 14:43:58 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm/zsmalloc: adjust order of functions
Message-ID: <20141216054357.GA17615@blaptop>
References: <1418478203-17687-1-git-send-email-opensource.ganesh@gmail.com>
 <20141216003941.GA17665@blaptop>
 <CADAEsF99yOT0ZHD3yDxT_tOM-48=3gut+-GB6SR5BBZxZ_XY6w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADAEsF99yOT0ZHD3yDxT_tOM-48=3gut+-GB6SR5BBZxZ_XY6w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, Dec 16, 2014 at 12:08:02PM +0800, Ganesh Mahendran wrote:
> Hello Minchan,
> 
> 
> 2014-12-16 8:40 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> > Hello Ganesh,
> >
> > On Sat, Dec 13, 2014 at 09:43:23PM +0800, Ganesh Mahendran wrote:
> >> Currently functions in zsmalloc.c does not arranged in a readable
> >> and reasonable sequence. With the more and more functions added,
> >> we may meet below inconvenience. For example:
> >>
> >> Current functions:
> >>     void zs_init()
> >>     {
> >>     }
> >>
> >>     static void get_maxobj_per_zspage()
> >>     {
> >>     }
> >>
> >> Then I want to add a func_1() which is called from zs_init(), and this new added
> >> function func_1() will used get_maxobj_per_zspage() which is defined below zs_init().
> >>
> >>     void func_1()
> >>     {
> >>         get_maxobj_per_zspage()
> >>     }
> >>
> >>     void zs_init()
> >>     {
> >>         func_1()
> >>     }
> >>
> >>     static void get_maxobj_per_zspage()
> >>     {
> >>     }
> >>
> >> This will cause compiling issue. So we must add a declaration:
> >>     static void get_maxobj_per_zspage();
> >> before func_1() if we do not put get_maxobj_per_zspage() before func_1().
> >
> > Yes, I suffered from that when I made compaction but was not sure
> > it's it was obviously wrong.
> > Stupid question:
> > What's the problem if we should put function declaration on top of
> > source code?
> 
> There is no problem if we do this. But if we obey to some coding
> style, then it will
> be convenient for the later developers.
> Normally I put the global or important interface function at the
> bottom of the file, and
> the static or helper functions on the top. Because usually global
> functions is the caller, and
> static functions is the callee.
> 
> >
> >>
> >> In addition, puting module_[init|exit] functions at the bottom of the file
> >> conforms to our habit.
> >
> > Normally, we do but without any strong reason, I don't want to rub git-blame
> > by clean up patches.
> 
> Sorry, I did not consider this when I made this patch.:)
> 
> >
> > In summary, I like this patch but don't like to churn git-blame by clean-up
> > patchset without strong reason so I need something I am sure.
> 
> Now, zsmalloc module is active in development. More and more changes
> will be included.
> If we do not clean up, then this file may looks messy.
> 
> Thanks a lot.

Okay, you move my heart

Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
