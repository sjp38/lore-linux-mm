Received: by ik-out-1112.google.com with SMTP id c28so1008850ika
        for <linux-mm@kvack.org>; Mon, 30 Jul 2007 09:25:48 -0700 (PDT)
Message-ID: <b21f8390707300925i76cb08f2j55bba537cf853f88@mail.gmail.com>
Date: Tue, 31 Jul 2007 02:25:47 +1000
From: "Matthew Hawkins" <darthmdh@gmail.com>
Subject: Re: [ck] Re: SD still better than CFS for 3d ?(was Re: 2.6.23-rc1)
In-Reply-To: <d3380cee0707300831m33d896aufcbdb188576940a2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>
	 <1185536610.502.8.camel@localhost> <20070729170641.GA26220@elte.hu>
	 <930f95dc0707291154j102494d9m58f4cc452c7ff17c@mail.gmail.com>
	 <20070729204716.GB1578@elte.hu>
	 <930f95dc0707291431j4e50214di3c01cd44b5597502@mail.gmail.com>
	 <20070730114649.GB19186@elte.hu> <op.tv90xghwatcbto@linux.site>
	 <d3380cee0707300831m33d896aufcbdb188576940a2@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jacob Braun <jwbraun@gmail.com>
Cc: kriko <kristjan.ugrin@gmail.com>, ck@vds.kolivas.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On 7/31/07, Jacob Braun <jwbraun@gmail.com> wrote:
> On 7/30/07, kriko <kristjan.ugrin@gmail.com> wrote:
> > I would try the new cfs how it performs, but it seems that nvidia drivers
> > doesn't compile successfully under 2.6.23-rc1.
> > http://files.myopera.com/kriko/files/nvidia-installer.log
> >
> > If someone has the solution, please share.
>
> There is a patch for the nvidia drivers here:
> http://bugs.gentoo.org/attachment.cgi?id=125959

The ATI drivers (current 8.39.4) were broken by
commit e21ea246bce5bb93dd822de420172ec280aed492
Author: Martin Schwidefsky <schwidefsky@de.ibm.com>

Bad call on the "nobody was using these", Martin :(

-- 
Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
