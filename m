Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id D7F446B009F
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 02:07:54 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id i8so772948qcq.9
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 23:07:54 -0800 (PST)
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [2001:4b98:c:538::195])
        by mx.google.com with ESMTPS id v4si5080qap.7.2014.02.25.23.07.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 23:07:54 -0800 (PST)
Date: Tue, 25 Feb 2014 23:07:45 -0800
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [mmotm:master 326/350] undefined reference to `tty_write_message'
Message-ID: <20140226070745.GA8078@thin>
References: <530d8dd5.N73la/TcxHdsINPu%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <530d8dd5.N73la/TcxHdsINPu%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Wed, Feb 26, 2014 at 02:46:45PM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   a6a1126d3535f0bd8d7c56810061541a4f5595af
> commit: 5837644fad4fdcc7a812eb1f3a215d8196628627 [326/350] kconfig: make allnoconfig disable options behind EMBEDDED and EXPERT
> config: make ARCH=ia64 allnoconfig
> 
> All error/warnings:
> 
>    arch/ia64/kernel/built-in.o: In function `ia64_handle_unaligned':
> >> (.text+0x1b882): undefined reference to `tty_write_message'

Looks like ia64 is broken with CONFIG_TTY=n.  Why in the world does
arch/ia64/kernel/unaligned.c call tty_write_message on the tty of the
current process?  That's just *wrong*.

Would anything go horribly wrong if the tty_write_message just went
away, leaving only the printk?  (Bonus: no need to sprintf first.)

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
