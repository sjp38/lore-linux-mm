Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <20041004.033559.71092746.taka@valinux.co.jp>
References: <20041002183349.GA7986@logos.cnet>
	 <20041003.131338.41636688.taka@valinux.co.jp>
	 <20041003140723.GD4635@logos.cnet>
	 <20041004.033559.71092746.taka@valinux.co.jp>
Content-Type: text/plain; charset=iso-8859-1
Message-Id: <1096831287.9667.61.camel@lade.trondhjem.org>
Mime-Version: 1.0
Date: Sun, 03 Oct 2004 21:21:27 +0200
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, iwamoto@valinux.co.jp, haveblue@us.ibm.com, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, piggin@cyberone.com.au, arjanv@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Pa su , 03/10/2004 klokka 20:35, skreiv Hirokazu Takahashi:

> Pages for NFS also might be pinned with network problems.
> One of the ideas is to restrict NFS to allocate pages from
> specific memory region, sot that all memory except the region
> can be hot-removed. And it's possible to implementing whole
> migrate_page method, which may handled stuck pages.

Why do you want to special-case this?

The above is a generic condition: any filesystem can suffer from the
equivalent problem of a failure or slow response in the underlying
device. Making an NFS-specific hack is just counter-productive to
solving the generic problem.

Cheers,
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
