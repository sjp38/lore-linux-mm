Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 3CF116B0033
	for <linux-mm@kvack.org>; Wed, 28 Aug 2013 15:28:03 -0400 (EDT)
Date: Wed, 28 Aug 2013 19:28:02 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 1/2] mm: make vmstat_update periodic run conditional
In-Reply-To: <CAOtvUMdPswm3pHesXAzLYA4c7yzsXKoRoOt2T3LWBCjZ86ybpg@mail.gmail.com>
Message-ID: <00000140c6659902-f76c4733-ff61-47d9-b0d2-69fd04253aa3-000000@email.amazonses.com>
References: <CAOtvUMc5w3zNe8ed6qX0OOM__3F_hOTqvFa1AkdXF0PHvzGZqg@mail.gmail.com> <1371672168-9869-1-git-send-email-gilad@benyossef.com> <0000013f61e7609b-a8d1907b-8169-4f77-ab83-a624a8d0ab4a-000000@email.amazonses.com> <CAOtvUMe=QQni4Ouu=P_vh8QSb4ZdnaX_fW1twn3QFcOjYgJBGA@mail.gmail.com>
 <000001405e70a92f-3b2a0b89-f807-45d7-af70-9e7292156dd4-000000@email.amazonses.com> <CAOtvUMdPswm3pHesXAzLYA4c7yzsXKoRoOt2T3LWBCjZ86ybpg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frederic Weisbecker <fweisbec@gmail.com>

On Fri, 9 Aug 2013, Gilad Ben-Yossef wrote:

> If the code does not consider setting the vmstat_cpus bit in the mask
> unless we are running
> on a CPU in tickless state, than we will (almost) never set
> vmstat_cpus since we will (almost)
> never be tickless in a deferrable work -

Sorry never got around to answering this one. Not sure what to do about
it.

How about this: Disable the vmstats when there is no diff to handle
instead?  This means that the OS was quiet during the earlier period. That
way you have an independent criteria for switching vmstat work off from
tickless. Would even work when there are multiple processes running on the
processor if none of them causes counter updates.

In the meantime there are additional patches for the vmstat function
pending for merge from me (not related to the conditional running of
vmstat but may make it easier to implement). So if you want to do any work
then please on top of the newer release available from Andrew's tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
