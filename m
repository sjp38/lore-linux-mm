Date: Fri, 1 Feb 2008 05:04:32 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 1/4] mmu_notifier: Core code
Message-ID: <20080201110432.GL26420@sgi.com>
References: <20080201050439.009441434@sgi.com> <20080201050623.112641539@sgi.com> <20080201105516.GK26420@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080201105516.GK26420@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, Feb 01, 2008 at 04:55:16AM -0600, Robin Holt wrote:
> OK.  Now that release has been moved, I think I agree with you that the
> down_write(mmap_sem) can be used as our lock again and still work for
> Jack.  I would like a ruling from Jack as well.

Ignore this, I was in the wrong work area.  I am sorry for adding to the
confusion.  This version has no locking requirement outside the driver
itself.

Sorry,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
