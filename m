From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] /proc/pid/maps doesn't match "ipcs -m" shmid
References: <1181146045.9503.67.camel@dyn9047017100.beaverton.ibm.com>
	<m1sl95t3r4.fsf@ebiederm.dsl.xmission.com>
	<1181151475.9503.77.camel@dyn9047017100.beaverton.ibm.com>
Date: Wed, 06 Jun 2007 12:24:11 -0600
In-Reply-To: <1181151475.9503.77.camel@dyn9047017100.beaverton.ibm.com>
	(Badari Pulavarty's message of "Wed, 06 Jun 2007 10:37:55 -0700")
Message-ID: <m18xaxszzo.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Badari Pulavarty <pbadari@us.ibm.com> writes:
>
> ------ Shared Memory Segments --------
> key        shmid      owner      perms      bytes      nattch     status
> 0x00000000 884737     db2inst1  767        33554432   13
> 0x00000000 950275     db2fenc1  701        23052288   13
>
> There is no unique way to identify them easily :(
>
> I guess, like you suggested, we can change the dentry name to use shmid
> instead of the portions of the "key" to make it unique. I think, I can 
> work out a patch for this.

Thanks.  That should be more robust.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
