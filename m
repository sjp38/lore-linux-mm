Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 203026B003A
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 12:53:56 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id lx4so665324iec.37
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 09:53:56 -0700 (PDT)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id nz8si19965842icb.69.2014.03.25.09.53.50
        for <linux-mm@kvack.org>;
        Tue, 25 Mar 2014 09:53:50 -0700 (PDT)
Date: Tue, 25 Mar 2014 11:53:48 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Bug in reclaim logic with exhausted nodes?
In-Reply-To: <20140325162303.GA29977@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1403251152250.16870@nuc>
References: <20140311210614.GB946@linux.vnet.ibm.com> <20140313170127.GE22247@linux.vnet.ibm.com> <20140324230550.GB18778@linux.vnet.ibm.com> <alpine.DEB.2.10.1403251116490.16557@nuc> <20140325162303.GA29977@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, rientjes@google.com, linuxppc-dev@lists.ozlabs.org, anton@samba.org, mgorman@suse.de

On Tue, 25 Mar 2014, Nishanth Aravamudan wrote:

> On 25.03.2014 [11:17:57 -0500], Christoph Lameter wrote:
> > On Mon, 24 Mar 2014, Nishanth Aravamudan wrote:
> >
> > > Anyone have any ideas here?
> >
> > Dont do that? Check on boot to not allow exhausting a node with huge
> > pages?
>
> Gigantic hugepages are allocated by the hypervisor (not the Linux VM),

Ok so the kernel starts booting up and then suddenly the hypervisor takes
the 2 16G pages before even the slab allocator is working?

Not sure if I understand that correctly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
