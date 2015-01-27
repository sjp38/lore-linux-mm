Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB546B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 06:03:37 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id k14so14030257wgh.10
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 03:03:37 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bt4si25333796wib.2.2015.01.27.03.03.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 Jan 2015 03:03:36 -0800 (PST)
Message-ID: <54C77086.7090505@suse.cz>
Date: Tue, 27 Jan 2015 12:03:34 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: OOM at low page cache?
References: <54C2C89C.8080002@gmail.com>
In-Reply-To: <54C2C89C.8080002@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Moser <john.r.moser@gmail.com>
Cc: linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

CC linux-mm in case somebody has a good answer but missed this in lkml traffic

On 01/23/2015 11:18 PM, John Moser wrote:
> Why is there no tunable to OOM at low page cache?
> 
> I have no swap configured.  I have 16GB RAM.  If Chrome or Gimp or some
> other stupid program goes off the deep end and eats up my RAM, I hit
> some 15.5GB or 15.75GB usage and stay there for about 40 minutes.  Every
> time the program tries to do something to eat more RAM, it cranks disk
> hard; the disk starts thrashing, the mouse pointer stops moving, and
> nothing goes on.  It's like swapping like crazy, except you're reading
> library files instead of paged anonymous RAM.
> 
> If only I could tell the system to OOM kill at 512MB or 1GB or 95%
> non-evictable RAM, it would recover on its own.  As-is, I need to wait
> or trigger the OOM killer by sysrq.
> 
> Am I just the only person in the world who's ever had that problem?  Or
> is it a matter of questions fast popping up when you try to do this
> *and* enable paging to disk?  (In my experience, that's a matter of too
> much swap space:  if you have 16GB RAM and your computer dies at 15.25GB
> usage, your swap space should be no larger than 750MB plus inactive
> working RAM; obviously, your computer can't handle paging 750MB back and
> forth.  If you make it 8GB wide and you start swap thrashing at 2GB
> usage, you have too much swap available).
> 
> I guess you could try to detect excessive swap and page cache thrashing,
> but that's complex; if anyone really wanted to do that, it would be done
> by now.  A low-barrier OOM is much simpler.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
