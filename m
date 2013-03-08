Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id D2ED86B0006
	for <linux-mm@kvack.org>; Fri,  8 Mar 2013 09:47:53 -0500 (EST)
Message-ID: <5139FA13.8090305@genband.com>
Date: Fri, 08 Mar 2013 08:47:47 -0600
From: Chris Friesen <chris.friesen@genband.com>
MIME-Version: 1.0
Subject: Re: mmap vs fs cache
References: <5136320E.8030109@symas.com> <20130307154312.GG6723@quack.suse.cz> <20130308020854.GC23767@cmpxchg.org> <5139975F.9070509@symas.com> <20130308084246.GA4411@shutemov.name> <5139B214.3040303@symas.com>
In-Reply-To: <5139B214.3040303@symas.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Howard Chu <hyc@symas.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 03/08/2013 03:40 AM, Howard Chu wrote:

> There is no way that a process that is accessing only 30GB of a mmap
> should be able to fill up 32GB of RAM. There's nothing else running on
> the machine, I've killed or suspended everything else in userland
> besides a couple shells running top and vmstat. When I manually
> drop_caches repeatedly, then eventually slapd RSS/SHR grows to 30GB and
> the physical I/O stops.

Is it possible that the kernel is doing some sort of automatic 
readahead, but it ends up reading pages corresponding to data that isn't 
ever queried and so doesn't get mapped by the application?

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
