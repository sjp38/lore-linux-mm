Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BDDA16B006A
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 16:38:45 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [linux-pm] [RFC][PATCH] PM: Force GFP_NOIO
 =?iso-8859-1?q?during=09suspend/resume?= (was: Re: Memory allocations in
 =?iso-8859-1?q?=2Esuspend=09became_very?= unreliable)
Date: Thu, 21 Jan 2010 22:38:47 +0100
References: <20100120085053.405A.A69D9226@jp.fujitsu.com> <201001212121.50272.rjw@sisk.pl> <4B58BC31.1040406@crca.org.au>
In-Reply-To: <4B58BC31.1040406@crca.org.au>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201001212238.47471.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Nigel Cunningham <ncunningham@crca.org.au>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-pm@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thursday 21 January 2010, Nigel Cunningham wrote:
> Hi.
> 
> Rafael J. Wysocki wrote:
> > On Thursday 21 January 2010, KOSAKI Motohiro wrote:
> >>  - Ask all drivers how much they require memory before starting suspend and
> >>    Make enough free memory at first?
> > 
> > That's equivalent to reworking all drivers to allocate memory before suspend
> > eg. with the help of PM notifiers.  Which IMHO is unrealistic.
> 
> What's unrealistic about it? I can see that it would be a lot of work,
> but unrealistic? To me, at this stage, it sounds like the ideal solution.

First, we'd need to audit the drivers which is quite a task by itself.
Second, we'd need to make changes, preferably test them or find someone with
suitable hardware to do that for us and propagate them upstream.

I don't really think we have the time to do it.

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
