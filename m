Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id A53946B002B
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 10:17:49 -0500 (EST)
Received: by mail-vc0-f169.google.com with SMTP id gb23so2549936vcb.14
        for <linux-mm@kvack.org>; Thu, 13 Dec 2012 07:17:48 -0800 (PST)
Message-ID: <50C9F19D.8060209@gmail.com>
Date: Thu, 13 Dec 2012 10:17:49 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add node physical memory range to sysfs
References: <1354919696.2523.6.camel@buesod1.americas.hpqcorp.net> <20121207155125.d3117244.akpm@linux-foundation.org> <50C28720.3070205@linux.vnet.ibm.com> <1355361524.5255.9.camel@buesod1.americas.hpqcorp.net> <50C933E9.2040707@linux.vnet.ibm.com> <1355364222.9244.3.camel@buesod1.americas.hpqcorp.net> <50C95E4A.9010509@linux.vnet.ibm.com>
In-Reply-To: <50C95E4A.9010509@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@gmail.com

(12/12/12 11:49 PM), Dave Hansen wrote:
> On 12/12/2012 06:03 PM, Davidlohr Bueso wrote:
>> On Wed, 2012-12-12 at 17:48 -0800, Dave Hansen wrote:
>>> But if we went and did it per-DIMM (showing which physical addresses and
>>> NUMA nodes a DIMM maps to), wouldn't that be redundant with this
>>> proposed interface?
>>
>> If DIMMs overlap between nodes, then we wouldn't have an exact range for
>> a node in question. Having both approaches would complement each other.
> 
> How is that possible?  If NUMA nodes are defined by distances from CPUs
> to memory, how could a DIMM have more than a single distance to any
> given CPU?

numa_emulation? just guess.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
