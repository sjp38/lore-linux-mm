Date: Tue, 29 Jan 2008 12:02:01 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 6/6] mmu_notifier: Add invalidate_all()
In-Reply-To: <20080129163158.GX3058@sgi.com>
Message-ID: <Pine.LNX.4.64.0801291200550.25300@schroedinger.engr.sgi.com>
References: <20080128202840.974253868@sgi.com> <20080128202924.810792591@sgi.com>
 <20080129163158.GX3058@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2008, Robin Holt wrote:

> What is the status of getting invalidate_all adjusted to indicate a need
> to also call _release?

Release is only called if the mmu_notifier is still registered. If you 
take it out on invalidate_all then there will be no call to release 
(provided you deal with the RCU issues).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
