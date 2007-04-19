Subject: Re: dio_get_page() lockdep complaints
References: <20070419073828.GB20928@kernel.dk>
	<20070419012540.bed394e2.akpm@linux-foundation.org>
	<20070419083407.GD20928@kernel.dk> <200704191643.38367.vs@namesys.com>
	<20070419124933.GE11780@kernel.dk> <20070419125236.GF11780@kernel.dk>
From: Roland Dreier <rdreier@cisco.com>
Date: Thu, 19 Apr 2007 06:53:55 -0700
In-Reply-To: <20070419125236.GF11780@kernel.dk> (Jens Axboe's message of "Thu, 19 Apr 2007 14:52:36 +0200")
Message-ID: <adavefstqq4.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <jens.axboe@oracle.com>
Cc: "Vladimir V. Saveliev" <vs@namesys.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-aio@kvack.org, reiserfs-dev@namesys.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Maybe you could add some hack really early on (say at the beginning of
the reiserfs mount code) that took instances of the locks in the
correct order, so you would get a lockdep trace of where the ordering
is violated when it first happens?

 - R.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
