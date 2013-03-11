Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id F41BD6B0005
	for <linux-mm@kvack.org>; Mon, 11 Mar 2013 08:40:50 -0400 (EDT)
Message-ID: <513DD0BD.8000400@symas.com>
Date: Mon, 11 Mar 2013 05:40:29 -0700
From: Howard Chu <hyc@symas.com>
MIME-Version: 1.0
Subject: Re: mmap vs fs cache
References: <5136320E.8030109@symas.com> <20130307154312.GG6723@quack.suse.cz> <20130308020854.GC23767@cmpxchg.org> <5139975F.9070509@symas.com> <20130308084246.GA4411@shutemov.name> <5139B214.3040303@symas.com> <5139FA13.8090305@genband.com> <5139FD27.1030208@symas.com> <20130308161643.GE23767@cmpxchg.org> <513A445E.9070806@symas.com> <20130311120427.GC29799@quack.suse.cz>
In-Reply-To: <20130311120427.GC29799@quack.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Friesen <chris.friesen@genband.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Jan Kara wrote:
> On Fri 08-03-13 12:04:46, Howard Chu wrote:
>> The test clearly is accessing only 30GB of data. Once slapd reaches
>> this process size, the test can be stopped and restarted any number
>> of times, run for any number of hours continuously, and memory use
>> on the system is unchanged, and no pageins occur.
>    Interesting. It might be worth trying what happens if you do
> madvise(..., MADV_DONTNEED) on the data file instead of dropping caches
> with /proc/sys/vm/drop_caches. That way we can establish whether the extra
> cached data is in the data file (things will look the same way as with
> drop_caches) or somewhere else (there will be still unmapped page cache).

I screwed up. My madvise(RANDOM) call used the wrong address/len so it didn't 
cover the whole region. After fixing this, the test now runs as expected - the 
slapd process size grows to 30GB without any problem. Sorry for the noise.

-- 
   -- Howard Chu
   CTO, Symas Corp.           http://www.symas.com
   Director, Highland Sun     http://highlandsun.com/hyc/
   Chief Architect, OpenLDAP  http://www.openldap.org/project/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
