Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id SAA04673
	for <linux-mm@kvack.org>; Sat, 25 Jan 2003 18:16:23 -0800 (PST)
Date: Sat, 25 Jan 2003 18:17:01 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.59-mm5
Message-Id: <20030125181701.312826e5.akpm@digeo.com>
In-Reply-To: <200301252043.09642.tomlins@cam.org>
References: <20030123195044.47c51d39.akpm@digeo.com>
	<200301251534.32447.tomlins@cam.org>
	<20030125143343.2c505c93.akpm@digeo.com>
	<200301252043.09642.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org, green@namesys.com
List-ID: <linux-mm.kvack.org>

Ed Tomlinson <tomlins@cam.org> wrote:
>
> The excessive copy_foo_user times are still there with Oleg (and Chris's) patch
> removed.  Here is what I see doing:
> 
> "apt-get install --reinstall squidguard chastity-list"
> 
> (with file_write from my first message)
>  55091 default_idle                             1377.2750
>  62640 __copy_from_user_ll                      1204.6154
>  33595 __copy_to_user_ll                        646.0577
> 
> (without file_write)
>  40259 __copy_from_user_ll                      774.2115
>  18735 default_idle                             468.3750
>  21524 __copy_to_user_ll                        413.9231 
>    386 system_call                                8.0417
>    428 current_kernel_time                        7.1333

Is this different from 2.5.59 base?

It's beginning to look like copy_foo_user() itself has gone silly.

I don't know what's causing this, Ed.  Could you please dig into it a little
more?  Does it happen with a bare `dd'?  Or is it networking?  etcetera...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
