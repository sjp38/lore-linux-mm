Message-ID: <46AE18AE.50305@tigershaunt.com>
Date: Mon, 30 Jul 2007 12:58:22 -0400
From: Rashkae <rashkae@tigershaunt.com>
MIME-Version: 1.0
Subject: Re: [ck] Re: SD still better than CFS for 3d ?(was Re: 2.6.23-rc1)
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>	<1185536610.502.8.camel@localhost> <20070729170641.GA26220@elte.hu>	<930f95dc0707291154j102494d9m58f4cc452c7ff17c@mail.gmail.com>	<20070729204716.GB1578@elte.hu>	<930f95dc0707291431j4e50214di3c01cd44b5597502@mail.gmail.com>	<20070730114649.GB19186@elte.hu> <op.tv90xghwatcbto@linux.site>	<d3380cee0707300831m33d896aufcbdb188576940a2@mail.gmail.com>	<b21f8390707300925i76cb08f2j55bba537cf853f88@mail.gmail.com> <1185814243.7377.2.camel@localhost>
In-Reply-To: <1185814243.7377.2.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: schwidefsky@de.ibm.com
Cc: Matthew Hawkins <darthmdh@gmail.com>, ck@vds.kolivas.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky wrote:

> 
> Do we care ? The code should be replaced with ptep_get_and_clear +
> pte_modify anyway..
> 

Since the general direction of this thread was for people to test 3D 
game performance with the shiny new CFS cpu scheduler, I would say yes, 
we do care if people with the only 2 types of gaming caliber Video cards 
can get said video cards working, right now, with said shiny new kernel.

Yes yes, I know, kernel devs don't care if they break binary drivers... 
and in principle, I agree with that philosophy.. but it's still damn 
inconvenient at times :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
