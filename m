Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 61C3D6B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 10:50:48 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id eg20so4650676lab.5
        for <linux-mm@kvack.org>; Wed, 19 Jun 2013 07:50:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013f5cd1c54a-31d71292-c227-4f84-925d-75407a687824-000000@email.amazonses.com>
References: <20130618152302.GA10702@linux.vnet.ibm.com>
	<0000013f58656ee7-8bb24ac4-72fa-4c0b-b888-7c056f261b6e-000000@email.amazonses.com>
	<20130618182616.GT5146@linux.vnet.ibm.com>
	<0000013f5cd1c54a-31d71292-c227-4f84-925d-75407a687824-000000@email.amazonses.com>
Date: Wed, 19 Jun 2013 17:50:46 +0300
Message-ID: <CAOtvUMc5w3zNe8ed6qX0OOM__3F_hOTqvFa1AkdXF0PHvzGZqg@mail.gmail.com>
Subject: Re: vmstat kthreads
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, ghaskins@londonstockexchange.com, niv@us.ibm.com, kravetz@us.ibm.com, Frederic Weisbecker <fweisbec@gmail.com>

On Wed, Jun 19, 2013 at 5:23 PM, Christoph Lameter <cl@linux.com> wrote:
> On Tue, 18 Jun 2013, Paul E. McKenney wrote:
>
>> > Gilad Ben-Yossef has been posting patches that address this issue in Feb
>> > 2012. Ccing him. Can we see your latest work, Gilead?
>>
>> Is it this one?
>>
>> https://lkml.org/lkml/2012/5/3/269
>
> Yes that is it. Maybe the scheme there could be generalized so that other
> subsystems can also use this to disable their threads if nothing is going
> on? Or integrate the monitoring into the notick logic somehow?
>

I respinned the original patch based on feedback from Christoph for
3.2 and even did some light testing then, but got distracted and never
posted the result.

I've just ported them over to 3.10 and they merge (with a small fix
due to deferred workqueue API changes) and build. I did not try to run
this version though.
I'll post them as replies to this message.

I'd be happy to rescue them from the "TODO" pile... :-)

-- 
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
 -- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
