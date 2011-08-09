Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 57B646B016A
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 14:41:51 -0400 (EDT)
Subject: Re: [PATCH 5/5] writeback: IO-less balance_dirty_pages()
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 09 Aug 2011 20:41:05 +0200
In-Reply-To: <20110809181543.GG6482@redhat.com>
References: <20110806084447.388624428@intel.com>
	 <20110806094527.136636891@intel.com> <20110809181543.GG6482@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1312915266.1083.75.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2011-08-09 at 14:15 -0400, Vivek Goyal wrote:
>=20
> So far bw had pos_ratio as value now it will be replaced with actual
> bandwidth as value. It makes code confusing. So using pos_ratio will
> help.=20

Agreed on consistency, also I'm not sure bandwidth is the right term
here to begin with, its a pages/s unit and I think rate would be better
here. But whatever ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
