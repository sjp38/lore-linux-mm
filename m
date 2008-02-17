In-reply-to: <20080215193719.262c03a1.akpm@linux-foundation.org> 
References: <20080215064859.384203497@sgi.com> <20080215064932.371510599@sgi.com>  <20080215193719.262c03a1.akpm@linux-foundation.org> 
Subject: Re: [patch 1/6] mmu_notifier: Core code 
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Sat, 16 Feb 2008 23:04:50 -0600
Message-ID: <1428.1203224690@bebe.enoyolf.org>
From: Doug Maxey <dwm@enoyolf.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Ben Herrenschmidt <benh@kernel.crashing.org>, Jan-Bernd Themann <themann@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 15 Feb 2008 19:37:19 PST, Andrew Morton wrote:
> Which other potential clients have been identified and how important it it
> to those?

The powerpc ehea utilizes its own mmu.  Not sure about the importance 
to the driver. (But will investigate :)

++doug

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
