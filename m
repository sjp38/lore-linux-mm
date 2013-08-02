Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id EE1156B0032
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 22:27:08 -0400 (EDT)
Date: Fri, 2 Aug 2013 12:27:03 +1000
From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH 1/8] register bootmem pages for powerpc when sparse
 vmemmap is not defined
Message-ID: <20130802022703.GA1680@concordia>
References: <51F01E06.6090800@linux.vnet.ibm.com>
 <51F01E5F.80307@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F01E5F.80307@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, isimatu.yasuaki@jp.fujitsu.com

On Wed, Jul 24, 2013 at 01:35:11PM -0500, Nathan Fontenot wrote:
> Previous commit 46723bfa540... introduced a new config option
> HAVE_BOOTMEM_INFO_NODE that ended up breaking memory hot-remove for powerpc
> when sparse vmemmap is not defined.

So that's a bug fix that should go into 3.10 stable?

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
