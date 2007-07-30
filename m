Subject: Re: [ck] Re: SD still better than CFS for 3d ?(was Re: 2.6.23-rc1)
From: Arjan van de Ven <arjan@infradead.org>
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
Date: Mon, 30 Jul 2007 10:51:17 -0700
Message-Id: <1185817877.2739.2.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Hawkins <darthmdh@gmail.com>
Cc: Jacob Braun <jwbraun@gmail.com>, kriko <kristjan.ugrin@gmail.com>, ck@vds.kolivas.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
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


some fo these binary drivers do really really bad stuff (esp the AMD
ones are infamous for that) and it's no surprise they might throw of a
new scheduler. In fact, that's a bonus, some of those hacks are
workarounds for older (often 2.4) scheduler corner cases and should just
be removed from the driver to get better performance. Holding back linux
for such hacky junk in binary drivers would be the absolute worst thing
to do; even for people who insist on using these drivers over the open
source ones, since the next rev of these drivers can now use the new
scheduler and actually be faster with all the workarounds removed.

Very likely the best thing to do is to contact the supplier of the
driver (AMD or Nvidia) and ask them to fix it.....



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
