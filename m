Message-ID: <3BCD3E9D.8050501@zytor.com>
Date: Wed, 17 Oct 2001 01:17:33 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: starting address of a kernel module
References: <20011017080453.34334.qmail@web12001.mail.yahoo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: anumula venkat <anumulavenkat@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

anumula venkat wrote:

> Hi Friends,
> 
>    I want to know how to get starting address of a
> kernel module. For example if we an executable file by
> reading header of that file we can get starting
> address of that prog in memory. But it is difficult to
> find starting address of a module by examining the
> header as it will be a relocatable file. Is there any
> way of getting it ? 
> 


/proc/ksyms, or hack insmod.

A module doesn't have an address until it has been installed.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
