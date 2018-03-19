Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 77CE26B000C
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 06:15:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id z83so2253715wmc.2
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 03:15:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z11sor7197861edh.50.2018.03.19.03.15.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Mar 2018 03:15:08 -0700 (PDT)
Date: Mon, 19 Mar 2018 13:14:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2] mm: Warn on lock_page() from reclaim context.
Message-ID: <20180319101440.6xe5ixd5nn4zrvl2@node.shutemov.name>
References: <1521295866-9670-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180317155437.pcbeigeivn4a23gt@node.shutemov.name>
 <201803181022.IAI30275.JOFOQMtFSHLFOV@I-love.SAKURA.ne.jp>
 <20180319090419.GR23100@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180319090419.GR23100@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On Mon, Mar 19, 2018 at 10:04:19AM +0100, Michal Hocko wrote:
> On Sun 18-03-18 10:22:49, Tetsuo Handa wrote:
> > >From f43b8ca61b76f9a19c13f6bf42b27fad9554afc0 Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Sun, 18 Mar 2018 10:18:01 +0900
> > Subject: [PATCH v2] mm: Warn on lock_page() from reclaim context.
> > 
> > Kirill A. Shutemov noticed that calling lock_page[_killable]() from
> > reclaim context might cause deadlock. In order to help finding such
> > lock_page[_killable]() users (including out of tree users), this patch
> > emits warning messages when CONFIG_PROVE_LOCKING is enabled.
> 
> So how do you ensure that this won't cause false possitives? E.g. do we
> ever allocate while holding the page lock and not having the page on the
> LRU list?

Hm. Do we even have a reason to lock such pages?
Probably we do, but I cannot come up with an example.

-- 
 Kirill A. Shutemov
