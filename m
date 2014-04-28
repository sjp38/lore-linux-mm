Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 996016B0036
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 19:57:30 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id e53so52651eek.8
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 16:57:29 -0700 (PDT)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id v2si24763591eel.346.2014.04.28.16.57.29
        for <linux-mm@kvack.org>;
        Mon, 28 Apr 2014 16:57:29 -0700 (PDT)
Date: Tue, 29 Apr 2014 01:57:14 +0200
From: Andres Freund <andres@anarazel.de>
Subject: Re: [Lsf] Postgresql performance problems with IO latency,
 especially during fsync()
Message-ID: <20140428235714.GA16070@awork2.anarazel.de>
References: <20140326191113.GF9066@alap3.anarazel.de>
 <20140409092009.GA27519@dastard>
 <20140428234756.GM15995@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140428234756.GM15995@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: rhaas@anarazel.de, linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>

Hi Dave,

On 2014-04-29 09:47:56 +1000, Dave Chinner wrote:
> ping?

I'd replied at http://marc.info/?l=linux-mm&m=139730910307321&w=2

As an additional note:

> On Wed, Apr 09, 2014 at 07:20:09PM +1000, Dave Chinner wrote:
> > I'm not sure how you were generating the behaviour you reported, but
> > the test program as it stands does not appear to be causing any
> > problems at all on the sort of storage I'd expect large databases to
> > be hosted on....

A really really large number of database aren't stored on big enterprise
rigs...

Andres Freund

-- 
 Andres Freund	                   http://www.2ndQuadrant.com/
 PostgreSQL Development, 24x7 Support, Training & Services

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
