Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 69C8A6B004D
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 17:13:10 -0400 (EDT)
Message-ID: <1376341985.32100.174.camel@pasglop>
Subject: Re: [PATCH 2/2] Register bootmem pages at boot on powerpc
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 13 Aug 2013 07:13:05 +1000
In-Reply-To: <5208DCBC.7060205@linux.vnet.ibm.com>
References: <52050ACE.4090001@linux.vnet.ibm.com>
	 <52050B80.8010602@linux.vnet.ibm.com> <1376266763.32100.144.camel@pasglop>
	 <5208DCBC.7060205@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>

On Mon, 2013-08-12 at 08:01 -0500, Nathan Fontenot wrote:
> > Can you tell me a bit more, the above makes me nervous...
> 
> Ok, I agree. that message isn't quite right.
> 
> What I wanted to convey is that memory hotplug is not fully supported
> on powerpc with SPARSE_VMEMMAP enabled.. Perhaps the message should read
> "Memory hotplug is not fully supported for bootmem info nodes".
> 
> Thoughts?

Since SPARSE_VMEMMAP is our default and enabled in our distros, that mean
that memory hotplug isn't fully supported for us in general ?

What do you mean by "not fully supported" ? What precisely is missing ?
What will happen if one tries to plug or unplug memory?

Shouldn't we fix it ?

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
