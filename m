Date: Mon, 17 Sep 2007 14:24:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Configurable reclaim batch size
In-Reply-To: <46EEE80D.6060808@linux.vnet.ibm.com>
Message-ID: <Pine.LNX.4.64.0709171423230.29704@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0709141519230.14894@schroedinger.engr.sgi.com>
 <1189812002.5826.31.camel@lappy> <Pine.LNX.4.64.0709171053040.26860@schroedinger.engr.sgi.com>
 <20070917215615.685a5378@lappy> <46EEE80D.6060808@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Sep 2007, Balbir Singh wrote:

> Please do let me know if someone finds a good standard test for it or a
> way to stress reclaim. I've heard AIM7 come up often, but never been
> able to push it much. I should retry.

AIM7 does small computing loads reflecting an earlier time. I wish there 
was something better reflecting large computing loads of today. The tests 
that I know of require MPI and other libraries and are not that suitable 
for kernel hackers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
