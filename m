Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id CB4506B0037
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 11:00:42 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 19 Jun 2013 11:00:41 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 8962CC90041
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 11:00:36 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5JExYln236886
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 10:59:34 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5JF1egW006120
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 09:01:41 -0600
Date: Wed, 19 Jun 2013 07:59:07 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: vmstat kthreads
Message-ID: <20130619145906.GB5146@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20130618152302.GA10702@linux.vnet.ibm.com>
 <0000013f58656ee7-8bb24ac4-72fa-4c0b-b888-7c056f261b6e-000000@email.amazonses.com>
 <20130618182616.GT5146@linux.vnet.ibm.com>
 <0000013f5cd1c54a-31d71292-c227-4f84-925d-75407a687824-000000@email.amazonses.com>
 <CAOtvUMc5w3zNe8ed6qX0OOM__3F_hOTqvFa1AkdXF0PHvzGZqg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOtvUMc5w3zNe8ed6qX0OOM__3F_hOTqvFa1AkdXF0PHvzGZqg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, ghaskins@londonstockexchange.com, niv@us.ibm.com, kravetz@us.ibm.com, Frederic Weisbecker <fweisbec@gmail.com>

On Wed, Jun 19, 2013 at 05:50:46PM +0300, Gilad Ben-Yossef wrote:
> On Wed, Jun 19, 2013 at 5:23 PM, Christoph Lameter <cl@linux.com> wrote:
> > On Tue, 18 Jun 2013, Paul E. McKenney wrote:
> >
> >> > Gilad Ben-Yossef has been posting patches that address this issue in Feb
> >> > 2012. Ccing him. Can we see your latest work, Gilead?
> >>
> >> Is it this one?
> >>
> >> https://lkml.org/lkml/2012/5/3/269
> >
> > Yes that is it. Maybe the scheme there could be generalized so that other
> > subsystems can also use this to disable their threads if nothing is going
> > on? Or integrate the monitoring into the notick logic somehow?
> >
> 
> I respinned the original patch based on feedback from Christoph for
> 3.2 and even did some light testing then, but got distracted and never
> posted the result.
> 
> I've just ported them over to 3.10 and they merge (with a small fix
> due to deferred workqueue API changes) and build. I did not try to run
> this version though.
> I'll post them as replies to this message.
> 
> I'd be happy to rescue them from the "TODO" pile... :-)

Please!  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
