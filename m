Date: Sat, 19 Jul 2003 10:39:04 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: Linux free issue
In-Reply-To: <MEHFFGFJPAFEOBAA@mailcity.com>
Message-ID: <Pine.LNX.4.44.0307191037530.26759-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vinay I K <abcxyz1@lycos.com>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 19 Jul 2003, Vinay I K wrote:

> http://mail.nl.linux.org/linux-mm/1998-08/msg00028.html
> 
> I am a bit confused. When we call free in Linux, is the memory not given
> back to the system(just cached)? What is the state of the issue in the
> latest Linux Kernel?

The issue is not in the Linux kernel at all, but in glibc.
It is the C library that has (after careful measuring and
optimising) made the decision to not call the system call
to free memory but instead keep it for later use.

I suspect their decision is the right one in most of the
cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
