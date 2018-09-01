Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC4F06B5CEB
	for <linux-mm@kvack.org>; Sat,  1 Sep 2018 10:04:09 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d18-v6so18856366qtj.20
        for <linux-mm@kvack.org>; Sat, 01 Sep 2018 07:04:09 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t7-v6si3890000qkc.322.2018.09.01.07.04.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Sep 2018 07:04:08 -0700 (PDT)
Subject: Re: [PATCH RFCv2 0/6] mm: online/offline_pages called w.o.
 mem_hotplug_lock
References: <20180821104418.12710-1-david@redhat.com>
 <20180831205457.GB3945@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <d4b6608b-0b21-b925-4adc-d11e4706f69d@redhat.com>
Date: Sat, 1 Sep 2018 16:03:58 +0200
MIME-Version: 1.0
In-Reply-To: <20180831205457.GB3945@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Haiyang Zhang <haiyangz@microsoft.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, John Allen <jallen@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Len Brown <lenb@kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Mathieu Malaterre <malat@debian.org>, Michael Ellerman <mpe@ellerman.id.au>, Michael Neuling <mikey@neuling.org>, Michal Hocko <mhocko@suse.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Oscar Salvador <osalvador@suse.de>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Philippe Ombredanne <pombredanne@nexb.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Rashmica Gupta <rashmica.g@gmail.com>, Stephen Hemminger <sthemmin@microsoft.com>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>

On 31.08.2018 22:54, Oscar Salvador wrote:
> On Tue, Aug 21, 2018 at 12:44:12PM +0200, David Hildenbrand wrote:
>> This is the same approach as in the first RFC, but this time without
>> exporting device_hotplug_lock (requested by Greg) and with some more
>> details and documentation regarding locking. Tested only on x86 so far.
> 
> Hi David,
> 
> I would like to review this but I am on vacation, so I will not be able to get to it
> soon.
> I plan to do it once I am back.

Sure, I won't be resending within next two weeks either way, as I am
also on vacation.

Have a nice vacation!

> 
> Thanks
> 


-- 

Thanks,

David / dhildenb
