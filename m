Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id DA9636B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 10:23:40 -0400 (EDT)
Date: Wed, 19 Jun 2013 14:23:39 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmstat kthreads
In-Reply-To: <20130618182616.GT5146@linux.vnet.ibm.com>
Message-ID: <0000013f5cd1c54a-31d71292-c227-4f84-925d-75407a687824-000000@email.amazonses.com>
References: <20130618152302.GA10702@linux.vnet.ibm.com> <0000013f58656ee7-8bb24ac4-72fa-4c0b-b888-7c056f261b6e-000000@email.amazonses.com> <20130618182616.GT5146@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: gilad@benyossef.com, linux-mm@kvack.org, ghaskins@londonstockexchange.com, niv@us.ibm.com, kravetz@us.ibm.com, Frederic Weisbecker <fweisbec@gmail.com>

On Tue, 18 Jun 2013, Paul E. McKenney wrote:

> > Gilad Ben-Yossef has been posting patches that address this issue in Feb
> > 2012. Ccing him. Can we see your latest work, Gilead?
>
> Is it this one?
>
> https://lkml.org/lkml/2012/5/3/269

Yes that is it. Maybe the scheme there could be generalized so that other
subsystems can also use this to disable their threads if nothing is going
on? Or integrate the monitoring into the notick logic somehow?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
