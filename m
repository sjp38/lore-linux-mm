Date: Mon, 14 Apr 2003 08:49:04 +0000
From: Arjan van de Ven <arjanv@redhat.com>
Subject: Re: 2.5.67-mm2
Message-ID: <20030414084904.A15608@devserv.devel.redhat.com>
References: <20030412180852.77b6c5e8.akpm@digeo.com> <20030413151232.D672@nightmaster.csn.tu-chemnitz.de> <1050245689.1422.11.camel@laptop.fenrus.com> <200304140629.h3E6TPu01387@Port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200304140629.h3E6TPu01387@Port.imtp.ilyichevsk.odessa.ua>; from vda@port.imtp.ilyichevsk.odessa.ua on Mon, Apr 14, 2003 at 09:24:26AM +0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Cc: arjanv@redhat.com, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 14, 2003 at 09:24:26AM +0300, Denis Vlasenko wrote:
> >
> > that in itself is easy to find btw; just give every GFP_* an extra
> > __GFP_REQUIRED bit and then check inside kmalloc for that bit (MSB?)
> > to be set.....
> 
> This will incur runtime penalty

but only for CONFIG_DEBUG_KMALLOC or whatever
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
