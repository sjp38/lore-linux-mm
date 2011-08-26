Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 40A9F6B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 08:12:16 -0400 (EDT)
Subject: Re: [PATCH 2/5] writeback: dirty position control
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 26 Aug 2011 14:11:50 +0200
In-Reply-To: <20110826112637.GA17785@localhost>
References: <1314027488.24275.74.camel@twins>
	 <20110823034042.GC7332@localhost> <1314093660.8002.24.camel@twins>
	 <20110823141504.GA15949@localhost> <20110823174757.GC15820@redhat.com>
	 <20110824001257.GA6349@localhost> <1314202378.6925.48.camel@twins>
	 <20110826001846.GA6118@localhost> <1314349469.26922.24.camel@twins>
	 <20110826100428.GA7996@localhost> <20110826112637.GA17785@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1314360710.11049.1.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 2011-08-26 at 19:26 +0800, Wu Fengguang wrote:
> Now I get 3 figures. Test case is: run 1 dd write task for 300s, with
> a "disturber" dd read task during roughly 120-130s.=20

Ah, but ideally the disturber task should run in bursts of 100ms
(<feedback period), otherwise your N is indeed mostly constant.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
