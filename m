Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id UAA06190
	for <linux-mm@kvack.org>; Sat, 25 Jan 2003 20:04:11 -0800 (PST)
Date: Sat, 25 Jan 2003 20:04:49 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.59-mm5
Message-Id: <20030125200449.22356137.akpm@digeo.com>
In-Reply-To: <200301252251.14860.tomlins@cam.org>
References: <20030123195044.47c51d39.akpm@digeo.com>
	<200301252043.09642.tomlins@cam.org>
	<20030125181701.312826e5.akpm@digeo.com>
	<200301252251.14860.tomlins@cam.org>
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
> and the squidguard processes proceed to take most of the cpu.  Each 
> of the squidguard processes takes about 17% of the cpu.  These keep 
> running after apt finshes and the system time drops when they end...
> 
> ...
>
> Does this help?

Not a lot.  Looks like squidguard has gone berzerk reading lots of stuff from
pagecache.  Could be that it has a bug which is triggered by subtly altered
kernel behaviour, or a subtle bug in the kernel broke it.

Do any other applications exhibit the same behaviour?

Can you generate a simple, standalone usage of squidguard which exhibits this
behaviour?  Just starting them up??

You may need to build your own squidguard and attach gdb to one, see what
it's up to.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
