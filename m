Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5BE006B01C4
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 04:52:55 -0400 (EDT)
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100622012406.1d9aa8fd.akpm@linux-foundation.org>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
	 <20100618060901.GA6590@dastard> <20100621233628.GL3828@quack.suse.cz>
	 <20100622054409.GP7869@dastard>
	 <20100621231416.904c50c7.akpm@linux-foundation.org>
	 <1277192722.1875.526.camel@laptop>
	 <20100622012406.1d9aa8fd.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 22 Jun 2010 10:52:23 +0200
Message-ID: <1277196743.1875.622.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Tue, 2010-06-22 at 01:24 -0700, Andrew Morton wrote:
>=20
> Oh come on, of course it will.  It just needs
> __percpu_counter_compare() as I mentioned when merging it.=20

Sure, all I was saying is that something like that needs doing..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
