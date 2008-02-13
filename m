Date: Wed, 13 Feb 2008 08:31:18 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [patch 0/6] MMU Notifiers V6
Message-ID: <20080213143114.GA26715@sgi.com>
References: <20080208220616.089936205@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080208220616.089936205@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

> GRU
> - Simple additional hardware TLB (possibly covering multiple instances of
>   Linux)
> - Needs TLB shootdown when the VM unmaps pages.
> - Determines page address via follow_page (from interrupt context) but can
>   fall back to get_user_pages().
> - No page reference possible since no page status is kept..

I applied the latest mmuops patch to a 2.6.24 kernel & updated the
GRU driver to use it. As far as I can tell, everything works ok.
Although more testing is needed, all current tests of driver functionality
are working on both a system simulator and a hardware simulator.

The driver itself is still a few weeks from being ready to post but I can
send code fragments of the portions related to mmuops or external TLB
management if anyone is interested.


--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
