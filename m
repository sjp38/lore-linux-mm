Message-ID: <3BCDC61E.C1AD98CB@mvista.com>
Date: Wed, 17 Oct 2001 10:55:42 -0700
From: Scott Anderson <scott_anderson@mvista.com>
MIME-Version: 1.0
Subject: Re: starting address of a kernel module
References: <20011017080453.34334.qmail@web12001.mail.yahoo.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: anumula venkat <anumulavenkat@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

anumula venkat wrote:
>    I want to know how to get starting address of a
> kernel module. For example if we an executable file by
> reading header of that file we can get starting
> address of that prog in memory. But it is difficult to
> find starting address of a module by examining the
> header as it will be a relocatable file. Is there any
> way of getting it ?

Perhaps "insmod -m foo.o" is what you are looking for...

    Scott Anderson
    scott_anderson@mvista.com   MontaVista Software Inc.
    (408)328-9214               1237 East Arques Ave.
    http://www.mvista.com       Sunnyvale, CA  94085
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
