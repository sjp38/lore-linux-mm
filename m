Message-ID: <39D844E0.A8B4203E@norran.net>
Date: Mon, 02 Oct 2000 10:18:40 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: [PATCH] fix for VM  test9-pre7
References: <Pine.LNX.4.21.0010020038090.30717-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi

Sadly I got a lockup first time when trying to write
this email :-(
So some kind of lockups remain...

Rik van Riel wrote:
> 
> Hi,
> 
> The attached patch seems to fix all the reported deadlock
> problems with the new VM. Basically they could be grouped
> into 2 categories:
> 
> 1) __GFP_IO related locking issues
> 2) something sleeps on a free/clean/inactive page goal
>    that isn't worked towards

Trying mmapp002 it gets killed due to no free
memory left...

This was on a 96MB RAM, 180MHz PPro, IDE disks

Riel, have you tested to run with little memory or
      limit your memory size? Or rather what system do
      you test in.

/RogerL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
