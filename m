Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 6A26B6B0034
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 09:58:28 -0400 (EDT)
Date: Thu, 20 Jun 2013 13:58:27 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 2/2] mm: add sysctl to pick vmstat monitor cpu
In-Reply-To: <1371672168-9869-2-git-send-email-gilad@benyossef.com>
Message-ID: <0000013f61e10d68-d5ca253d-d14f-4547-8291-aafa6b596ed7-000000@email.amazonses.com>
References: <CAOtvUMc5w3zNe8ed6qX0OOM__3F_hOTqvFa1AkdXF0PHvzGZqg@mail.gmail.com> <1371672168-9869-2-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frederic Weisbecker <fweisbec@gmail.com>

On Wed, 19 Jun 2013, Gilad Ben-Yossef wrote:

> Add a sysctl knob to enable admin to hand pick the scapegoat cpu
> that will perform the extra work of preiodically checking for
> new VM activity on CPUs that have switched off their vmstat_update
> work item schedling.

Not necessary if we use the dynticks sacrificial processor
(boot cpu). Seems to be also used for RCU.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
