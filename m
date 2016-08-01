Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 62FFF6B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 15:43:27 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k135so80756804lfb.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 12:43:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bx10si32944398wjb.45.2016.08.01.12.43.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 12:43:26 -0700 (PDT)
Date: Mon, 1 Aug 2016 21:43:23 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM killer changes
Message-ID: <20160801194323.GE31957@dhcp22.suse.cz>
References: <d8f3adcc-3607-1ef6-9ec5-82b2e125eef2@quantum.com>
 <20160801061625.GA11623@dhcp22.suse.cz>
 <b1a39756-a0b5-1900-6575-d6e1f502cb26@Quantum.com>
 <20160801182358.GB31957@dhcp22.suse.cz>
 <30dbabc4-585c-55a5-9f3a-4e243c28356a@Quantum.com>
 <20160801192620.GD31957@dhcp22.suse.cz>
 <939def12-3fa8-e877-ce17-b59db9fa1876@Quantum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <939def12-3fa8-e877-ce17-b59db9fa1876@Quantum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Mon 01-08-16 12:35:51, Ralf-Peter Rohbeck wrote:
> On 01.08.2016 12:26, Michal Hocko wrote:
[...]
> > the amount of dirty pages is much smaller as well as the anonymous
> > memory. The biggest portion seems to be in the page cache. The memory
>
> The page cache will always be full if I'm writing at full steam to multiple
> drives, no?

Yes, the memory full of page cache is not unusual. The large portion of
that memory being dirty/writeback can be a problem. That is why we have
a dirty memory throttling which slows down (throttles) writers to keep
the amount reasonable. What is your dirty throttling setup?
$ grep . /proc/sys/vm/dirty*

and what is your storage setup?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
