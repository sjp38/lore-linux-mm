Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id JAA19901
	for <linux-mm@kvack.org>; Tue, 18 Feb 2003 09:31:23 -0800 (PST)
Date: Tue, 18 Feb 2003 09:32:33 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.62-mm1
Message-Id: <20030218093233.32dac87c.akpm@digeo.com>
In-Reply-To: <200302180755.07705.tomlins@cam.org>
References: <20030218015844.5320578a.akpm@digeo.com>
	<200302180755.07705.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson <tomlins@cam.org> wrote:
>
> On February 18, 2003 04:58 am, Andrew Morton wrote:
> > -scheduler-tunables.patch
> > -sched-f3.patch
> > -rml-scheduler-bits.patch
> >
> >  Leaky.
> 
> Would you happen to have more details?  I have my thread
> governors patch, now numa aware, ported to -62 with all 
> of the above patches updated...  Do we know which one 
> leaks?
> 

sched-f3.  It has moved an mmdrop() in context_switch() elsewhere,
and it appears that it is now failing to keep the refcounts right.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
