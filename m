Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 512F38D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 07:47:20 -0400 (EDT)
Received: by ewy9 with SMTP id 9so278109ewy.14
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 04:47:17 -0700 (PDT)
Subject: Re: [PATCH 0/1] mm: make read-only accessors take const pointer
 parameters
From: Artem Bityutskiy <dedekind1@gmail.com>
Reply-To: dedekind1@gmail.com
In-Reply-To: <op.vt8hr5j73l0zgt@mnazarewicz-glaptop>
References: <1302861377-8048-1-git-send-email-ext-phil.2.carmody@nokia.com>
	 <20110415145133.GO15707@random.random>
	 <20110415155916.GD7112@esdhcp04044.research.nokia.com>
	 <20110415160957.GV15707@random.random> <1303291717.2700.20.camel@localhost>
	 <op.vt8hr5j73l0zgt@mnazarewicz-glaptop>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Apr 2011 14:44:25 +0300
Message-ID: <1303299865.2700.25.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Phil Carmody <ext-phil.2.carmody@nokia.com>, akpm@linux-foundation.org, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2011-04-20 at 13:20 +0200, Michal Nazarewicz wrote:
> On Wed, 20 Apr 2011 11:28:37 +0200, Artem Bityutskiy <dedekind1@gmail.com>  
> wrote:
> > I think it is good when small core functions like this are strict and
> > use 'const' whenever possible, even though 'const' is so imperfect in C.
> >
> > Let me give an example from my own experience. I was writing code which
> > was using the kernel RB trees, and I was trying to be strict and use
> > 'const' whenever possible. But because the core functions like 'rb_next'
> > do not have 'const' modifier, I could not use const in many many places
> > of my code, because gcc was yelling. And I was not very enthusiastic to
> > touch the RB-tree code that time.
> 
> The problem is that you end up with two sets of functions (one taking const
> another taking non-const), a bunch of macros or a function that takes const
> but returns non-const.  If we settle on anything I would probably vote for
> the last option but the all are far from ideal.

I think it is fine to take const and return non-const. Yes, it is not
beautiful, but we could live with this.

-- 
Best Regards,
Artem Bityutskiy (D?N?N?N?D 1/4  D?D,N?N?N?DoD,D1)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
