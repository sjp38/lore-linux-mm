Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A520D6B0390
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 04:19:51 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u2so2322922wmu.18
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 01:19:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z74si15234349wrb.95.2017.04.17.01.19.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Apr 2017 01:19:50 -0700 (PDT)
Date: Mon, 17 Apr 2017 10:19:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Heavy I/O causing slow interactivity
Message-ID: <20170417081946.GB12511@dhcp22.suse.cz>
References: <CAGDaZ_qvb7QcWr3MaqnYOFeuqBQzTwzzOKwHXOUxa+S256uc=g@mail.gmail.com>
 <20170405125322.GB9146@rapoport-lnx>
 <CAGDaZ_o745MVD8PDeGhp0-oehUVb8+Zrm4g7uUBBZNTAPODbmQ@mail.gmail.com>
 <20170405184325.GV6035@dhcp22.suse.cz>
 <CAGDaZ_r+HsMnrdW-i2PtZeCUwJnKs9D_DO-fosCo7TexLWDkNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGDaZ_r+HsMnrdW-i2PtZeCUwJnKs9D_DO-fosCo7TexLWDkNw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raymond Jennings <shentino@gmail.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>

On Thu 13-04-17 11:13:41, Raymond Jennings wrote:
> Would it make a difference if I cited that
> 
> My intent on upping the limits so high and pushing the dirty expiry so
> far into the future was to *avoid* triggering background writeback.
> 
> In fact, dirty memory during one of these tests never actually rose a bunch.

How have you checked that?

> Are you guys suggesting that if dirty memory gets high enough the
> writeback turns into an OOM dodger that preempts foreground I/O?

Once you exceed the dirty limit, writers starts being throttled on new
writes. If things go especially bad than all writers get throttled
basically and that is where your stalls come from most probably.
 
> What I was hoping for is for dirty writeback itself to be throttled
> and stay out of the way of foreground I/O.

The amount of dirty data would just grow without any bounds if the
writers were not throttled...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
