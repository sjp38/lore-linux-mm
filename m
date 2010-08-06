Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 84B746007FD
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 03:19:22 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o767JMHS026178
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 00:19:22 -0700
Received: from gwj18 (gwj18.prod.google.com [10.200.10.18])
	by wpaz5.hot.corp.google.com with ESMTP id o767JK73007109
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 00:19:21 -0700
Received: by gwj18 with SMTP id 18so2725572gwj.30
        for <linux-mm@kvack.org>; Fri, 06 Aug 2010 00:19:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTik9AMf1pmsguB843UC9Qq6KxBcWiN_qyeiDPp1O@mail.gmail.com>
References: <1280969004-29530-1-git-send-email-mrubin@google.com>
	<1280969004-29530-3-git-send-email-mrubin@google.com> <20100805132433.d1d7927b.akpm@linux-foundation.org>
	<AANLkTik9AMf1pmsguB843UC9Qq6KxBcWiN_qyeiDPp1O@mail.gmail.com>
From: Michael Rubin <mrubin@google.com>
Date: Fri, 6 Aug 2010 00:19:00 -0700
Message-ID: <AANLkTikFM9J9On85N9k6hKPfUz0w4LxZai6xfsHQz+-D@mail.gmail.com>
Subject: Re: [PATCH 2/2] writeback: Adding pages_dirtied and
	pages_entered_writeback
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, david@fromorbit.com, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Thu, Aug 5, 2010 at 1:24 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> Wait.  These counters appear in /proc/vmstat.  So why create standalone
> /proc/sys/vm files as well?

Andrew I was thinking about this today. And I think there is a case
for keeping the proc files.
Christoph was the one who pointed out to me that is their proper home
and I think he's right. Most if not all the tunables for writeback are
there. When one is trying to find the state of the system's writeback
activity that's the directory. Only having these variables in
/proc/vmstat to me feels like a way to make sure that users who would
need them won't find them unless they are reading source. And these
are folks who aren't reading source.

/proc/vmstat _does_ look like a good place to put the thresholds as it
already has similar values as the thresholds suck as
kswapd_low_wmark_hit_quickly.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
