Date: Thu, 8 May 2003 14:04:50 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: 2.5.69-mm2 Kernel panic, possibly network related
Message-ID: <20030508120450.GT823@suse.de>
References: <3EB8E4CC.8010409@aitel.hist.no> <20030507.025626.10317747.davem@redhat.com> <20030507144100.GD8978@holomorphy.com> <20030507.064010.42794250.davem@redhat.com> <20030507215430.GA1109@hh.idb.hist.no> <20030508013854.GW8931@holomorphy.com> <20030508065440.GA1890@hh.idb.hist.no> <20030508080135.GK8978@holomorphy.com> <20030508100717.GN8978@holomorphy.com> <3EBA4529.7050507@aitel.hist.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3EBA4529.7050507@aitel.hist.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: William Lee Irwin III <wli@holomorphy.com>, "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

On Thu, May 08 2003, Helge Hafting wrote:
> William Lee Irwin III wrote:
> 
> >2.5.69-mm3 should suffice to test things now. If you can try that when
> >you get back I'd be much obliged.
> 
> 2.5.69-mm3 died in exactly the same way - the oops was identical.
> I'm back to running mm2 without netfilter, to see how
> stable it is.

See my mail to rusty, I'm seeing the same thing. Back out the changeset
that wli pasted here too, and it will work.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
