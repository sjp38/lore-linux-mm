Date: Mon, 28 Jan 2008 10:44:56 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/4] mmu_notifier: Core code
In-Reply-To: <20080126120149.GS3058@sgi.com>
Message-ID: <Pine.LNX.4.64.0801281044380.14003@schroedinger.engr.sgi.com>
References: <20080125055606.102986685@sgi.com> <20080125055801.212744875@sgi.com>
 <20080125183934.GO26420@sgi.com> <Pine.LNX.4.64.0801251041040.672@schroedinger.engr.sgi.com>
 <20080125185646.GQ3058@sgi.com> <Pine.LNX.4.64.0801251058170.3198@schroedinger.engr.sgi.com>
 <20080125193554.GP26420@sgi.com> <Pine.LNX.4.64.0801251315350.19523@schroedinger.engr.sgi.com>
 <20080126120149.GS3058@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Sat, 26 Jan 2008, Robin Holt wrote:

> But what if the caller is already holding the mmap_sem?  Why force the
> acquire into this function?  Since we are dealing with a semaphore/mutex,

Then you need to call __register_mmu_notifier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
