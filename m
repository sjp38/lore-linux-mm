Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8083E6B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 01:12:17 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a69so220439847pfa.1
        for <linux-mm@kvack.org>; Sun, 12 Jun 2016 22:12:17 -0700 (PDT)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id c9si15632957pax.66.2016.06.12.22.12.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Jun 2016 22:12:16 -0700 (PDT)
Received: by mail-pf0-x231.google.com with SMTP id t190so42301341pfb.3
        for <linux-mm@kvack.org>; Sun, 12 Jun 2016 22:12:16 -0700 (PDT)
Date: Mon, 13 Jun 2016 14:12:14 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: add trace events for zs_compact
Message-ID: <20160613051214.GA491@swordfish>
References: <1465289804-4913-1-git-send-email-opensource.ganesh@gmail.com>
 <20160608001625.GB27258@bbox>
 <CADAEsF_wYQpMP_Hpr2LEnafxteV7aN1kCdAhLWhk13Ed1ueZ+A@mail.gmail.com>
 <20160608051352.GA28155@bbox>
 <CADAEsF_q0qzk2D_cKMCcvHxF7_eY1cQVKrBp0eM_v05jjOjSOA@mail.gmail.com>
 <20160613044237.GC23754@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160613044237.GC23754@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, rostedt@goodmis.org, mingo@redhat.com

Hello,

On (06/13/16 13:42), Minchan Kim wrote:
[..]
> > compacted(total 0) */
> >  2) # 1351.241 us |  }
> > ------
> > => 1351.241 us used
> > 
> > And it seems the overhead of function_graph is bigger than trace event.
> > 
> > bash-3682  [002] ....  1439.180646: zsmalloc_compact_start: pool zram0
> > bash-3682  [002] ....  1439.180659: zsmalloc_compact_end: pool zram0:
> > 0 pages compacted(total 0)
> > => 13 us > 1351.241 us
> 
> You could use set_ftrace_filter to cut out.
> 
> To introduce new event trace to get a elasped time, it's pointless,
> I think.
> 
> It should have more like pool name you mentioned.
> Like saying other thread, It would be better to show
> [pool name, compact size_class,
> the number of object moved, the number of freed page], IMO.

just my 5 cents:

some parts (of the info above) are already available: zram<ID> maps to
pool<ID> name, which maps to a sysfs file name, that can contain the rest.
I'm just trying to understand what kind of optimizations we are talking
about here and how would timings help... compaction can spin on class
lock, for example, if the device in question is busy, etc. etc. on the
other hand we have a per-class info in zsmalloc pool stats output, so
why not extend it instead of introducing a new debugging interface?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
