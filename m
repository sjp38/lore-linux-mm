Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iBH219jd489906
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 21:01:09 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBH219Vt239158
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 19:01:09 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iBH218RL027322
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 19:01:08 -0700
Subject: Re: [patch] [RFC] make WANT_PAGE_VIRTUAL a config option
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.61.0412170150080.793@scrub.home>
References: <E1Cf3bP-0002el-00@kernel.beaverton.ibm.com>
	 <Pine.LNX.4.61.0412170133560.793@scrub.home>
	 <1103244171.13614.2525.camel@localhost>
	 <Pine.LNX.4.61.0412170150080.793@scrub.home>
Content-Type: text/plain
Message-Id: <1103248865.13614.2621.camel@localhost>
Mime-Version: 1.0
Date: Thu, 16 Dec 2004 18:01:05 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, geert@linux-m68k.org, ralf@linux-mips.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-12-16 at 16:51, Roman Zippel wrote:
> Could you explain a bit more, what exactly the problem is?

Maybe I should also say that this doesn't fix any bugs.  It simply makes
the headers easier to work with.  I've been doing a lot of work in those
headers for the memory hotplug effort, and I think that this is a
worthwhile cleanup effort.  Plus, it will make my memory hotplug patches
look a little less crazy :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
