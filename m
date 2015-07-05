Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id B1B4D280291
	for <linux-mm@kvack.org>; Sat,  4 Jul 2015 20:10:56 -0400 (EDT)
Received: by qkeo142 with SMTP id o142so95114750qke.1
        for <linux-mm@kvack.org>; Sat, 04 Jul 2015 17:10:56 -0700 (PDT)
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [2001:4b98:c:538::196])
        by mx.google.com with ESMTPS id w10si15775619qkw.84.2015.07.04.17.10.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 04 Jul 2015 17:10:55 -0700 (PDT)
Date: Sat, 4 Jul 2015 17:10:48 -0700
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: kernel/uid16.c:184:2: error: implicit declaration of function
 'groups_alloc'
Message-ID: <20150705001048.GA3486@x>
References: <201507050734.RcWSMvjj%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201507050734.RcWSMvjj%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Iulia Manda <iulia.manda21@gmail.com>, kbuild-all@01.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sun, Jul 05, 2015 at 07:30:38AM +0800, kbuild test robot wrote:
>    kernel/uid16.c: In function 'SYSC_setgroups16':
> >> kernel/uid16.c:184:2: error: implicit declaration of function 'groups_alloc'
>    kernel/uid16.c:184:13: warning: assignment makes pointer from integer without a cast

The kernel configuration seems to be malformed:
[...]
> CONFIG_OPENRISC=y
[...]
> CONFIG_UID16=y

UID16 is set, but...

> # CONFIG_MULTIUSER is not set

And quoting init/Kconfig:

config UID16
        bool "Enable 16-bit UID system calls" if EXPERT
        depends on HAVE_UID16 && MULTIUSER

That dependency exists precisely because this error would occur if it
didn't.

The only thing I can think of that might not respect that dependency
would be a "select UID16", and I don't see any of those either in the
current tree or in the tree as of that commit.  So I don't see any way
this can have legitimately occurred.  How was this kernel configuration
generated?

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
