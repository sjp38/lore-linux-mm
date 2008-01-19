Received: by rv-out-0910.google.com with SMTP id l15so940243rvb.26
        for <linux-mm@kvack.org>; Fri, 18 Jan 2008 22:20:11 -0800 (PST)
Message-ID: <86802c440801182220h640dc0csabd92e715d4e79d0@mail.gmail.com>
Date: Fri, 18 Jan 2008 22:20:11 -0800
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH 1/5] x86: Change size of node ids from u8 to u16 fixup
In-Reply-To: <alpine.DEB.0.9999.0801182116380.10040@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080118183011.354965000@sgi.com>
	 <20080118183011.527888000@sgi.com>
	 <86802c440801182003vd94044ex7fb13e61e5f79c81@mail.gmail.com>
	 <alpine.DEB.0.9999.0801182026130.32726@chino.kir.corp.google.com>
	 <86802c440801182043l1f36086bq51d1fa0528e6bd74@mail.gmail.com>
	 <alpine.DEB.0.9999.0801182116380.10040@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Eric Dumazet <dada1@cosmosbay.com>
List-ID: <linux-mm.kvack.org>

On Jan 18, 2008 9:17 PM, David Rientjes <rientjes@google.com> wrote:
> On Fri, 18 Jan 2008, Yinghai Lu wrote:
>
> > > > I got
> > > > SART: PXM 0 -> APIC 0 -> Node 255
> > > > SART: PXM 0 -> APIC 1 -> Node 255
> > > > SART: PXM 1 -> APIC 2 -> Node 255
> > > > SART: PXM 1 -> APIC 3 -> Node 255
> > > >
> > >
> > > I assume this is a typo and those proximity mappings are actually from the
> > > SRAT.
> >
> > SRAT for processor only have
> > PXM and APIC id. setup_node(pxm) will get node id for pxm, start from 0...
> >
>
> I was referring to "SART" in your log.

i should copy it instead of type it...

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
