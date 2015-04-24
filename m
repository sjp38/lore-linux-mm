Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1A8A96B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 10:09:14 -0400 (EDT)
Received: by iebrs15 with SMTP id rs15so84294035ieb.3
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 07:09:13 -0700 (PDT)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id i6si2130522igu.6.2015.04.24.07.09.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 07:09:13 -0700 (PDT)
Date: Fri, 24 Apr 2015 09:09:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <55390EE1.8020304@gmail.com>
Message-ID: <alpine.DEB.2.11.1504240904530.7582@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <20150422000538.GB6046@gmail.com> <alpine.DEB.2.11.1504211942040.6294@gentwo.org> <20150422131832.GU5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
 <1429756200.4915.19.camel@kernel.crashing.org> <alpine.DEB.2.11.1504230921020.32297@gentwo.org> <55390EE1.8020304@gmail.com>
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; FORMAT=flowed
Content-ID: <alpine.DEB.2.11.1504240904532.7582@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Austin S Hemmelgarn <ahferroin7@gmail.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Thu, 23 Apr 2015, Austin S Hemmelgarn wrote:

> Looking at this whole conversation, all I see is two different views on how to
> present the asymmetric multiprocessing arrangements that have become
> commonplace in today's systems to userspace.  Your model favors performance,
> while CAPI favors simplicity for userspace.

Oww. No performance just simplicity? Really?

The simplification of the memory registration for Infiniband etc is
certainly useful and I hope to see contributions on that going into the
kernel.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
