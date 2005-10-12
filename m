From: Andi Kleen <ak@suse.de>
Subject: Re: ppc64/cell: local TLB flush with active SPEs
Date: Wed, 12 Oct 2005 20:08:59 +0200
References: <200510122003.59701.arnd@arndb.de>
In-Reply-To: <200510122003.59701.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200510122009.00393.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linuxppc64-dev@ozlabs.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Mark Nutter <mnutter@us.ibm.com>, Mike Day <mnday@us.ibm.com>, Ulrich Weigand <Ulrich.Weigand@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 12 October 2005 20:03, Arnd Bergmann wrote:

> 
> Another idea would be to add a new field to mm_context_t, so it stays
> in the architecture specific code. Again, adding an int here does
> not waste space because there is currently padding in tha place on
> ppc64.

mm_context_t sounds like the right place for this to me.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
