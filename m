Received: from alogconduit1ah.ccr.net (ccr@alogconduit1am.ccr.net [208.130.159.13])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA14118
	for <linux-mm@kvack.org>; Mon, 10 May 1999 22:42:26 -0400
Subject: Re: [PATCH] dirty pages in memory & co.
References: <m1pv4ddj3z.fsf@flinx.ccr.net> <14135.13698.659905.454361@dukat.scot.redhat.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 10 May 1999 19:30:00 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of "Mon, 10 May 1999 20:37:38 +0100 (BST)"
Message-ID: <m1hfpke9dj.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:

ST> Hi,
ST> On 07 May 1999 09:56:00 -0500, ebiederm+eric@ccr.net (Eric W. Biederman)
ST> said:

>> It looks like I need 2 variations on generic_file_write at the
>> moment. 
>> 1) for network filesystems that can get away without filling
>> the page on a partial write.
>> 2) for block based filesystems that must fill the page on a
>> partial write because they can't write arbitrary chunks of
>> data.

ST> I'd be very worried by (1): sounds like a partial write followed by a
ST> read of the full page could show up garbage in the page cache if you do
ST> this.  If NFS skips the page clearing for partial writes, how does it
ST> avoid returning garbage later?

Actually (1) is current behaviour.  I really don't like it but I can see
how it can potentially improve performance.  Partial writes are handled
by not setting PG_uptodate.

Reads are handled by always flushing the per page dirty data before reading.

I don't especially like it but it's what we have now.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
