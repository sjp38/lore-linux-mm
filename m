Date: Mon, 1 Dec 2008 08:40:58 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 8/8] badpage: KERN_ALERT BUG instead of KERN_EMERG
In-Reply-To: <Pine.LNX.4.64.0812010047010.11401@blonde.site>
Message-ID: <Pine.LNX.4.64.0812010840110.15331@quilx.com>
References: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
 <Pine.LNX.4.64.0812010047010.11401@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Jones <davej@redhat.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Dec 2008, Hugh Dickins wrote:
> And remove the "Trying to fix it up, but a reboot is needed" line:
> it's not untrue, but I hope the KERN_ALERT "BUG: " conveys as much.

Thanks. That was a pretty strange message....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
