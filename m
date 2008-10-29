Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9TI0dm9026421
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 14:00:39 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9TI0dSc059314
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 14:00:39 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9TI0WF6021956
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 14:00:32 -0400
Message-ID: <4908A4CC.3000300@austin.ibm.com>
Date: Wed, 29 Oct 2008 13:00:44 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory hotplug: fix page_zone() calculation in	test_pages_isolated()
References: <1225290330.10021.7.camel@t60p>
In-Reply-To: <1225290330.10021.7.camel@t60p>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: gerald.schaefer@de.ibm.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, y-goto@jp.fujitsu.com, dave@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Looks like you beat me to it, and with a nicer fix too.

Gerald Schaefer wrote:
> From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> 
> My last bugfix here (adding zone->lock) introduced a new problem: Using
> page_zone(pfn_to_page(pfn)) to get the zone after the for() loop is wrong.
> pfn will then be >= end_pfn, which may be in a different zone or not
> present at all. This may lead to an addressing exception in page_zone()
> or spin_lock_irqsave().
> 
> Now I use __first_valid_page() again after the loop to find a valid page
> for page_zone().
> 
> Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>

Acked-by: Nathan Fontenot <nfont@austin.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
