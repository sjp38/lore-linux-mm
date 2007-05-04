Subject: RE: Regression with SLUB on Netperf and Volanomark
From: Tim Chen <tim.c.chen@linux.intel.com>
Reply-To: tim.c.chen@linux.intel.com
In-Reply-To: <Pine.LNX.4.64.0705031839480.16296@schroedinger.engr.sgi.com>
References: <9D2C22909C6E774EBFB8B5583AE5291C02786032@fmsmsx414.amr.corp.intel.com>
	 <Pine.LNX.4.64.0705031839480.16296@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 04 May 2007 16:41:23 -0700
Message-Id: <1178322083.23795.217.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Chen, Tim C" <tim.c.chen@intel.com>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "Wang, Peter Xihong" <peter.xihong.wang@intel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-03 at 18:45 -0700, Christoph Lameter wrote:
> Hmmmm.. One potential issues are the complicated way the slab is 
> handled. Could you try this patch and see what impact it has?
> 
The patch boost the throughput of TCP_STREAM test by 5%, for both slab
and slub.  But slab is still 5% better in my tests.

> If it has any then remove the cachline alignment and see how that 
> influences things.

Removing the cacheline alignment didn't change the throughput.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
