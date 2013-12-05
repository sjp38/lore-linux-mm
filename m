Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 001B26B0035
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 16:00:22 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id md12so26450035pbc.5
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 13:00:22 -0800 (PST)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id il5si43879312pbb.324.2013.12.05.13.00.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 13:00:21 -0800 (PST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <benh@au1.ibm.com>;
	Fri, 6 Dec 2013 07:00:18 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 14BC12CE8053
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 08:00:10 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB5KfsoX44630074
	for <linux-mm@kvack.org>; Fri, 6 Dec 2013 07:41:54 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB5L08GZ002989
	for <linux-mm@kvack.org>; Fri, 6 Dec 2013 08:00:08 +1100
Message-ID: <1386277201.21910.44.camel@pasglop>
Subject: Re: [PATCH -V2 3/5] mm: Move change_prot_numa outside
 CONFIG_ARCH_USES_NUMA_PROT_NONE
From: Benjamin Herrenschmidt <benh@au1.ibm.com>
Date: Fri, 06 Dec 2013 08:00:01 +1100
In-Reply-To: <52A0B786.608@redhat.com>
References: 
	<1384766893-10189-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1384766893-10189-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1386126782.16703.137.camel@pasglop> <52A0B786.608@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Thu, 2013-12-05 at 12:27 -0500, Rik van Riel wrote:

> However, it appears that since the code was #ifdefed
> like that, the called code was made generic enough,
> that change_prot_numa should actually work for
> everything.
> 
> In other words:
> 
> Reviewed-by: Rik van Riel <riel@redhat.com>

Ok thanks, that's what I needed. Do you have any objection of me merging
that change via the powerpc tree along with the corresponding powerpc
bits from Aneesh ?

The other option would be to have it in a topic branch that I pull from
you.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
