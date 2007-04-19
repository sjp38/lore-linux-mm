Date: Thu, 19 Apr 2007 14:52:36 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: dio_get_page() lockdep complaints
Message-ID: <20070419125236.GF11780@kernel.dk>
References: <20070419073828.GB20928@kernel.dk> <20070419012540.bed394e2.akpm@linux-foundation.org> <20070419083407.GD20928@kernel.dk> <200704191643.38367.vs@namesys.com> <20070419124933.GE11780@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070419124933.GE11780@kernel.dk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Vladimir V. Saveliev" <vs@namesys.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-aio@kvack.org, reiserfs-dev@namesys.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 19 2007, Jens Axboe wrote:
> > I tried fio (1.15) with this job file and did not get the possible
> > circular locking dependency detected
> 
> Perhaps some of the preempt settings? The box is an emc centera, it's a
> lowly p4/ht.

As I mentioned, the rootfs is on reiser. So something in the boot up
scripts may trigger something that gets reiser to run through that path
with the wrong locking order. After the box is done booting, the dmesg
is clean. I then mount the ext3 fs and run the fio test, the lockdep
trace shows up immediately.

The distro is SLES9.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
