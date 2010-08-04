Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F29C06B02A4
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 13:10:15 -0400 (EDT)
Subject: Re: [PATCH 3/6] writeback: avoid unnecessary calculation of bdi
 dirty thresholds
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100804164159.GA22189@localhost>
References: <20100711020656.340075560@intel.com>
	 <20100711021748.879183413@intel.com> <1280847822.1923.597.camel@laptop>
	 <20100804164159.GA22189@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 04 Aug 2010 19:10:10 +0200
Message-ID: <1280941810.1923.1424.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-08-05 at 00:41 +0800, Wu Fengguang wrote:
>=20
> Comments updated as below. Any suggestions/corrections?
>=20
Looks nice, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
