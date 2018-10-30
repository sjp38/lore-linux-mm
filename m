Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CCBEA6B0288
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 09:44:36 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c2-v6so7289466edi.6
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 06:44:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v1-v6si2012428eda.269.2018.10.30.06.44.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 06:44:35 -0700 (PDT)
Date: Tue, 30 Oct 2018 14:44:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory hotplug vmem pages
Message-ID: <20181030134433.GE32673@dhcp22.suse.cz>
References: <17182cdc-cffe-ca39-f5c0-d1c5bd7ec4cb@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <17182cdc-cffe-ca39-f5c0-d1c5bd7ec4cb@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zaslonko Mikhail <zaslonko@linux.ibm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

[Sorry for late response]

On Fri 12-10-18 10:15:26, Zaslonko Mikhail wrote:
> Hello Michal,
> 
> I've read a recent discussion about introducing the memory types for memory
> hotplug:
> https://marc.info/?t=153814716600004&r=1&w=2
> 
> In particular I was interested in the idea of moving vmem struct pages to
> the hotplugable memory itself. I'm also looking into it for s390 right now.
> So, in one of your replies you mentioned that you "have proposed (but
> haven't finished this due to other stuff) a solution for this". Have you
> covered any part of that solution yet? Could you please point me to any
> relevant discussions on this matter?

the patchset has been posted here [1]. I didn't get around to fix the
hotremove case when you have to be extra carefule to not remove pfn
range that backs struct pages still in use. I didn't have problems for
small systems but 2GB memblocks just crashed.

[1] http://lkml.kernel.org/r/20170801124111.28881-1-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs
