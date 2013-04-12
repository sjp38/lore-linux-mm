Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 5F5946B0002
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 14:07:07 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 12 Apr 2013 14:07:05 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 4618438C801C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 14:07:02 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3CI6xWx343594
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 14:07:00 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3CI8OZ5009958
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 12:08:25 -0600
Date: Fri, 12 Apr 2013 11:05:36 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
Message-ID: <20130412180536.GH29861@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <alpine.LNX.2.00.1304021600420.22412@eggly.anvils>
 <alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
 <20130403041447.GC4611@cmpxchg.org>
 <alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com>
 <20130403045814.GD4611@cmpxchg.org>
 <CAKOQZ8wPBO7so_b=4RZvUa38FY8kMzJcS5ZDhhS5+-r_krOAYw@mail.gmail.com>
 <20130403163348.GD28522@linux.vnet.ibm.com>
 <CAKOQZ8wd24AUCN2c6p9iLFeHMpJy=jRO2xoiKkH93k=+iYQpEA@mail.gmail.com>
 <20130403221129.GL28522@linux.vnet.ibm.com>
 <CAKOQZ8yFq5V1mZGrR_n7WqbgJ92WnpKO-ZvYY2n5Rn8+cjk0ew@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOQZ8yFq5V1mZGrR_n7WqbgJ92WnpKO-ZvYY2n5Rn8+cjk0ew@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Lance Taylor <iant@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org

On Wed, Apr 03, 2013 at 03:28:35PM -0700, Ian Lance Taylor wrote:
> On Wed, Apr 3, 2013 at 3:11 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> >
> > How about a request for gcc to formally honor the current uses of volatile?
> 
> Seems harder to define, but, sure, if it can be made to work.

Actually, I am instead preparing to take this up with the standards
committee.  Even those who hate volatile (of which there are many) have
an interest in a good codification of the defacto definition of volatile.
After all, without a definition how can they hope to replace it?  ;-)
And the C committee cares deeply about backwards compatibility, so
getting a good definition will help there as well.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
