Message-Id: <200304140629.h3E6TPu01387@Port.imtp.ilyichevsk.odessa.ua>
Content-Type: text/plain;
  charset="koi8-r"
From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Reply-To: vda@port.imtp.ilyichevsk.odessa.ua
Subject: Re: 2.5.67-mm2
Date: Mon, 14 Apr 2003 09:24:26 +0300
References: <20030412180852.77b6c5e8.akpm@digeo.com> <20030413151232.D672@nightmaster.csn.tu-chemnitz.de> <1050245689.1422.11.camel@laptop.fenrus.com>
In-Reply-To: <1050245689.1422.11.camel@laptop.fenrus.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: arjanv@redhat.com, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 13 April 2003 17:54, Arjan van de Ven wrote:
> On Sun, 2003-04-13 at 15:12, Ingo Oeser wrote:
> > Hi Andrew,
> > hi lists readers,
> >
> > On Sat, Apr 12, 2003 at 06:08:52PM -0700, Andrew Morton wrote:
> > > +gfp_repeat.patch
> > >
> > >  Implement __GFP_REPEAT: so we can consolidate lots of
> > > alloc-with-retry code.
> >
> > What about reworking the semantics of kmalloc()?
> >
> > Many users of kmalloc get the flags and size reversed (major
> > source of hard to find bugs), so wouldn't it be simpler to have:
>
> that in itself is easy to find btw; just give every GFP_* an extra
> __GFP_REQUIRED bit and then check inside kmalloc for that bit (MSB?)
> to be set.....

This will incur runtime penalty
--
vda
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
