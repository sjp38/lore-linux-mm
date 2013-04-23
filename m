Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 568E66B0034
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 08:02:49 -0400 (EDT)
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id r3NC2hww009419
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 14:02:44 +0200
Message-ID: <5176785D.5030707@fastmail.fm>
Date: Tue, 23 Apr 2013 14:02:37 +0200
From: Bernd Schubert <bernd.schubert@fastmail.fm>
MIME-Version: 1.0
Subject: Re: page eviction from the buddy cache
References: <51504A40.6020604@ya.ru> <20130327150743.GC14900@thunk.org> <alpine.LNX.2.00.1303271135420.29687@eggly.anvils> <3C8EEEF8-C1EB-4E3D-8DE6-198AB1BEA8C0@gmail.com> <515CD665.9000300@gmail.com> <239AD30A-2A31-4346-A4C7-8A6EB8247990@gmail.com> <51730619.3030204@fastmail.fm> <20130420235718.GA28789@thunk.org>
In-Reply-To: <20130420235718.GA28789@thunk.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Will Huck <will.huckk@gmail.com>, Hugh Dickins <hughd@google.com>, Andrew Perepechko <anserper@ya.ru>, linux-ext4@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de

On 04/21/2013 01:57 AM, Theodore Ts'o wrote:
> On Sat, Apr 20, 2013 at 11:18:17PM +0200, Bernd Schubert wrote:
>> Alex, Andrew,
>>
>> did you notice the patch Ted just sent?
>> ("ext4: mark all metadata I/O with REQ_META")
>
> This patch was sent to fix another issue that was brought up at Linux
> Storage, Filesystem, and MM workshop.  I did bring up this issue with
> Mel Gorman while at LSF/MM, and as a result, tThe mm folks are going
> to look into making mark_page_accessed() do the right thing, or

Yeah, I know that REQ_META is a hint/flag for the IO scheduler.

> perhaps provide us with new interface.  The problem with forcing the
> page to be marked as activated is this would cause a TLB flush, which
> would be pointless since this these buddy bitmap pages aren't actually
> mapped in anywhere.

I just thought we can (mis)use that flag and and add another information 
to the page that it holds meta data. The mm system then could use that 
flag and evict those pages with a lower priority  compared to other pages.
I'm curious about outcome of the mm folks. Please let me know if there 
is anything I can help with.


Thanks,
Bernd




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
