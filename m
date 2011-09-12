Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A4B0A6B024F
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 06:22:54 -0400 (EDT)
Subject: Re: [PATCH 13/18] writeback: limit max dirty pause time
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 12 Sep 2011 12:22:31 +0200
In-Reply-To: <20110907023505.GB13755@localhost>
References: <20110904015305.367445271@intel.com>
	 <20110904020916.329482509@intel.com> <1315320726.14232.11.camel@twins>
	 <20110907023505.GB13755@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1315822951.26517.25.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 2011-09-07 at 10:35 +0800, Wu Fengguang wrote:
> So yeah, the HZ value does impact the minimal available sleep time...

There's always schedule_hrtimeout() and we could trivially add a
io_schedule_hrtimeout() variant if you need it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
