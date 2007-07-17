Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id l6H01WVZ019074
	for <linux-mm@kvack.org>; Mon, 16 Jul 2007 17:01:32 -0700
Received: from an-out-0708.google.com (andd11.prod.google.com [10.100.30.11])
	by zps19.corp.google.com with ESMTP id l6H01Vn3008529
	for <linux-mm@kvack.org>; Mon, 16 Jul 2007 17:01:31 -0700
Received: by an-out-0708.google.com with SMTP id d11so391690and
        for <linux-mm@kvack.org>; Mon, 16 Jul 2007 17:01:31 -0700 (PDT)
Message-ID: <b040c32a0707161701q49ad150di6387b029a39b39c3@mail.gmail.com>
Date: Mon, 16 Jul 2007 17:01:31 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [patch] fix periodic superblock dirty inode flushing
In-Reply-To: <b040c32a0707131517m4cc20d3an2123e324746d3e7@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0707112121y21d08438u8ca7f138931827b0@mail.gmail.com>
	 <20070712120519.8a7241dd.akpm@linux-foundation.org>
	 <b040c32a0707131517m4cc20d3an2123e324746d3e7@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/13/07, Ken Chen <kenchen@google.com> wrote:
> On 7/12/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > Was this tested in combination with check_dirty_inode_list.patch,
> > to make sure that the time-orderedness is being retained?
>
> I think I tested with the debug patch.  And just to be sure, I ran the
> test again with the time-order check in place.  It passed the test.

I ran some more tests over the weekend with the debug turned on. There
are a few fall out that the order-ness of sb-s_dirty is corrupted.  We
probably should drop this patch until I figure out a real solution to
this.

One idea is to use rb-tree for sorting and use a in-tree dummy node as
a tree iterator.  Do you think that will work better?  I will hack on
that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
