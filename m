Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k3RKuC8j021120
	for <linux-mm@kvack.org>; Thu, 27 Apr 2006 16:56:12 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3RKuCBg164086
	for <linux-mm@kvack.org>; Thu, 27 Apr 2006 14:56:12 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k3RKuCeM008085
	for <linux-mm@kvack.org>; Thu, 27 Apr 2006 14:56:12 -0600
Received: from austin.ibm.com (netmail1.austin.ibm.com [9.41.248.175])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id k3RKu21U007719
	for <linux-mm@kvack.org>; Thu, 27 Apr 2006 14:56:11 -0600
Message-ID: <44512FC5.6090808@austin.ibm.com>
Date: Thu, 27 Apr 2006 15:55:33 -0500
From: jschopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: Page host virtual assist patches.
References: <20060424123412.GA15817@skybase>	 <20060424180138.52e54e5c.akpm@osdl.org>  <444DCD87.2030307@yahoo.com.au>	 <1145953914.5282.21.camel@localhost>  <444DF447.4020306@yahoo.com.au> <1145964531.5282.59.camel@localhost>
In-Reply-To: <1145964531.5282.59.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: schwidefsky@de.ibm.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

> Which simple approach do you mean? The guest ballooner? That works
> reasonably well for a small number of guests. If you keep adding guests
> the overhead for the guest calls increases. Ultimately we believe that a
> combination of the ballooner method and the new hva method will yield
> the best results.

Don't forget memory hotplug in your combination mix. Your ballooner fragments the hell out 
of your memory, and your hva method requires some work to keep the state updated.  Memory 
hotplug on the other hand suffers from neither of those problems.

That said, I rather like the hva method.  It's quite clever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
