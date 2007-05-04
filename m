MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@redhat.com>
Subject: Re: incoming
In-Reply-To: Greg KH's message of  Friday, 4 May 2007 12:24:07 -0700 <20070504192407.GA32235@kroah.com>
Message-Id: <20070504192944.7D5041800A0@magilla.sf.frob.com>
Date: Fri,  4 May 2007 12:29:44 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@engr.sgi.com>, "David S. Miller" <davem@davemloft.net>, Andi Kleen <ak@suse.de>, "Luck, Tony" <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Stephen Smalley <sds@tycho.nsa.gov>
List-ID: <linux-mm.kvack.org>

> ABI changes are not a problem for -stable, so don't let that stop anyone
> :)

In fact this is the harmless sort (changes only the error code of a
failure case) that might actually go in if there were any important
reason.  But the smiley stands.


Thanks,
Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
