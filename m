Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C5F0F6B4CF5
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 13:54:14 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id m21-v6so4922458oic.7
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 10:54:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 13-v6si3239073oii.216.2018.08.29.10.54.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 10:54:13 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w7THiPSm130788
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 13:54:12 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2m5ynahggv-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 13:54:12 -0400
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 29 Aug 2018 13:54:11 -0400
Date: Wed, 29 Aug 2018 10:54:05 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] fs/dcache: Make negative dentries easier to be
 reclaimed
Reply-To: paulmck@linux.vnet.ibm.com
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
 <1535476780-5773-3-git-send-email-longman@redhat.com>
 <20180828160150.9a45ee293c92708edb511eab@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180828160150.9a45ee293c92708edb511eab@linux-foundation.org>
Message-Id: <20180829175405.GA17337@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Waiman Long <longman@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On Tue, Aug 28, 2018 at 04:01:50PM -0700, Andrew Morton wrote:
> 
> Another pet peeve ;)
> 
> On Tue, 28 Aug 2018 13:19:40 -0400 Waiman Long <longman@redhat.com> wrote:
> 
> >  /**
> > + * list_lru_add_head: add an element to the lru list's head
> > + * @list_lru: the lru pointer
> > + * @item: the item to be added.
> > + *
> > + * This is similar to list_lru_add(). The only difference is the location
> > + * where the new item will be added. The list_lru_add() function will add
> 
> People often use the term "the foo() function".  I don't know why -
> just say "foo()"!

For whatever it is worth...

I tend to use "The foo() function ..." instead of "foo() ..." in order
to properly capitalize the first word of the sentence.  So I might say
"The call_rcu() function enqueues an RCU callback." rather than something
like "call_rcu() enqueues an RCU callback."  Or I might use some other
trick to keep "call_rcu()" from being the first word of the sentence.
But if the end of the previous sentence introduced call_rcu(), you
usually want the next sentence's first use of "call_rcu()" to be very
early in the sentence, because otherwise the flow will seem choppy.

And no, I have no idea what I would do if I were writing in German,
where nouns are capitalized, given that function names tend to be used
as nouns.  Probably I would get yelled at a lot for capitalizing my
function names.  ;-)

							Thanx, Paul
