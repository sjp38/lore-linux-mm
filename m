Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA24A6B03A1
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 14:16:26 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d66so5450302qkb.0
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 11:16:26 -0700 (PDT)
Received: from mail-qt0-x235.google.com (mail-qt0-x235.google.com. [2607:f8b0:400d:c0d::235])
        by mx.google.com with ESMTPS id q48si18435353qta.270.2017.04.05.11.16.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 11:16:25 -0700 (PDT)
Received: by mail-qt0-x235.google.com with SMTP id x35so17796944qtc.2
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 11:16:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170405125322.GB9146@rapoport-lnx>
References: <CAGDaZ_qvb7QcWr3MaqnYOFeuqBQzTwzzOKwHXOUxa+S256uc=g@mail.gmail.com>
 <20170405125322.GB9146@rapoport-lnx>
From: Raymond Jennings <shentino@gmail.com>
Date: Wed, 5 Apr 2017 11:15:44 -0700
Message-ID: <CAGDaZ_o745MVD8PDeGhp0-oehUVb8+Zrm4g7uUBBZNTAPODbmQ@mail.gmail.com>
Subject: Re: Heavy I/O causing slow interactivity
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>

I have 32GiB of memory

Storage is an LVM volume group sitting on a pair of 2T western digital
drives, one WD Green, and the other WD Blue

My CPU is an i7, model 4790K.

What I'd like is some way for my system to fairly share the available
I/O bandwidth.  My youtube is sensitive to latency but doesn't chew up
a lot of throughput.  My I/O heavy stuff isn't really urgent and I
don't mind it yielding to the interactive stuff.

I remember a similiar concept being tried awhile ago with a scheduler
that "punished" processes that sucked up too much CPU and made sure
the short sporadic event driven interactive stuff got the scraps of
CPU when it needed them.

/proc/sys/vm/dirty is set up as follows

dirty_ratio 90
dirty_background_ratio 80
dirty_expire_centisecs 30000
dirty_writeback_centisecs 6000

It's gotten bad enough that my IRC client froze long enough to get
pinged off the server it was connected to, which means over 180
seconds of lag.

Since it was triggered by intense disk I/O I figured mm/vm was a good
place to ask for help

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
