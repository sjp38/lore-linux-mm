Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA06174
	for <linux-mm@kvack.org>; Tue, 25 May 1999 17:43:15 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14155.6480.319372.615650@dukat.scot.redhat.com>
Date: Tue, 25 May 1999 22:42:40 +0100 (BST)
Subject: Re: DANGER: DONT apply it. Re: [patch] ext2nolock-2.2.8-A0
In-Reply-To: <Pine.LNX.3.96.990517013337.2953A-100000@devserv.devel.redhat.com>
References: <14142.57697.49520.664805@worf.scot.redhat.com>
	<Pine.LNX.3.96.990517013337.2953A-100000@devserv.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@redhat.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org, "Eric W. Biederman" <ebiederm+eric@ccr.net>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 17 May 1999 01:35:49 -0400 (EDT), Ingo Molnar
<mingo@redhat.com> said:

>> > cool. i'm now working on the writepage stuff, i'll debug your patch (and
>> > maybe extend it to SMP) if that one is stable. 
>> 
>> You know that Eric Beiderman posted a page write patch for recent 2.2s
>> just recently on linux-mm?

> does it make ext2fs work on the page cache exclusively? Could you forward
> that patch to me just in case you have it handy. I have my patch working
> almost, i just have some small instabilities like kernel oopses and casual
> filesystem corruption to sort out ;)

Well, I'm just back from LE and it looks like Eric isn't hanging
around.  Eric, thanks for liaising with Ingo on this, I know he's been
itching to benchmark things with a decent page cache.  Do you know if
these are likely to be accepted for 2.3 soon?

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
