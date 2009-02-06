Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 578F66B003D
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 11:57:00 -0500 (EST)
Date: Fri, 6 Feb 2009 17:56:56 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Patch] mmu_notifiers destroyed by __mmu_notifier_release()
	retain extra mm_count.
Message-ID: <20090206165656.GP14011@random.random>
References: <20090205172303.GB8559@sgi.com> <alpine.DEB.1.10.0902051427280.13692@qirst.com> <20090205200214.GN8577@sgi.com> <alpine.DEB.1.10.0902051844390.17441@qirst.com> <20090206013805.GL14011@random.random> <20090206014400.GM14011@random.random> <20090206125845.GC8559@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090206125845.GC8559@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Glad you are ok with mandatory unregister, it wasn't a problem for GRU
either and the auto-mm-pinning gives peace of mind.

On Fri, Feb 06, 2009 at 06:58:45AM -0600, Robin Holt wrote:
> Sorry for the noise.

No prob from my part, one more review and refresh of correctness of
current code didn't hurt ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
