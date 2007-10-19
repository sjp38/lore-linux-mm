From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] rd: Mark ramdisk buffers heads dirty
References: <200710151028.34407.borntraeger@de.ibm.com>
	<200710172348.23113.borntraeger@de.ibm.com>
	<m1myuhcrfu.fsf@ebiederm.dsl.xmission.com>
	<200710181126.10559.borntraeger@de.ibm.com>
Date: Fri, 19 Oct 2007 16:46:04 -0600
In-Reply-To: <200710181126.10559.borntraeger@de.ibm.com> (Christian
	Borntraeger's message of "Thu, 18 Oct 2007 11:26:10 +0200")
Message-ID: <m1sl46en9v.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Christian Borntraeger <borntraeger@de.ibm.com> writes:

> Am Donnerstag, 18. Oktober 2007 schrieb Eric W. Biederman:
>> Grr. Inconsistent rules on a core piece of infrastructure.
>> It looks like that if there is any trivial/minimal fix it
>> is based on your patch suppressing try_to_free_buffers.  Ugh.
>> 
>> Eric
>
> Ok. What do you think about having my patch for 2.6.23 stable, for 2.6.24
> and doing a nicer fix (rd rewrite for example for post 2.6.24)?

Looking at it.  If we don't get carried away using our own private
inode is barely more difficult then stomping on release_page and
in a number of ways a whole lot more subtle.  At least for 2.6.24 I
think it makes a sane fix, and quite possibly as a back port as well.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
