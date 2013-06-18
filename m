Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 09A106B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 13:46:51 -0400 (EDT)
Date: Tue, 18 Jun 2013 17:46:50 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: vmstat kthreads
In-Reply-To: <20130618152302.GA10702@linux.vnet.ibm.com>
Message-ID: <0000013f58656ee7-8bb24ac4-72fa-4c0b-b888-7c056f261b6e-000000@email.amazonses.com>
References: <20130618152302.GA10702@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gilad@benyossef.com
Cc: linux-mm@kvack.org, ghaskins@londonstockexchange.com, niv@us.ibm.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, kravetz@us.ibm.com

On Tue, 18 Jun 2013, Paul E. McKenney wrote:

> I have been digging around the vmstat kthreads a bit, and it appears to
> me that there is no reason to run a given CPU's vmstat kthread unless
> that CPU spends some time executing in the kernel.  If correct, this
> observation indicates that one way to safely reduce OS jitter due to the
> vmstat kthreads is to prevent them from executing on a given CPU if that
> CPU has been executing in usermode since the last time that this CPU's
> vmstat kthread executed.

Right and we have patches to that effect.

> Does this seem like a sensible course of action, or did I miss something
> when I went through the code?

Nope you are right on.

Gilad Ben-Yossef has been posting patches that address this issue in Feb
2012. Ccing him. Can we see your latest work, Gilead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
