Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7VJpaap001612
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 15:51:36 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7VJpYX9274958
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 15:51:36 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7VJpXim000737
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 15:51:34 -0400
Subject: Re: [RFC][PATCH 2/9] conditionally define generic get_order()
	(ARCH_HAS_GET_ORDER)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1defaf580608311141j39aa87e5ldf80db1db54b2edf@mail.gmail.com>
References: <20060830221604.E7320C0F@localhost.localdomain>
	 <20060830221605.CFC342D7@localhost.localdomain>
	 <1defaf580608311141j39aa87e5ldf80db1db54b2edf@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 31 Aug 2006 12:51:23 -0700
Message-Id: <1157053883.28577.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Haavard Skinnemoen <hskinnemoen@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-08-31 at 20:41 +0200, Haavard Skinnemoen wrote:
> On 8/31/06, Dave Hansen <haveblue@us.ibm.com> wrote:
> > diff -puN mm/Kconfig~generic-get_order mm/Kconfig
> > --- threadalloc/mm/Kconfig~generic-get_order    2006-08-30 15:14:56.000000000 -0700
> > +++ threadalloc-dave/mm/Kconfig 2006-08-30 15:15:00.000000000 -0700
> > @@ -1,3 +1,7 @@
> > +config ARCH_HAVE_GET_ORDER
> > +       def_bool y
> > +       depends on IA64 || PPC32 || XTENSA
> > +
> 
> I have a feeling this has been discussed before, but wouldn't it be
> better to let each architecture define this in its own Kconfig?

As long as the conditions are simple, I think it would be nice to keep
it this way.  It makes it pretty obvious to tell what is going on from
_one_ place.  

> At some point, I have to add AVR32 to that list, and if one or more
> other architectures need to do the same, there will be rejects.

True, there will be rejects.  But, do you think they will actually take
more than a moment to merge?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
