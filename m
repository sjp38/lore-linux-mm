Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id m0GItTWT023101
	for <linux-mm@kvack.org>; Wed, 16 Jan 2008 10:55:29 -0800
Received: from py-out-1112.google.com (pybp76.prod.google.com [10.34.92.76])
	by zps78.corp.google.com with ESMTP id m0GIsUxK014640
	for <linux-mm@kvack.org>; Wed, 16 Jan 2008 10:55:28 -0800
Received: by py-out-1112.google.com with SMTP id p76so647243pyb.2
        for <linux-mm@kvack.org>; Wed, 16 Jan 2008 10:55:28 -0800 (PST)
Message-ID: <532480950801161055u4191ef1ak644dd4528ab60f8@mail.gmail.com>
Date: Wed, 16 Jan 2008 10:55:28 -0800
From: "Michael Rubin" <mrubin@google.com>
Subject: Re: [patch] Converting writeback linked lists to a tree based data structure
In-Reply-To: <400452490.28636@ustc.edu.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080115080921.70E3810653@localhost>
	 <1200386774.15103.20.camel@twins>
	 <532480950801150953g5a25f041ge1ad4eeb1b9bc04b@mail.gmail.com>
	 <400452490.28636@ustc.edu.cn>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fengguang Wu <wfg@mail.ustc.edu.cn>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Jan 15, 2008 7:01 PM, Fengguang Wu <wfg@mail.ustc.edu.cn> wrote:
> Basically I think rbtree is an overkill to do time based ordering.
> Sorry, Michael. But s_dirty would be enough for that. Plus, s_more_io
> provides fair queuing between small/large files, and s_more_io_wait
> provides waiting mechanism for blocked inodes.

I think the flush_tree (which is a little more than just an rbtree)
provides the same queuing mechanisms that the three or four lists
heads do and manages to do it in one structure. The i_flushed_when
provides the ability to have blocked inodes wait their turn so to
speak.

Another motivation behind the rbtree patch is to unify the data
structure that handles the priority and mechanism of how we write out
the pages of the inodes. There are some ideas about introducing
priority schemes for QOS and such in the future. I am not saying this
patch is about making that happen, but the idea is to if possible
unify the four stages of lists into a single structure to facilitate
efforts like that.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
