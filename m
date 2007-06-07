Received: by nz-out-0506.google.com with SMTP id x7so553700nzc
        for <linux-mm@kvack.org>; Thu, 07 Jun 2007 09:43:42 -0700 (PDT)
Message-ID: <787b0d920706070943h6ac65b85nee5b01600905be08@mail.gmail.com>
Date: Thu, 7 Jun 2007 12:43:42 -0400
From: "Albert Cahalan" <acahalan@gmail.com>
Subject: Re: [RFC][PATCH] /proc/pid/maps doesn't match "ipcs -m" shmid
In-Reply-To: <1181233393.9995.14.camel@dyn9047017100.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <787b0d920706062027s5a8fd35q752f8da5d446afc@mail.gmail.com>
	 <20070606204432.b670a7b1.akpm@linux-foundation.org>
	 <787b0d920706062153u7ad64179p1c4f3f663c3882f@mail.gmail.com>
	 <1181233393.9995.14.camel@dyn9047017100.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, ebiederm@xmission.com, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 6/7/07, Badari Pulavarty <pbadari@us.ibm.com> wrote:

> BTW, I agree with Eric that its would be nice to use shmid as part
> of name instead of forcing to be as inode number. It should be
> possible for pmap to workout shmid from "key" or name. Isn't it ?

It is not at all nice.

1. it's incompatible ABI breakage
2. where will you put the key then, in the inode? :-)

Changing to "SYSVID%d" is no good either. Look, people
are ***parsing*** this stuff in /proc. The /proc filesystem
is not some random sandbox to be playing in.

Before you go messing with it, note that the device number
also matters. (it's per-boot dynamic, but that's OK)
That's how one knows that /SYSV00000000 is not just
a regular file; sadly these didn't get a non-/ prefix.
(and no you can't fix that now; it's way too late)

Next time you feel like breaking an ABI, mind putting
"LET'S BREAK AN ABI!" in the subject of your email?

BTW, I suspect this kind of thing also breaks:
a. fuser, lsof, and other resource usage display tools
b. various obscure emulators (similar to valgrind)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
