Date: Fri, 7 Mar 2008 20:12:57 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: Notifier for Externally Mapped Memory (EMM) V1
Message-ID: <20080307191257.GN24114@v2.random>
References: <Pine.LNX.4.64.0803051600470.7481@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803051600470.7481@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Izik Eidus <izike@qumranet.com>, Avi Kivity <avi@qumranet.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 05, 2008 at 04:22:11PM -0800, Christoph Lameter wrote:
> +		if (e->callback) {
> +			x = e->callback(e, mm, op, start, end);
> +			if (x)
> +				return x;
[..]
> +
> +	if (emm_notify(mm, emm_referenced, address, address + PAGE_SIZE))
> +			referenced++;

This has still the same aging bug as in the RFC version.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
