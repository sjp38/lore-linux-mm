Message-ID: <3C33B37E.4050604@zytor.com>
Date: Wed, 02 Jan 2002 17:27:26 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: Maximum physical memory on i386 platform
References: <20020102222026.69416.qmail@web12304.mail.yahoo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravi K <kravi26@yahoo.com>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ravi K wrote:

> Hi,
>   The configuration help for HIGHMEM feature on i386
> platform states that 'Linux can use up to 64 Gigabytes
> of physical memory on x86 systems'. I see a problem
> with this:
>  - page structures needed to support 64GB would take
> up 1GB memory (64 bytes per page of size 4k) 


64GB is physical memory, not virtual memory.

	-hpa



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
