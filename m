Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E37E46B039F
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 07:25:19 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z109so28066915wrb.1
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 04:25:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z50si24084319wrz.218.2017.04.04.04.25.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 04:25:18 -0700 (PDT)
Date: Tue, 4 Apr 2017 13:25:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Heavy I/O causing slow interactivity
Message-ID: <20170404112514.GB15490@dhcp22.suse.cz>
References: <CAGDaZ_qvb7QcWr3MaqnYOFeuqBQzTwzzOKwHXOUxa+S256uc=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGDaZ_qvb7QcWr3MaqnYOFeuqBQzTwzzOKwHXOUxa+S256uc=g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raymond Jennings <shentino@gmail.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>

On Mon 03-04-17 10:39:39, Raymond Jennings wrote:
> I'm running gentoo and it's emerging llvm.  This I/O heavy process is
> causing slowdowns when I attempt interactive stuff, including watching
> a youtube video and accessing a chatroom.
> 
> Similar latency is induced during a heavy database application.
> 
> As an end user is there anything I can do to better support
> interactive performance?
> 
> And as a potential kernel developer, is there anything I could tweak
> in the kernel source to mitigate this behavior?

How much memory do you have? What is your /proc/sys/vm/dirty_* setting?
What kind of storage do you use?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
