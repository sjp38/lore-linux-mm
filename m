Received: from alogconduit1ah.ccr.net (root@alogconduit1ak.ccr.net [208.130.159.11])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA06462
	for <linux-mm@kvack.org>; Sun, 30 May 1999 13:41:39 -0400
Subject: Re: [PATCHES]
References: <Pine.LNX.3.96.990523171206.21583A-100000@chiara.csoma.elte.hu> 	<m1emk7skik.fsf@flinx.ccr.net> <14156.58667.141026.238904@dukat.scot.redhat.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 30 May 1999 12:01:23 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of "Thu, 27 May 1999 07:24:43 +0100 (BST)"
Message-ID: <m17lpq4hlo.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:

ST> Hi,
ST> On 23 May 1999 13:34:11 -0500, ebiederm+eric@ccr.net (Eric W. Biederman) said:

>> My work on dirty pages sets up a bdflush like mechanism on top of the page
>> cache.  So for anything that can fit in the page cache the buffer cache
>> simply isn't needed.   Where the data goes when it is written simply doesn't
>> matter.

ST> One good reason for using buffers aliased into the page cache is
ST> precisely to avoid a new bdflush mechanism.  We have had enough deadlock
ST> and resource starvation issues with one bdflush that I get nervous about
ST> adding another one!

I agree, multiple bdflushes are a problem.   But this is precisely the
reason why we put bdflush into the page cache.

The buffer cache is not general purpose.

It has a maximum buffer size of 4k,  and doesn't even attempt to work for
non block based filesystems.

We need something in the page cache that can be used by everyone, otherwise
we will eventually have coda-bdflush, smbfs-bdflush, nfs-bdflush, ....
And all of an inferior quality because they don't share code.

Also using the current bdflush we can't implement allocate on write.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
