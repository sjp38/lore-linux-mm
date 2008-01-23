Received: by rv-out-0910.google.com with SMTP id l15so2104341rvb.26
        for <linux-mm@kvack.org>; Wed, 23 Jan 2008 00:19:34 -0800 (PST)
Message-ID: <84144f020801230019i5ac6c8b1lfa5364672988b0c4@mail.gmail.com>
Date: Wed, 23 Jan 2008 10:19:33 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: crash in kmem_cache_init
In-Reply-To: <Pine.LNX.4.64.0801221517260.2871@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0801171049190.21058@schroedinger.engr.sgi.com>
	 <20080118225713.GA31128@aepfle.de> <20080122195448.GA15567@csn.ul.ie>
	 <Pine.LNX.4.64.0801221203340.27950@schroedinger.engr.sgi.com>
	 <20080122212654.GB15567@csn.ul.ie>
	 <Pine.LNX.4.64.0801221330390.1652@schroedinger.engr.sgi.com>
	 <20080122225046.GA866@csn.ul.ie> <47967560.8080101@cs.helsinki.fi>
	 <Pine.LNX.4.64.0801221501240.2565@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0801221517260.2871@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Olaf Hering <olaf@aepfle.de>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Jan 23, 2008 1:18 AM, Christoph Lameter <clameter@sgi.com> wrote:
> My patch is useless (fascinating history of the changelog there through).
> fallback_alloc calls kmem_getpages without GFP_THISNODE. This means that
> alloc_pages_node() will try to allocate on the current node but fallback
> to neighboring node if nothing is there....

Sure, but I was referring to the scenario where current node _has_
pages available but no ->nodelists. Olaf, did you try it?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
