Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id BB34F280011
	for <linux-mm@kvack.org>; Sat,  1 Nov 2014 08:30:15 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id rd3so9312992pab.41
        for <linux-mm@kvack.org>; Sat, 01 Nov 2014 05:30:15 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.226])
        by mx.google.com with ESMTP id cw5si11301487pbc.133.2014.11.01.05.30.14
        for <linux-mm@kvack.org>;
        Sat, 01 Nov 2014 05:30:14 -0700 (PDT)
Date: Sat, 1 Nov 2014 08:30:12 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [BUG] mm/page-writeback.c: divide by zero in pos_ratio_polynom
 not fixed
Message-ID: <20141101083012.54d3b59b@gandalf.local.home>
In-Reply-To: <20141101082325.7be0463f@gandalf.local.home>
References: <20141101082325.7be0463f@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On Sat, 1 Nov 2014 08:23:25 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:

> I don't see how d5c9fde3dae75
> could have fixed anything.

I take that back. It fixes the case on 64 bit systems where the
parameter of div_u64() truncates it. But it does nothing to help the
situation on 32 bit systems.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
