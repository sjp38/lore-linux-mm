Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9C5BD6B01E0
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 10:12:55 -0400 (EDT)
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100621141027.GG3828@quack.suse.cz>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
	 <1276856496.27822.1698.camel@twins> <20100621140236.GF3828@quack.suse.cz>
	 <20100621141027.GG3828@quack.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 21 Jun 2010 16:12:47 +0200
Message-ID: <1277129567.1875.517.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, akpm@linux-foundation.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-21 at 16:10 +0200, Jan Kara wrote:
>   I just got an idea - if the sleeping is too unfair (as threads at the e=
nd
> of the FIFO are likely to have 'pause' smaller and thus could find out
> earlier that the system is below dirty limits), we could share 'pause'
> among all threads waiting for that BDI. That way threads would wake up
> in a FIFO order...=20


Sounds sensible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
