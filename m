Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A720F6B0088
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 03:38:30 -0500 (EST)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oAN8T4pv032254
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 01:29:04 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id oAN8cOHQ257986
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 01:38:24 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAN8cOH7024848
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 01:38:24 -0700
Subject: Re: Sudden and massive page cache eviction
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20101122161158.02699d10.akpm@linux-foundation.org>
References: <AANLkTikg-sR97tkG=ST9kjZcHe6puYSvMGh-eA3cnH7X@mail.gmail.com>
	 <20101122161158.02699d10.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 23 Nov 2010 00:38:22 -0800
Message-ID: <1290501502.2390.7029.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter =?ISO-8859-1?Q?Sch=FCller?= <scode@spotify.com>, linux-kernel@vger.kernel.org, Mattias de Zalenski <zalenski@spotify.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-11-22 at 16:11 -0800, Andrew Morton wrote:
> > This latest observation we understand may be due to NUMA related
> > allocation issues, and we should probably try to use numactl to ask
> > for a more even allocation. We have not yet tried this. However, it
> is not clear how any issues having to do with that would cause sudden
> > eviction of data already *in* the page cache (on whichever node). 

You don't have anybody messing with /proc/sys/vm/drop_caches, do you?

That can cause massive, otherwise unprovoked page cache eviction.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
