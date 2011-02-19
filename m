Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BF3938D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 21:29:25 -0500 (EST)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p1J2THvv009526
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 18:29:20 -0800
Received: from yie21 (yie21.prod.google.com [10.243.66.21])
	by wpaz13.hot.corp.google.com with ESMTP id p1J2SkWk020398
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 18:29:17 -0800
Received: by yie21 with SMTP id 21so7204yie.35
        for <linux-mm@kvack.org>; Fri, 18 Feb 2011 18:29:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4D5DDDD7.509@cn.fujitsu.com>
References: <4D5C7EA7.1030409@cn.fujitsu.com> <4D5C7ED1.2070601@cn.fujitsu.com>
 <20110217144643.0d60bef4.akpm@linux-foundation.org> <AANLkTin6TqQMHSpQjNXNrgGAHG8DL6CvzhTm3KHoxv0y@mail.gmail.com>
 <4D5DDDD7.509@cn.fujitsu.com>
From: Paul Menage <menage@google.com>
Date: Fri, 18 Feb 2011 18:28:50 -0800
Message-ID: <AANLkTinDwDbOqfnYQ8b_69iQhPzn7R26wQXPht0NgjAM@mail.gmail.com>
Subject: Re: [PATCH 3/4] cpuset: Fix unchecked calls to NODEMASK_ALLOC()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, =?UTF-8?B?57yqIOWLsA==?= <miaox@cn.fujitsu.com>, linux-mm@kvack.org

On Thu, Feb 17, 2011 at 6:47 PM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>
> I think a defect of this is people might call it twice in one function
> but don't know it returns the same variable?

Hopefully they'd read the comments...

But it's not a big issue either way - having the WARN_ON() statements
in front of each use works OK too, given that there are only a few of
them.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
