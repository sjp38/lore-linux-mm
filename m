Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id C4AA26B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 11:49:31 -0400 (EDT)
Received: by igblo3 with SMTP id lo3so17840830igb.0
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 08:49:31 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id p8si2296684ige.41.2015.04.24.08.49.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 08:49:31 -0700 (PDT)
Date: Fri, 24 Apr 2015 10:49:28 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150424145459.GY5561@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.11.1504241048490.9889@gentwo.org>
References: <1429663372.27410.75.camel@kernel.crashing.org> <20150422005757.GP5561@linux.vnet.ibm.com> <1429664686.27410.84.camel@kernel.crashing.org> <alpine.DEB.2.11.1504221020160.24979@gentwo.org> <20150422163135.GA4062@gmail.com>
 <alpine.DEB.2.11.1504221206080.25607@gentwo.org> <1429756456.4915.22.camel@kernel.crashing.org> <alpine.DEB.2.11.1504230925250.32297@gentwo.org> <20150423185240.GO5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504240929340.7582@gentwo.org>
 <20150424145459.GY5561@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, 24 Apr 2015, Paul E. McKenney wrote:

> can deliver, but where the cost of full-fledge hand tuning cannot be
> justified.
>
> You seem to believe that this latter category is the empty set, which
> I must confess does greatly surprise me.

If there are already compromises are being made then why would you want to
modify the kernel for this? Some user space coding and device drivers
should be sufficient.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
