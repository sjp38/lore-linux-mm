Date: Sun, 11 May 2003 08:06:41 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.69-mm2 Kernel panic, possibly network related
Message-ID: <20030511150641.GL8978@holomorphy.com>
References: <3EB8E4CC.8010409@aitel.hist.no> <20030507.025626.10317747.davem@redhat.com> <20030507144100.GD8978@holomorphy.com> <20030507.064010.42794250.davem@redhat.com> <20030507215430.GA1109@hh.idb.hist.no> <20030508013854.GW8931@holomorphy.com> <20030508065440.GA1890@hh.idb.hist.no> <20030508080135.GK8978@holomorphy.com> <20030508100717.GN8978@holomorphy.com> <3EBA39B9.8040008@aitel.hist.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3EBA39B9.8040008@aitel.hist.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> 2.5.69-mm3 should suffice to test things now. If you can try that when
>> you get back I'd be much obliged.

On Thu, May 08, 2003 at 01:04:25PM +0200, Helge Hafting wrote:
> I'll do.
> It'll probably work, for a 2.5.69-mm2 without netfilter works fine.
> At least it stays up for hours where 2.5.69-mm2 with netfilter died
> in 15 minutes.

I think -mm3 only has the incomplete netfilter fix; you might want to
twiddle it to use davem's more complete fix instead.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
