Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 51A5E6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 15:20:48 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 30 Jul 2012 13:20:47 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id C893D1FF001A
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 19:19:54 +0000 (WET)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6UJJsAB055488
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 13:19:55 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6UJJhgl022657
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 13:19:44 -0600
Message-ID: <5016DE4E.5050300@linux.vnet.ibm.com>
Date: Mon, 30 Jul 2012 14:19:42 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] promote zcache from staging
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com> <b95aec06-5a10-4f83-bdfd-e7f6adabd9df@default> <20120727205932.GA12650@localhost.localdomain> <d4656ba5-d6d1-4c36-a6c8-f6ecd193b31d@default>
In-Reply-To: <d4656ba5-d6d1-4c36-a6c8-f6ecd193b31d@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

Dan,

I started writing inline responses to each concern but that
was adding more confusion than clarity.  I would like to
focus the discussion.

The purpose of this patchset is to discuss the inclusion of
zcache into mainline during the 3.7 merge window.  zcache
has been a staging since v2.6.39 and has been maturing with
contributions from 15 developers (5 with multiple commits)
working on improvements and bug fixes.

I want good code in the kernel, so if there are particular
areas that need attention before it's of acceptable quality
for mainline we need that discussion.  I am eager to have
customers using memory compression with zcache but before
that I want to see zcache in mainline.

We agree with Konrad that zcache should be promoted before
additional features are included.  Greg has also expressed
that he would like promotion before attempting to add
additional features [1].  Including new features now, while
in the staging tree, adds to the complexity and difficultly
of reverifying zcache and getting it accepted into mainline.

[1] https://lkml.org/lkml/2012/3/16/472

Let's have this discussion.  If there are specific issues
that need to be addressed to get this ready for mainline
let's take them one-by-one and line-by-line with patches.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
