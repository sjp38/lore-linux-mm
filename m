Date: Tue, 9 May 2006 20:22:46 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 0/2][RFC] New version of shared page tables
In-Reply-To: <445FA0CA.4010008@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0605092012170.8037@blonde.wat.veritas.com>
References: <1146671004.24422.20.camel@wildcat.int.mccr.org>
 <Pine.LNX.4.64.0605031650190.3057@blonde.wat.veritas.com>
 <57DF992082E5BD7D36C9D441@[10.1.1.4]> <Pine.LNX.4.64.0605061620560.5462@blonde.wat.veritas.com>
 <445FA0CA.4010008@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brian Twichell <tbrian@us.ibm.com>
Cc: Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 8 May 2006, Brian Twichell wrote:
> 
> If we had to choose between pagetable sharing for small pages and hugepages,
> we would be in favor of retaining pagetable sharing for small pages.  That is
> where the discernable benefit is for customers that run with "out-of-the-box"
> settings.  Also, there is still some benefit there on x86-64 for customers
> that use hugepages for the bufferpools.

Thanks for the further info, Brian.  Okay, the hugepage end of it does
add a different kind of complexity, in an area already complex from the
different arch implementations.  If you've found that a significant part
of the hugepage test improvment is actually due to the smallpage changes,
let's turn around what I said, and suggest Dave concentrate on getting the
smallpage changes right, putting the hugepage part of it on the backburner
at least for now (or if he's particularly keen still to present it, as 3/3).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
