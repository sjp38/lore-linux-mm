Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A33118D0039
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 20:08:25 -0500 (EST)
Date: Sat, 22 Jan 2011 02:08:20 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [BUG]thp: BUG at mm/huge_memory.c:1350
Message-ID: <20110122010820.GP9506@random.random>
References: <20110120154935.GA1760@barrios-desktop>
 <20110120161436.GB21494@random.random>
 <AANLkTikHNcD3aOWKJdPtCqdJi9C34iLPxj5-L8=gqBFc@mail.gmail.com>
 <20110121175843.GA1534@barrios-desktop>
 <20110121181442.GK9506@random.random>
 <20110122005901.GA1590@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110122005901.GA1590@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Jan 22, 2011 at 09:59:01AM +0900, Minchan Kim wrote:
> Good news.
> If PSA is enable, it works well until now.

Yeah x86 is not entirely broken, just some .config, and it's not
common code bug (which is the most important thing!). I think it's a
bug in set_pmd_at when paravirt is set and PSA is off. If I'm right 4m
pages with PSA off should also work when disabling paravirt.

I'm just trying to reproduce...

> Thanks for the good and interesting feature :)

:)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
