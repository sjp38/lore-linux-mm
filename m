Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id l6UGlQDK590720
	for <linux-mm@kvack.org>; Mon, 30 Jul 2007 16:47:26 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6UGlPAk2203754
	for <linux-mm@kvack.org>; Mon, 30 Jul 2007 18:47:25 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6UGlJvd029542
	for <linux-mm@kvack.org>; Mon, 30 Jul 2007 18:47:19 +0200
Subject: Re: [ck] Re: SD still better than CFS for 3d ?(was Re: 2.6.23-rc1)
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <b21f8390707300925i76cb08f2j55bba537cf853f88@mail.gmail.com>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>
	 <1185536610.502.8.camel@localhost> <20070729170641.GA26220@elte.hu>
	 <930f95dc0707291154j102494d9m58f4cc452c7ff17c@mail.gmail.com>
	 <20070729204716.GB1578@elte.hu>
	 <930f95dc0707291431j4e50214di3c01cd44b5597502@mail.gmail.com>
	 <20070730114649.GB19186@elte.hu> <op.tv90xghwatcbto@linux.site>
	 <d3380cee0707300831m33d896aufcbdb188576940a2@mail.gmail.com>
	 <b21f8390707300925i76cb08f2j55bba537cf853f88@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 30 Jul 2007 18:50:43 +0200
Message-Id: <1185814243.7377.2.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Hawkins <darthmdh@gmail.com>
Cc: Jacob Braun <jwbraun@gmail.com>, kriko <kristjan.ugrin@gmail.com>, ck@vds.kolivas.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-07-31 at 02:25 +1000, Matthew Hawkins wrote:
> On 7/31/07, Jacob Braun <jwbraun@gmail.com> wrote:
> > On 7/30/07, kriko <kristjan.ugrin@gmail.com> wrote:
> > > I would try the new cfs how it performs, but it seems that nvidia drivers
> > > doesn't compile successfully under 2.6.23-rc1.
> > > http://files.myopera.com/kriko/files/nvidia-installer.log
> > >
> > > If someone has the solution, please share.
> >
> > There is a patch for the nvidia drivers here:
> > http://bugs.gentoo.org/attachment.cgi?id=125959
> 
> The ATI drivers (current 8.39.4) were broken by
> commit e21ea246bce5bb93dd822de420172ec280aed492
> Author: Martin Schwidefsky <schwidefsky@de.ibm.com>
> 
> Bad call on the "nobody was using these", Martin :(

Do we care ? The code should be replaced with ptep_get_and_clear +
pte_modify anyway..

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
