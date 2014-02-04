Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f52.google.com (mail-oa0-f52.google.com [209.85.219.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8BAC86B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 02:27:17 -0500 (EST)
Received: by mail-oa0-f52.google.com with SMTP id i4so9208831oah.25
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 23:27:17 -0800 (PST)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id f6si11136767obr.33.2014.02.03.23.27.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 23:27:16 -0800 (PST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 4 Feb 2014 00:27:16 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 8EE013E4003E
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 00:27:12 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s147QnZe983546
	for <linux-mm@kvack.org>; Tue, 4 Feb 2014 08:26:54 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s147QqdP015997
	for <linux-mm@kvack.org>; Tue, 4 Feb 2014 00:26:52 -0700
Date: Mon, 3 Feb 2014 23:26:30 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <20140204072630.GB10101@linux.vnet.ibm.com>
References: <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com>
 <20140124232902.GB30361@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com>
 <20140125001643.GA25344@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241618500.20466@chino.kir.corp.google.com>
 <20140125011041.GB25344@linux.vnet.ibm.com>
 <20140127055805.GA2471@lge.com>
 <20140128182947.GA1591@linux.vnet.ibm.com>
 <20140203230026.GA15383@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1402032138070.17997@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1402032138070.17997@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On 03.02.2014 [21:38:36 -0600], Christoph Lameter wrote:
> On Mon, 3 Feb 2014, Nishanth Aravamudan wrote:
> 
> > So what's the status of this patch? Christoph, do you think this is fine
> > as it is?
> 
> Certainly enabling CONFIG_MEMORYLESS_NODES is the right thing to do and I
> already acked the patch.

Yes, sorry for my lack of clarity. I meant Joonsoo's latest patch for
the $SUBJECT issue.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
