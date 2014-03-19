Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id F3CC16B0162
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 08:04:27 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id 10so5879693lbg.11
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 05:04:26 -0700 (PDT)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id be6si10608246lbc.186.2014.03.19.05.04.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Mar 2014 05:04:26 -0700 (PDT)
Received: by mail-la0-f54.google.com with SMTP id mc6so5869127lab.13
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 05:04:25 -0700 (PDT)
Date: Wed, 19 Mar 2014 16:04:24 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: bad rss-counter message in 3.14rc5
Message-ID: <20140319120424.GD1728@moon>
References: <20140311053017.GB14329@redhat.com>
 <20140311132024.GC32390@moon>
 <531F0E39.9020100@oracle.com>
 <20140311134158.GD32390@moon>
 <20140311142817.GA26517@redhat.com>
 <20140311143750.GE32390@moon>
 <20140311171045.GA4693@redhat.com>
 <20140311173603.GG32390@moon>
 <20140311173917.GB4693@redhat.com>
 <alpine.LSU.2.11.1403181703470.7055@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1403181703470.7055@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Tue, Mar 18, 2014 at 05:38:38PM -0700, Hugh Dickins wrote:
> 
> (Cyrill, entirely unrelated, but in preparing this patch I noticed
> your soft_dirty work in install_file_pte(): which looked good at
> first, until I realized that it's propagating the soft_dirty of a
> pte it's about to zap completely, to the unrelated entry it's about
> to insert in its place.  Which seems very odd to me.)
> 

Thanks a lot Hugh for pointing! I'll revisit all file-softdirty cases.
(btw, I've grabbed Dave's config to run trinity and somehow help in
 testing and attempt to figure out what causes it but didn't yet
 find hardware node to run, hopefully i'll get a spare machine for
 testing in a couple of days).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
