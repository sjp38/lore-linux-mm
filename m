Date: Sun, 3 Feb 2008 02:39:36 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 0/4] [RFC] EMMU Notifiers V5
Message-ID: <20080203013936.GB7185@v2.random>
References: <20080201050439.009441434@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080201050439.009441434@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2008 at 09:04:39PM -0800, Christoph Lameter wrote:
> - Has page tables to track pages whose refcount was elevated(?) but
>   no reverse maps.

Just a correction, rmaps exists or swap couldn't be sane, it's just
that it's not built on the page_t because the guest memory is really
virtual and not physical at all (hence it swaps really well, thanks to
the regular linux VM algorithms without requiring any KVM knowledge at
all, it all looks (shared) anonymous memory as far as linux is
concerned ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
