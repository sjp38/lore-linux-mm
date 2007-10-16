From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] rd: Mark ramdisk buffers heads dirty
References: <200710151028.34407.borntraeger@de.ibm.com>
	<m14pgsknmd.fsf_-_@ebiederm.dsl.xmission.com>
	<m1zlykj8zl.fsf_-_@ebiederm.dsl.xmission.com>
	<200710160956.58061.borntraeger@de.ibm.com>
Date: Tue, 16 Oct 2007 03:22:30 -0600
In-Reply-To: <200710160956.58061.borntraeger@de.ibm.com> (Christian
	Borntraeger's message of "Tue, 16 Oct 2007 09:56:57 +0200")
Message-ID: <m1y7e3h0rt.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Christian Borntraeger <borntraeger@de.ibm.com> writes:

> Am Dienstag, 16. Oktober 2007 schrieb Eric W. Biederman:
>
>> fs/buffer.c |    3 +++
>> 1 files changed, 3 insertions(+), 0 deletions(-)
>>  drivers/block/rd.c |   13 +------------
>>  1 files changed, 1 insertions(+), 12 deletions(-)
>
> Your patches look sane so far. I have applied both patches, and the problem 
> seems gone. I will try to get these patches to our testers.
>
> As long as they dont find new problems:

Sounds good.  Please make certain to test reiserfs as well as ext2+ as
it seems to strain the ramdisk code more aggressively.

> Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>
>
> Nick, Eric. What is the best patch for the stable series? Both patches from
> Eric or mine? I CCed stable, so they know that something is coming.

My gut feel says my patches assuming everything tests out ok, as
they actually fix the problem instead of papering over it, and there
isn't really a size difference.

In addition the change to init_page_buffers is interesting all by
itself.  With that patch we now have the option of running block
devices in mode where we don't bother to cache the buffer heads
which should reduce memory pressure a bit.  Not that an enhancement
like that will show up in stable, but...

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
