Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4E6176B01C7
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 02:25:17 -0400 (EDT)
Received: by pva18 with SMTP id 18so290207pva.14
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 23:25:17 -0700 (PDT)
Message-ID: <4C074ACE.9020704@vflare.org>
Date: Thu, 03 Jun 2010 11:55:18 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH V2 0/7] Cleancache (was Transcendent Memory): overview
References: <20100528173510.GA12166%ca-server1.us.oracle.comAANLkTilV-4_QaNq5O0WSplDx1Oq7JvkgVrEiR1rgf1up@mail.gmail.com> <489aa002-6d42-4dd5-bb66-81c665f8cdd1@default> <4C07179F.5080106@vflare.org> <3721BEE2-DF2D-452A-8F01-E690E32C6B33@oracle.com>
In-Reply-To: <3721BEE2-DF2D-452A-8F01-E690E32C6B33@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andreas Dilger <andreas.dilger@oracle.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Minchan Kim <minchan.kim@gmail.com>, chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

On 06/03/2010 10:23 AM, Andreas Dilger wrote:
> On 2010-06-02, at 20:46, Nitin Gupta wrote:
>> On 06/03/2010 04:32 AM, Dan Magenheimer wrote:
>>>> From: Minchan Kim [mailto:minchan.kim@gmail.com]
>>>
>>>>> I am also eagerly awaiting Nitin Gupta's cleancache backend
>>>>> and implementation to do in-kernel page cache compression.
>>>>
>>>> Do Nitin say he will make backend of cleancache for
>>>> page cache compression?
>>>>
>>>> It would be good feature.
>>>> I have a interest, too. :)
>>>
>>> That was Nitin's plan for his GSOC project when we last discussed
>>> this.  Nitin is on the cc list and can comment if this has
>>> changed.
>>
>> Yes, I have just started work on in-kernel page cache compression
>> backend for cleancache :)
> 
> Is there a design doc for this implementation?

Its all on physical paper :)
Anyways, the design is quite simple as it simply has to act on cleancache
callbacks.

> I was thinking it would be quite clever to do compression in, say, 64kB or 128kB chunks in a mapping (to get decent compression) and then write these compressed chunks directly from the page cache to disk in btrfs and/or a revived compressed ext4.
> 

Batching of pages to get good compression ratio seems doable.

However, writing this compressed data (with/without batching) to disk seems
quite difficult. Pages given out to cleancache are not part of pagecache and
the disk might also contain uncompressed version of the same data. There is
also the problem of efficient on-disk structure for storing variable sized
compressed chunks. I'm not sure how we can deal with all these issues.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
