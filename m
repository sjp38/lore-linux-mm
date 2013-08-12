Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id A27246B0036
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 17:59:38 -0400 (EDT)
Message-ID: <1376344774.32100.185.camel@pasglop>
Subject: Re: [PATCH 2/2] Register bootmem pages at boot on powerpc
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 13 Aug 2013 07:59:34 +1000
In-Reply-To: <520952C9.3060101@linux.vnet.ibm.com>
References: <52050ACE.4090001@linux.vnet.ibm.com>
	 <52050B80.8010602@linux.vnet.ibm.com> <1376266763.32100.144.camel@pasglop>
	 <5208DCBC.7060205@linux.vnet.ibm.com> <1376341985.32100.174.camel@pasglop>
	 <520952C9.3060101@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>

On Mon, 2013-08-12 at 16:25 -0500, Nathan Fontenot wrote:
> On 08/12/2013 04:13 PM, Benjamin Herrenschmidt wrote:
> > On Mon, 2013-08-12 at 08:01 -0500, Nathan Fontenot wrote:
> >>> Can you tell me a bit more, the above makes me nervous...
> >>
> >> Ok, I agree. that message isn't quite right.
> >>
> >> What I wanted to convey is that memory hotplug is not fully supported
> >> on powerpc with SPARSE_VMEMMAP enabled.. Perhaps the message should read
> >> "Memory hotplug is not fully supported for bootmem info nodes".
> >>
> >> Thoughts?
> > 
> > Since SPARSE_VMEMMAP is our default and enabled in our distros, that mean
> > that memory hotplug isn't fully supported for us in general ?
> 
> Actually... We have had the distros (at least SLES 11 and RHEL 6 releases)
> disable SPARSE_VMEMMAP in their releases.

Yuck ! That has a significant impact on performances... Additionally our
VFIO implementation for KVM requires SPARSE_VMEMMAP. Why is it that this
was never fixed in all these years ?

> > 
> > What do you mean by "not fully supported" ? What precisely is missing ?
> > What will happen if one tries to plug or unplug memory?
> 
> I don't know everything that is missing, but there are several routines
> that need to be defined for power to support memory hotplug with SPARSE_VMEMMAP.
> 
> > 
> > Shouldn't we fix it ?
> 
> Working on it, but it's not there yet.

Ok, thanks.

Cheers,
Ben.

> > 
> > Cheers,
> > Ben.
> > 
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
