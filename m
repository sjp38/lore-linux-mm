Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 86C596B005C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 16:55:44 -0500 (EST)
Subject: Re: [PATCH RFC] Lost wakeups from lock_page_killable()
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <1231964632.8269.47.camel@think.oraclecorp.com>
References: <1231964632.8269.47.camel@think.oraclecorp.com>
Content-Type: text/plain
Date: Wed, 14 Jan 2009 16:55:31 -0500
Message-Id: <1231970131.8269.52.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Matthew Wilcox <matthew@wil.cx>, "chuck.lever" <chuck.lever@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-01-14 at 15:23 -0500, Chris Mason wrote:

> The patch below is entirely untested but may do a better job of
> explaining what I think the bug is.  I'm hoping I can trigger it locally
> with a few dd commands mixed with a lot of kill commands.
> 

I've tried many variations but haven't hit it locally yet.  Hopefully
testers at oracle can confirm the patch fixes things for them, but the
runs take about a day.

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
