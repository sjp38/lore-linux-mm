Subject: Re: Prezeroing V2 [0/3]: Why and When it works
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com>
	 <41C20E3E.3070209@yahoo.com.au>
	 <Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 23 Dec 2004 20:49:13 +0100
Message-Id: <1103831353.4139.16.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> The most expensive operation in the page fault handler is (apart of SMP
> locking overhead) the zeroing of the page. This zeroing means that all
> cachelines of the faulted page (on Altix that means all 128 cachelines of
> 128 byte each) must be loaded and later written back. This patch allows to
> avoid having to load all cachelines if only a part of the cachelines of
> that page is needed immediately after the fault.

eh why will all cachelines be loaded? Surely you can avoid the write-
allocate behavior for this case.....


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
