Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2EACE6B0038
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 13:46:49 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f193so99417727wmg.0
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 10:46:49 -0700 (PDT)
Received: from arcturus.aphlor.org (arcturus.ipv6.aphlor.org. [2a03:9800:10:4a::2])
        by mx.google.com with ESMTPS id g136si6555017wme.25.2016.10.04.10.46.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Oct 2016 10:46:48 -0700 (PDT)
Date: Tue, 4 Oct 2016 13:46:45 -0400
From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: page_cache_tree_insert WARN_ON hit on 4.8+
Message-ID: <20161004174645.urwwmvgibabaokjn@codemonkey.org.uk>
References: <20161004170955.n25polpcsotmwcdq@codemonkey.org.uk>
 <20161004173425.GA1223@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161004173425.GA1223@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Oct 04, 2016 at 07:34:25PM +0200, Johannes Weiner wrote:
 > Hi Dave,
 > 
 > On Tue, Oct 04, 2016 at 01:09:55PM -0400, Dave Jones wrote:
 > > Hit this during a trinity run.
 > > Kernel built from v4.8-1558-g21f54ddae449
 > > 
 > > WARNING: CPU: 0 PID: 5670 at ./include/linux/swap.h:276 page_cache_tree_insert+0x198/0x1b0
 > 
 > Thanks for the report.
 > 
 > I've been trying to reproduce this too after Linus got hit by it. Is
 > there any way to trace back the steps what trinity was doing exactly?

That run didn't have logging enabled, so not sure..

 > What kind of file(system) this was operating on,

btrfs

 > file size, what the /proc/vmstat delta before the operation until the trigger looks like?

No idea.

Let me play with some options, see if I can narrow it down.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
