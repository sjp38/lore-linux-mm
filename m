Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id D8E71900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 20:58:03 -0400 (EDT)
Received: by qgdy78 with SMTP id y78so76587661qgd.0
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 17:58:03 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id 70si3625934qgb.16.2015.04.21.17.58.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 17:58:02 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 21 Apr 2015 18:58:01 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 27EF419D803F
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 18:49:04 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3M0vfnw39649288
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 17:57:41 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3M0vxAF021715
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 18:57:59 -0600
Date: Tue, 21 Apr 2015 17:57:57 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150422005757.GP5561@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20150421214445.GA29093@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
 <1429663372.27410.75.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1429663372.27410.75.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Wed, Apr 22, 2015 at 10:42:52AM +1000, Benjamin Herrenschmidt wrote:
> On Tue, 2015-04-21 at 18:49 -0500, Christoph Lameter wrote:
> > On Tue, 21 Apr 2015, Paul E. McKenney wrote:
> > 
> > > Thoughts?
> > 
> > Use DAX for memory instead of the other approaches? That way it is
> > explicitly clear what information is put on the CAPI device.
> 
> Care to elaborate on what DAX is ?

I would like to know as well.  My first attempt to Google got me nothing
but Star Trek.  Is DAX the persistent-memory topic covered here?

	https://lwn.net/Articles/591779/
	https://lwn.net/Articles/610174/

Ben will correct me if I am wrong, but I do not believe that we are
looking for persistent memory in this case.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
