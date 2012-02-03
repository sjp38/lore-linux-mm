Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 0792A6B002C
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 19:32:33 -0500 (EST)
MIME-Version: 1.0
Message-ID: <abfed6dd-a194-4feb-b12e-735f9918804d@default>
Date: Thu, 2 Feb 2012 16:32:32 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: Re: [LSF/MM TOPIC][ATTEND] cleancache extension and memory
 checkpoint/restore
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xemul@parallels.com
Cc: linux-mm@kvack.org

Hi Pavel --

> From: Pavel Emelyanov <xemul () parallels ! com>
> 1. cleancache extension

> In containerized systems, when containers are more or less equal to each
> other, we can save RAM and (!) disk IOPS if we share equal files between
> containers. We've been using a unionfs-like approach and faced several=20
> disadvantages of it (I can describe them in details if required).

> Now we're working on extending the cleancache subsystem to achieve this=
=20
> sharing. The cost of fully isolated filesystems is very high, I can provi=
de=20
> numbers of various performance experiments, thus this is required badly f=
or
> containers.

I agree this is a great use of cleancache!

FYI, the Xen implementation of transcendent memory optionally
does deduplication.  I think you are probably doing something
very similar so you may be able to leverage some code.  No changes
to cleancache are needed... you just need to register a different
"backend" (e.g. like zcache or RAMster or the Xen tmem stubs).

IIRC, the Xen implementation is much simpler than KSM because
the candidate pages are more closely managed.

Hopefully we can talk about it at LSF/MM!

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
