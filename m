Date: Mon, 11 Sep 2006 11:49:33 -0400
From: Jeff Dike <jdike@addtoit.com>
Subject: Re: [PATCH 14/21] uml: enable scsi and add iscsi config
Message-ID: <20060911154933.GC4443@ccure.user-mode-linux.org>
References: <20060906131630.793619000@chello.nl>> <20060906133955.337828000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060906133955.337828000@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>, Mike Christie <michaelc@cs.wisc.edu>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 06, 2006 at 03:16:44PM +0200, Peter Zijlstra wrote:
> Enable iSCSI on UML, dunno why SCSI was deemed broken, it works like a charm.

Acked-by: Jeff Dike <jdike@addtoit.com>

Although it would be nice if we didn't have to copy bits of Kconfig files
to do this.

				Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
