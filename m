Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 161726B0071
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 18:57:44 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 24 Oct 2012 16:57:43 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id A21803E4003D
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 16:57:37 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9OMvb9k252920
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 16:57:37 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9OMvZbc024300
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 16:57:37 -0600
Message-ID: <5088725B.2090700@linux.vnet.ibm.com>
Date: Wed, 24 Oct 2012 15:57:31 -0700
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] add some drop_caches documentation and info messsge
References: <20121012125708.GJ10110@dhcp22.suse.cz> <20121023164546.747e90f6.akpm@linux-foundation.org> <20121024062938.GA6119@dhcp22.suse.cz> <20121024125439.c17a510e.akpm@linux-foundation.org> <50884F63.8030606@linux.vnet.ibm.com> <20121024134836.a28d223a.akpm@linux-foundation.org> <20121024210600.GA17037@liondog.tnic> <50885B2E.5050500@linux.vnet.ibm.com> <20121024224817.GB8828@liondog.tnic>
In-Reply-To: <20121024224817.GB8828@liondog.tnic>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On 10/24/2012 03:48 PM, Borislav Petkov wrote:
> On Wed, Oct 24, 2012 at 02:18:38PM -0700, Dave Hansen wrote:
>> Sounds fairly valid to me. But, it's also one that would not be harmed
>> or disrupted in any way because of a single additional printk() during
>> each suspend-to-disk operation.
> 
> back to the drop_caches patch. How about we hide the drop_caches
> interface behind some mm debugging option in "Kernel Hacking"? Assuming
> we don't need it otherwise on production kernels. Probably make it
> depend on CONFIG_DEBUG_VM like CONFIG_DEBUG_VM_RB or so.
> 
> And then also add it to /proc/vmstat, in addition.

That effectively means removing it from the kernel since distros ship
with those config options off.  We don't want to do that since there
_are_ valid, occasional uses like benchmarking that we want to be
consistent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
