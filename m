Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id C7BF06B0036
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:10:45 -0500 (EST)
Received: by mail-qc0-f176.google.com with SMTP id e16so4531324qcx.35
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:10:45 -0800 (PST)
Received: from qmta03.emeryville.ca.mail.comcast.net (qmta03.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:32])
        by mx.google.com with ESMTP id a3si836592qam.74.2014.02.06.07.35.12
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 07:35:42 -0800 (PST)
Date: Thu, 6 Feb 2014 09:35:07 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 48/51] mm, vmstat: Fix CPU hotplug callback
 registration
In-Reply-To: <20140205221322.19080.63386.stgit@srivatsabhat.in.ibm.com>
Message-ID: <alpine.DEB.2.10.1402060934460.31869@nuc>
References: <20140205220251.19080.92336.stgit@srivatsabhat.in.ibm.com> <20140205221322.19080.63386.stgit@srivatsabhat.in.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: paulus@samba.org, oleg@redhat.com, rusty@rustcorp.com.au, peterz@infradead.org, tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>, mingo@kernel.org, paulmck@linux.vnet.ibm.com, tj@kernel.org, walken@google.com, ego@linux.vnet.ibm.com, linux@arm.linux.org.uk, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Toshi Kani <toshi.kani@hp.com>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org

On Thu, 6 Feb 2014, Srivatsa S. Bhat wrote:

> Fix the vmstat code in the MM subsystem by using this latter form of callback
> registration.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
