Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id F1CEE6B03B5
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 14:14:23 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l25so8736188qtf.11
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 11:14:23 -0700 (PDT)
Received: from mail-qt0-x235.google.com (mail-qt0-x235.google.com. [2607:f8b0:400d:c0d::235])
        by mx.google.com with ESMTPS id g73si17080488qke.63.2017.04.13.11.14.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 11:14:22 -0700 (PDT)
Received: by mail-qt0-x235.google.com with SMTP id n46so51980529qta.2
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 11:14:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170405184325.GV6035@dhcp22.suse.cz>
References: <CAGDaZ_qvb7QcWr3MaqnYOFeuqBQzTwzzOKwHXOUxa+S256uc=g@mail.gmail.com>
 <20170405125322.GB9146@rapoport-lnx> <CAGDaZ_o745MVD8PDeGhp0-oehUVb8+Zrm4g7uUBBZNTAPODbmQ@mail.gmail.com>
 <20170405184325.GV6035@dhcp22.suse.cz>
From: Raymond Jennings <shentino@gmail.com>
Date: Thu, 13 Apr 2017 11:13:41 -0700
Message-ID: <CAGDaZ_r+HsMnrdW-i2PtZeCUwJnKs9D_DO-fosCo7TexLWDkNw@mail.gmail.com>
Subject: Re: Heavy I/O causing slow interactivity
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>

Would it make a difference if I cited that

My intent on upping the limits so high and pushing the dirty expiry so
far into the future was to *avoid* triggering background writeback.

In fact, dirty memory during one of these tests never actually rose a bunch.

Are you guys suggesting that if dirty memory gets high enough the
writeback turns into an OOM dodger that preempts foreground I/O?

What I was hoping for is for dirty writeback itself to be throttled
and stay out of the way of foreground I/O.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
