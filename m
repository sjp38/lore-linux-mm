Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 27F196B0070
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 20:57:06 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so1351275oag.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 17:57:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5088725B.2090700@linux.vnet.ibm.com>
References: <20121012125708.GJ10110@dhcp22.suse.cz> <20121023164546.747e90f6.akpm@linux-foundation.org>
 <20121024062938.GA6119@dhcp22.suse.cz> <20121024125439.c17a510e.akpm@linux-foundation.org>
 <50884F63.8030606@linux.vnet.ibm.com> <20121024134836.a28d223a.akpm@linux-foundation.org>
 <20121024210600.GA17037@liondog.tnic> <50885B2E.5050500@linux.vnet.ibm.com>
 <20121024224817.GB8828@liondog.tnic> <5088725B.2090700@linux.vnet.ibm.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 24 Oct 2012 20:56:45 -0400
Message-ID: <CAHGf_=pfdgoeG5pPJb+UgjqfieU1yxt=46FGW1=th0RbgVKNRQ@mail.gmail.com>
Subject: Re: [PATCH] add some drop_caches documentation and info messsge
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 24, 2012 at 6:57 PM, Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> On 10/24/2012 03:48 PM, Borislav Petkov wrote:
>> On Wed, Oct 24, 2012 at 02:18:38PM -0700, Dave Hansen wrote:
>>> Sounds fairly valid to me. But, it's also one that would not be harmed
>>> or disrupted in any way because of a single additional printk() during
>>> each suspend-to-disk operation.
>>
>> back to the drop_caches patch. How about we hide the drop_caches
>> interface behind some mm debugging option in "Kernel Hacking"? Assuming
>> we don't need it otherwise on production kernels. Probably make it
>> depend on CONFIG_DEBUG_VM like CONFIG_DEBUG_VM_RB or so.
>>
>> And then also add it to /proc/vmstat, in addition.
>
> That effectively means removing it from the kernel since distros ship
> with those config options off.  We don't want to do that since there
> _are_ valid, occasional uses like benchmarking that we want to be
> consistent.

Agreed. we don't want to remove valid interface never.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
