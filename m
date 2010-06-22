Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DF1C46B01E3
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 09:59:16 -0400 (EDT)
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100622135234.GA11561@localhost>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
	 <20100618060901.GA6590@dastard> <20100621233628.GL3828@quack.suse.cz>
	 <20100622054409.GP7869@dastard>
	 <20100621231416.904c50c7.akpm@linux-foundation.org>
	 <20100622100924.GQ7869@dastard> <20100622131745.GB3338@quack.suse.cz>
	 <20100622135234.GA11561@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 22 Jun 2010 15:59:04 +0200
Message-ID: <1277215144.1875.705.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-06-22 at 21:52 +0800, Wu Fengguang wrote:
>=20
> This test shows that atomic_dec_and_test() is about 4.5 times slower
> than plain i-- in a 4-core CPU. Not bad.=20

It gets worse - much worse - on larger machines.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
