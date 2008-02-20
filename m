Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id m1K6PatT007126
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 22:25:36 -0800
Received: from py-out-1112.google.com (pyhn39.prod.google.com [10.34.240.39])
	by zps37.corp.google.com with ESMTP id m1K6PZGs002310
	for <linux-mm@kvack.org>; Tue, 19 Feb 2008 22:25:35 -0800
Received: by py-out-1112.google.com with SMTP id n39so2595336pyh.31
        for <linux-mm@kvack.org>; Tue, 19 Feb 2008 22:25:35 -0800 (PST)
Message-ID: <6599ad830802192225t5eb31cb5q9fca5b6ef2e03d71@mail.gmail.com>
Date: Tue, 19 Feb 2008 22:25:34 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 0/2] cgroup map files: Add a key/value map file type to cgroups
In-Reply-To: <20080220061444.D65BD1E3C11@siro.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <6599ad830802192202t19c1f597jb7927e975eb80aa6@mail.gmail.com>
	 <20080220061444.D65BD1E3C11@siro.lan>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, balbir@in.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Feb 19, 2008 10:14 PM, YAMAMOTO Takashi <yamamoto@valinux.co.jp> wrote:
> > On Feb 19, 2008 9:48 PM, YAMAMOTO Takashi <yamamoto@valinux.co.jp> wrote:
> > >
> > > it changes the format from "%s %lld" to "%s: %llu", right?
> > > why?
> > >
> >
> > The colon for consistency with maps in /proc. I think it also makes it
> > slightly more readable.
>
> can you be a little more specific?
>
> i object against the colon because i want to use the same parser for
> /proc/vmstat, which doesn't have colons.

Ah. This /proc behaviour of having multiple formats for reporting the
same kind of data (compare with /proc/meminfo, which does use colons)
is the kind of thing that I want to avoid with cgroups. i.e. if two
cgroup subsystems are both reporting the same kind of structured data,
then they should both use the same output format.

I guess since /proc has both styles, and memory.stat is the first file
reporting key/value pairs in cgroups, you get to call the format. OK,
I'll zap the colon.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
