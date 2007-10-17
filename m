From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] rd: Mark ramdisk buffers heads dirty
References: <200710151028.34407.borntraeger@de.ibm.com>
	<200710171814.01717.borntraeger@de.ibm.com>
	<m1sl49ei8x.fsf@ebiederm.dsl.xmission.com>
	<200710172348.23113.borntraeger@de.ibm.com>
Date: Wed, 17 Oct 2007 16:22:13 -0600
In-Reply-To: <200710172348.23113.borntraeger@de.ibm.com> (Christian
	Borntraeger's message of "Wed, 17 Oct 2007 23:48:23 +0200")
Message-ID: <m1myuhcrfu.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Christian Borntraeger <borntraeger@de.ibm.com> writes:

> Am Mittwoch, 17. Oktober 2007 schrieb Eric W. Biederman:
>> Did you have both of my changes applied?
>> To init_page_buffer() and to the ramdisk_set_dirty_page?
>
> Yes, I removed my patch and applied both patches from you. 

Thanks.

Grr. Inconsistent rules on a core piece of infrastructure.
It looks like that if there is any trivial/minimal fix it
is based on your patch suppressing try_to_free_buffers.  Ugh.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
