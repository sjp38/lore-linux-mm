Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0B9D860021D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 17:44:42 -0400 (EDT)
From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: [patch] procfs: provide stack information for threads
References: <1238511505.364.61.camel@matrix> <20090401193135.GA12316@elte.hu>
	<1244146873.20012.6.camel@wall-e> <m2eipl7axx.fsf@igel.home>
Date: Fri, 02 Oct 2009 23:44:56 +0200
In-Reply-To: <m2eipl7axx.fsf@igel.home> (Andreas Schwab's message of "Fri, 02
	Oct 2009 23:17:14 +0200")
Message-ID: <m2ws3djwrr.fsf@igel.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Stefani Seibold <stefani@seibold.net>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

That missed compat_do_execve.

Andreas.
