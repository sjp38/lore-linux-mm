Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3BD956B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 16:02:10 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so1722699pdj.41
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 13:02:09 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id m8si16864198pbd.374.2014.04.18.13.02.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 13:02:09 -0700 (PDT)
Received: by mail-pa0-f45.google.com with SMTP id kl14so1760292pab.4
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 13:02:08 -0700 (PDT)
Date: Fri, 18 Apr 2014 13:01:01 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/8] mm/swap: prevent concurrent swapon on the same
 S_ISBLK blockdev
In-Reply-To: <CAL1ERfO2u838hnY2NVKVd7Tr_=2o=nVpBf_hTKGHms+QFGTFPQ@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1404181253200.13251@eggly.anvils>
References: <000c01cf1b47$ce280170$6a780450$%yang@samsung.com> <20140203153628.5e186b0e4e81400773faa7ac@linux-foundation.org> <alpine.LSU.2.11.1402032014140.29889@eggly.anvils> <CAL1ERfO2u838hnY2NVKVd7Tr_=2o=nVpBf_hTKGHms+QFGTFPQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Weijie Yang <weijie.yang@samsung.com>, Minchan Kim <minchan@kernel.org>, shli@kernel.org, Bob Liu <bob.liu@oracle.com>, Seth Jennings <sjennings@variantweb.net>, Heesub Shin <heesub.shin@samsung.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, 18 Apr 2014, Weijie Yang wrote:
> On Tue, Feb 4, 2014 at 12:20 PM, Hugh Dickins <hughd@google.com> wrote:
> >>
> >> Truly, I am fed up with silly swapon/swapoff races.  How often does
> >> anyone call these things?  Let's slap a huge lock around the whole
> >> thing and be done with it?
> >
> > That answer makes me sad: we can't be bothered to get it right,
> > even when Weijie goes to the trouble of presenting a series to do so.
> > But I sure don't deserve a vote until I've actually looked through it.
> 
> Hi,
> 
> This is a ping email. Could I get some options about these patch series?

Sorry, this is no more than a pong in return: I've not lost or
forgotten these, I shall get to them, but priorities intervene.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
