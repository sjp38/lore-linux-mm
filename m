Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 37A2C6B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 11:52:05 -0400 (EDT)
Received: by igbyr2 with SMTP id yr2so18351911igb.0
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 08:52:05 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id o19si2343921igs.5.2015.04.24.08.52.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 08:52:04 -0700 (PDT)
Date: Fri, 24 Apr 2015 10:52:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150424145738.GZ5561@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.11.1504241051090.9889@gentwo.org>
References: <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <20150422000538.GB6046@gmail.com> <alpine.DEB.2.11.1504211942040.6294@gentwo.org> <20150422131832.GU5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
 <1429756200.4915.19.camel@kernel.crashing.org> <alpine.DEB.2.11.1504230921020.32297@gentwo.org> <55390EE1.8020304@gmail.com> <20150423193339.GR5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504240909350.7582@gentwo.org>
 <20150424145738.GZ5561@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Austin S Hemmelgarn <ahferroin7@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, 24 Apr 2015, Paul E. McKenney wrote:

> > DAX is a mechanism to access memory not managed by the kernel and is the
> > successor to XIP. It just happens to be needed for persistent memory.
> > Fundamentally any driver can provide an MMAPPed interface to allow access
> > to a devices memory.
>
> I will take another look, but others in this thread have called out
> difficulties with DAX's filesystem nature.

Right so you do not need the filesystem structure. Just simply writing a
device driver that mmaps data as needed from the coprocessor will also do
the trick.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
