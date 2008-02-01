Date: Fri, 1 Feb 2008 11:14:51 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/4] mmu_notifier: Core code
In-Reply-To: <20080201105516.GK26420@sgi.com>
Message-ID: <Pine.LNX.4.64.0802011114280.18163@schroedinger.engr.sgi.com>
References: <20080201050439.009441434@sgi.com> <20080201050623.112641539@sgi.com>
 <20080201105516.GK26420@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 1 Feb 2008, Robin Holt wrote:

> OK.  Now that release has been moved, I think I agree with you that the
> down_write(mmap_sem) can be used as our lock again and still work for
> Jack.  I would like a ruling from Jack as well.

Talked to Jack last night and he said its okay.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
