Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id AAA17608
	for <linux-mm@kvack.org>; Sun, 15 Sep 2002 00:01:42 -0700 (PDT)
Message-ID: <3D84340A.25ED4C69@digeo.com>
Date: Sun, 15 Sep 2002 00:17:30 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] add vmalloc stats to meminfo
References: <3D8422BB.5070104@us.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> 
> Some workloads like to eat up a lot of vmalloc space.

Which workloads are those?

>  It is often hard to tell
> whether this is because the area is too small, or just too fragmented.  This
> makes it easy to determine.

I do not recall ever having seen any bug/problem reports which this patch
would have helped to solve.  Could you explain in more detai why is it useful?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
