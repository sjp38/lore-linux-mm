Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id RAA10744
	for <linux-mm@kvack.org>; Fri, 31 Jan 2003 17:45:15 -0800 (PST)
Date: Fri, 31 Jan 2003 17:45:22 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.59-mm7
Message-Id: <20030131174522.25b5f46c.akpm@digeo.com>
In-Reply-To: <200301312018.02020.tomlins@cam.org>
References: <20030131001733.083f72c5.akpm@digeo.com>
	<200301312018.02020.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson <tomlins@cam.org> wrote:
>
> Looks like something got missed...  I get this with mm7
> 
> if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.5.59-mm7; fi
> WARNING: /lib/modules/2.5.59-mm7/kernel/arch/i386/kernel/apm.ko needs unknown symbol xtime_lock
> 

aww, that's not fair.

xtime_lock was _always_ referenced by apm.c, and never exported to modules.

The only reason it ever worked was that apm does not compile for SMP, and
write/read_lock() are no-ops on uniprocessor.

ho hum, thanks, I shall add the export.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
