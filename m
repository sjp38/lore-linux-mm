Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 517C86B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 18:14:56 -0400 (EDT)
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 27 Jun 2012 18:14:55 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id B31C438C801F
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 18:14:52 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5RMEqmu225620
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 18:14:52 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5RMEq92007874
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 19:14:52 -0300
Message-ID: <4FEB85CD.4060705@linux.vnet.ibm.com>
Date: Wed, 27 Jun 2012 15:14:37 -0700
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/3] mm/sparse: more check on mem_section number
References: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com> <1340814968-2948-3-git-send-email-shangw@linux.vnet.ibm.com> <alpine.DEB.2.00.1206271506260.22985@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206271506260.22985@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, mhocko@suse.cz, hannes@cmpxchg.org, akpm@linux-foundation.org

On 06/27/2012 03:06 PM, David Rientjes wrote:
>> > +	VM_BUG_ON(root_nr >= NR_SECTION_ROOTS);
>> > +
> VM_BUG_ON(root_nr == NR_SECTION_ROOTS);

Whoops, when I suggested >=, I wasn't reading the context.  I thought
root_nr was an argument, not a for() loop variable.  This isn't exactly
_broken_, but it makes no sense the way the code is now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
