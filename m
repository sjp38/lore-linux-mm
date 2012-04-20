Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 63C3B6B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 10:59:04 -0400 (EDT)
Date: Fri, 20 Apr 2012 10:58:56 -0400
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [PATCH, RFC 0/3] Introduce new O_HOT and O_COLD flags
Message-ID: <20120420145856.GC24486@thunk.org>
References: <1334863211-19504-1-git-send-email-tytso@mit.edu>
 <4F912880.70708@panasas.com>
 <alpine.LFD.2.00.1204201120060.27750@dhcp-27-109.brq.redhat.com>
 <1334919662.5879.23.camel@dabdike>
 <alpine.LFD.2.00.1204201313231.27750@dhcp-27-109.brq.redhat.com>
 <1334932928.13001.11.camel@dabdike>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1334932928.13001.11.camel@dabdike>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Lukas Czerner <lczerner@redhat.com>, Boaz Harrosh <bharrosh@panasas.com>, linux-fsdevel@vger.kernel.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-mm@kvack.org

On Fri, Apr 20, 2012 at 06:42:08PM +0400, James Bottomley wrote:
> 
> I'm not at all wedded to O_HOT and O_COLD; I think if we establish a
> hint hierarchy file->page cache->device then we should, of course,
> choose the best API and naming scheme for file->page cache.  The only
> real point I was making is that we should tie in the page cache, and
> currently it only knows about "hot" and "cold" pages.

The problem is that "hot" and "cold" will have different meanings from
the perspective of the file system versus the page cache.  The file
system may consider a file "hot" if it is accessed frequently ---
compared to the other 2 TB of data on that HDD.  The memory subsystem
will consider a page "hot" compared to what has been recently accessed
in the 8GB of memory that you might have your system.  Now consider
that you might have a dozen or so 2TB disks that each have their "hot"
areas, and it's not at all obvious that just because a file, or even
part of a file is marked "hot", that it deserves to be in memory at
any particular point in time.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
