Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 18FE56B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 12:32:20 -0500 (EST)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oAOHKn0t005869
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 10:20:49 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id oAOHWCNS254040
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 10:32:12 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAOHWBJ0007637
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 10:32:11 -0700
Subject: Re: Sudden and massive page cache eviction
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <AANLkTi=mgTHPEYFsryDYnxPa78f-Nr+H7i4+0KPZbxh3@mail.gmail.com>
References: <AANLkTikg-sR97tkG=ST9kjZcHe6puYSvMGh-eA3cnH7X@mail.gmail.com>
	 <20101122161158.02699d10.akpm@linux-foundation.org>
	 <1290501502.2390.7029.camel@nimitz>
	 <AANLkTik2Fn-ynUap2fPcRxRdKA=5ZRYG0LJTmqf80y+q@mail.gmail.com>
	 <1290529171.2390.7994.camel@nimitz>
	 <AANLkTikCn-YvORocXSJ1Z+ovYNMhKF7TaX=BHWKwrQup@mail.gmail.com>
	 <AANLkTi=mgTHPEYFsryDYnxPa78f-Nr+H7i4+0KPZbxh3@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Wed, 24 Nov 2010 09:32:09 -0800
Message-ID: <1290619929.10586.6.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Peter =?ISO-8859-1?Q?Sch=FCller?= <scode@spotify.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mattias de Zalenski <zalenski@spotify.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-24 at 15:14 +0100, Peter Schuller wrote:
> >> Do you have any large page (hugetlbfs) or other multi-order (> 1 page)
> >> allocations happening in the kernel?
> 
> I forgot to address the second part of this question: How would I best
> inspect whether the kernel is doing that? 

I found out yesterday how to do it with tracing, but it's not a horribly
simple thing to do in any case.  You can watch the entries in slabinfo
and see if any of the ones with sizes over 4096 bytes are getting used
often.  You can also watch /proc/buddyinfo and see how often columns
other than the first couple are moving around.

Jumbo ethernet frames would be the most common reason to see these
allocations.  It's _probably_ not an issue in your case.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
