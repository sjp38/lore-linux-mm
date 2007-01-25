Date: Wed, 24 Jan 2007 18:40:45 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Limit the size of the pagecache
In-Reply-To: <20070124200614.GA25690@codepoet.org>
Message-ID: <Pine.LNX.4.64.0701241840090.12325@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
 <1169625333.4493.16.camel@taijtu> <45B7561C.9000102@yahoo.com.au>
 <Pine.LNX.4.64.0701240657130.9696@schroedinger.engr.sgi.com>
 <20070124200614.GA25690@codepoet.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Erik Andersen <andersen@codepoet.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Aubrey Li <aubreylee@gmail.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Robin Getz <rgetz@blackfin.uclinux.org>, "Henn, erich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jan 2007, Erik Andersen wrote:

> It would be far more useful if an application could hint to the
> pagecache as to which files are and which files as not worth
> caching, especially when the application knows a priori that data
> from a particular file will or will not ever be reused.

It can give such hints via madvise(2).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
