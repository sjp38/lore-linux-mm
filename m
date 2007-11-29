Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id lAT6wnR3024963
	for <linux-mm@kvack.org>; Wed, 28 Nov 2007 22:58:49 -0800
Received: from py-out-1112.google.com (pyia25.prod.google.com [10.34.253.25])
	by zps75.corp.google.com with ESMTP id lAT6wm6G030981
	for <linux-mm@kvack.org>; Wed, 28 Nov 2007 22:58:48 -0800
Received: by py-out-1112.google.com with SMTP id a25so3940940pyi
        for <linux-mm@kvack.org>; Wed, 28 Nov 2007 22:58:48 -0800 (PST)
Message-ID: <532480950711282258w14fcd5adh497e19463bf51081@mail.gmail.com>
Date: Wed, 28 Nov 2007 22:58:48 -0800
From: "Michael Rubin" <mrubin@google.com>
Subject: Re: [patch 1/1] Writeback fix for concurrent large and small file writes
In-Reply-To: <E1IxYuL-0001tu-8f@faramir.fjphome.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071128192957.511EAB8310@localhost>
	 <E1IxYuL-0001tu-8f@faramir.fjphome.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Frans Pop <elendil@planet.nl>
Cc: a.p.zijlstra@chello.nl, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

Thank you. Integrated the fixes in my patch.

On Nov 28, 2007 6:13 PM, Frans Pop <elendil@planet.nl> wrote:
> Two typos in comments.
>
> Cheers,
> FJP
>
> Michael Rubin wrote:
> > + * The flush tree organizes the dirtied_when keys with the rb_tree. Any
> > + * inodes with a duplicate dirtied_when value are link listed together.
> > This + * link list is sorted by the inode's i_flushed_when. When both the
> > + * dirited_when and the i_flushed_when are indentical the order in the
> > + * linked list determines the order we flush the inodes.
>
> s/dirited_when/dirtied_when/
>
> > + * Here is where we interate to find the next inode to process. The
> > + * strategy is to first look for any other inodes with the same
> > dirtied_when + * value. If we have already processed that node then we
> > need to find + * the next highest dirtied_when value in the tree.
>
> s/interate/iterate/
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
