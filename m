Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f50.google.com (mail-vn0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id E0854900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 21:04:55 -0400 (EDT)
Received: by vnbf129 with SMTP id f129so34235610vnb.9
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 18:04:55 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id kg5si3531429vdb.107.2015.04.21.18.04.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 18:04:55 -0700 (PDT)
Message-ID: <1429664686.27410.84.camel@kernel.crashing.org>
Subject: Re: Interacting with coherent memory on external devices
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 22 Apr 2015 11:04:46 +1000
In-Reply-To: <20150422005757.GP5561@linux.vnet.ibm.com>
References: <20150421214445.GA29093@linux.vnet.ibm.com>
	 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
	 <1429663372.27410.75.camel@kernel.crashing.org>
	 <20150422005757.GP5561@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Tue, 2015-04-21 at 17:57 -0700, Paul E. McKenney wrote:
> On Wed, Apr 22, 2015 at 10:42:52AM +1000, Benjamin Herrenschmidt wrote:
> > On Tue, 2015-04-21 at 18:49 -0500, Christoph Lameter wrote:
> > > On Tue, 21 Apr 2015, Paul E. McKenney wrote:
> > > 
> > > > Thoughts?
> > > 
> > > Use DAX for memory instead of the other approaches? That way it is
> > > explicitly clear what information is put on the CAPI device.
> > 
> > Care to elaborate on what DAX is ?
> 
> I would like to know as well.  My first attempt to Google got me nothing
> but Star Trek.  Is DAX the persistent-memory topic covered here?
> 
> 	https://lwn.net/Articles/591779/
> 	https://lwn.net/Articles/610174/
> 
> Ben will correct me if I am wrong, but I do not believe that we are
> looking for persistent memory in this case.

Right, it doesn't look at all like what we want.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
