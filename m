Date: Mon, 11 Aug 2003 09:02:22 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Is /proc/#/statm worth fixing?
Message-ID: <20030811160222.GE3170@holomorphy.com>
References: <20030811090213.GA11939@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030811090213.GA11939@k3.hellgate.ch>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Luethi <rl@hellgate.ch>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 11, 2003 at 11:02:13AM +0200, Roger Luethi wrote:
> /proc/#/statm is a joke. Out of 7 columns, 2 are always zero in 2.6. Of
> the remaining columns, at least one more is incorrect. You can most
> certainly get all the intended values off /proc/#/status anyway [1].
> In 2.4, more columns show actual data, but also more of them are wrong.
> To top it off, 2.4 and 2.6 show vastly different numbers for several
> colums (where they clearly shouldn't).
> /proc/#/statm is bust and any tool relying on it is broken. Can we just
> remove that file? Maybe print poisoned values in 2.6 to prevent the odd
> program from crashing (if there are any), and remove it in 2.7.

I've restored a number of the fields to the 2.4.x semantics in tandem
with a forward port of bcrl's O(1) proc_pid_statm() patch.

I dumped the forward port of the patch into -wli, available at:
ftp://ftp.kernel.org/pub/linux/kernel/people/wli/kernels/

It's unclear how much traction it will get, as it's mildly overweight
as far as patches go, though I wouldn't go so far as to call it invasive
(opinions will vary, of course).


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
