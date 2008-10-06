Date: Tue, 7 Oct 2008 00:26:01 +0100
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: Have ever checked in your mips sparsemem code into mips-linux
	tree?
Message-ID: <20081006232601.GB4376@linux-mips.org>
References: <48EA71F5.1040200@sciatl.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48EA71F5.1040200@sciatl.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: C Michael Sundius <Michael.sundius@sciatl.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-mips@linux-mips.org, "VomLehn, David" <dvomlehn@cisco.com>, me94043@yahoo.com
List-ID: <linux-mm.kvack.org>

On Mon, Oct 06, 2008 at 01:15:49PM -0700, C Michael Sundius wrote:

Btw, I'm planning to rip support for discontig memory from MIPS.  IP27
is the only platform using it and it also would be better off using
sparsemem instead.

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
