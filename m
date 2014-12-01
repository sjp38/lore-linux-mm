Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id D2C5C6B006E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 12:11:15 -0500 (EST)
Received: by mail-qc0-f177.google.com with SMTP id x3so7935548qcv.36
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 09:11:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k17si21186890qaa.34.2014.12.01.09.11.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Dec 2014 09:11:14 -0800 (PST)
Message-ID: <547CA12A.6010102@redhat.com>
Date: Mon, 01 Dec 2014 12:11:06 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] Expanding OS noise suppression
References: <alpine.DEB.2.11.1411241345250.10694@gentwo.org> <alpine.DEB.2.11.1412011044450.2648@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1412011044450.2648@gentwo.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 12/01/2014 11:45 AM, Christoph Lameter wrote:
> On Mon, 24 Nov 2014, Christoph Lameter wrote:
> 
>> Recently a lot of work has been done in the kernel to be able to
>> keep OS threads off low latency cores with the NOHZ work mainly
>> pushed by Frederic Weisbecker (also also Paul McKenney modifying
>> RCU for that purpose). With that approach we may now reduce the
>> timer tick to a frequency of 1 per second. The result of that
>> work is now available in Redhat 7.
>> 
>> I have recently submitted work on the vmstat kworkers that makes
>> the kworkers run on demand with a shepherd worker checking from a
>> non low latency processor if there is actual work to be done on a
>> processor in low latency mode. If not then the kworker requests
>> can be avoided and therefore activities on that processor are
>> reduced. This approach can be extended to cover other necessary
>> activities on low latency cores.
>> 
>> There is other work in progress to limit unbound kworker threads
>> to no NOHZ processors. Also more work is in flight to work on
>> various issues in the scheduler to enable us to hold off the
>> timer tick for more than one second.
>> 
>> There are numerous other issues that can impact on a low latency
>> core from the memory management system. I would like to discuss
>> ways that we can further ensure that OS activities do not impact
>> latency critical threads running on special nohz cores.
>> 
>> This may cover: - minor and major faults and how to suppress them
>> effectively. - Processor cache impacts by sibling threads. -
>> IPIs - Control over various subsystem specific per cpu threads. -
>> Control impacts of scans for defragmentation and THP on these
>> cores.

This is a very interesting topic, but I am not sure the right audience
for many of these discussions will be at LSF/MM...

Besides the minor and major faults, and the THP related defragmentation,
which of the problems could actually be addressed by the memory
management subsystem?

Would you have a list of other items in the memory management subsystem
that cause latency issues?

Is the minor & major fault thing an actual problem for people with real
time applications?

Do you have any ideas on how we could solve the defragmentation and THP
issue? Even strawman proposals to start a discussion could be useful...

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUfKEqAAoJEM553pKExN6D4n4IAKmEkEHrJkhbaI4xGHHl/Stq
73IWLjd10uLyiTDY2sMn5iKDHpeBLXL63uI8FiPBGO/XBi7YaGdOSGiGUuWLMSzL
oc49dHKI8hMnk9vTG/nRxdrODnRkSgwKudUN6FTe0MwZ9vcDtYXxSTDlN0pMBKKe
hpGHgwUwNzpc/m6gGWdjZ3Dzo5R8WZ84fgdVQlrbjx+9We6XetsbT2CzlxscnKyH
ZgJFae+taqUJt2AN9izeW7cNNRwro3SaS6J9FrO64Y044QCeQ11nyJP2XlAoT7lc
tPv5cOnxXNzBLyulLMHVL1/7jUcx8dfmhdsh8gVpLkL10QypFVS6MhVbyCRZ7dM=
=7AHn
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
