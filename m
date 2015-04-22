Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id D314F6B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 11:20:10 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so44738085ied.1
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 08:20:10 -0700 (PDT)
Received: from resqmta-po-11v.sys.comcast.net (resqmta-po-11v.sys.comcast.net. [2001:558:fe16:19:96:114:154:170])
        by mx.google.com with ESMTPS id jm16si4778849icb.27.2015.04.22.08.20.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 08:20:10 -0700 (PDT)
Date: Wed, 22 Apr 2015 10:20:08 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150422005757.GP5561@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.11.1504221018340.24979@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <1429663372.27410.75.camel@kernel.crashing.org> <20150422005757.GP5561@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Tue, 21 Apr 2015, Paul E. McKenney wrote:

> Ben will correct me if I am wrong, but I do not believe that we are
> looking for persistent memory in this case.

DAX is way of mapping special memory into user space. Persistance is one
possible use case. Its like the XIP that you IBMers know from z/OS
or the 390 mainframe stuff.

Its been widely discussed at memory managenent meetings. A bit surprised
that this is not a well known thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
