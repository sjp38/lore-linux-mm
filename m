MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@redhat.com>
Subject: Re: incoming
In-Reply-To: Andrew Morton's message of  Friday, 4 May 2007 09:14:34 -0700 <20070504091434.106ad04d.akpm@linux-foundation.org>
Message-Id: <20070504185721.3CB7C1800A0@magilla.sf.frob.com>
Date: Fri,  4 May 2007 11:57:21 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg KH <greg@kroah.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@engr.sgi.com>, "David S. Miller" <davem@davemloft.net>, Andi Kleen <ak@suse.de>, "Luck, Tony" <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Stephen Smalley <sds@tycho.nsa.gov>
List-ID: <linux-mm.kvack.org>

> Ah.  The patch affects security code, but it doesn't actually address any
> insecurity.  I didn't think it was needed for -stable?

I would not recommend it for -stable.  
It is an ABI change for the case of a security refusal.


Thanks,
Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
