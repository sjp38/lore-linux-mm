Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0876B0274
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 18:06:00 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id s123-v6so40710949qkf.12
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 15:06:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v9si9003812qkv.68.2018.11.14.15.05.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 15:05:59 -0800 (PST)
Subject: Re: [PATCH RFC 0/6] mm/kdump: allow to exclude pages that are
 logically offline
References: <20181114211704.6381-1-david@redhat.com>
 <8932E1F4-A5A9-4462-9800-CAC1EF85AC5D@vmware.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <63c5f4b6-828a-764e-f64d-e603dc4b104e@redhat.com>
Date: Thu, 15 Nov 2018 00:05:38 +0100
MIME-Version: 1.0
In-Reply-To: <8932E1F4-A5A9-4462-9800-CAC1EF85AC5D@vmware.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>, linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, xen-devel <xen-devel@lists.xenproject.org>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Baoquan He <bhe@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Christian Hansen <chansen3@cisco.com>, Dave Young <dyoung@redhat.com>, David Rientjes <rientjes@google.com>, Haiyang Zhang <haiyangz@microsoft.com>, Jonathan Corbet <corbet@lwn.net>, Juergen Gross <jgross@suse.com>, Kairui Song <kasong@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Len Brown <len.brown@intel.com>, Matthew Wilcox <willy@infradead.org>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Miles Chen <miles.chen@mediatek.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Omar Sandoval <osandov@fb.com>, Pavel Machek <pavel@ucw.cz>, Pavel Tatashin <pasha.tatashin@oracle.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Stefano Stabellini <sstabellini@kernel.org>, Stephen Hemminger <sthemmin@microsoft.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Vitaly Kuznetsov <vkuznets@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Julien Freche <jfreche@vmware.com>

On 14.11.18 23:57, Nadav Amit wrote:
> From: David Hildenbrand
> Sent: November 14, 2018 at 9:16:58 PM GMT
>> Subject: [PATCH RFC 0/6] mm/kdump: allow to exclude pages that are logically offline
>>
>>
>> Right now, pages inflated as part of a balloon driver will be dumped
>> by dump tools like makedumpfile. While XEN is able to check in the
>> crash kernel whether a certain pfn is actuall backed by memory in the
>> hypervisor (see xen_oldmem_pfn_is_ram) and optimize this case, dumps of
>> virtio-balloon and hv-balloon inflated memory will essentially result in
>> zero pages getting allocated by the hypervisor and the dump getting
>> filled with this data.
> 
> Is there any reason that VMware balloon driver is not mentioned?

Definitely ...

... not ;) . I haven't looked at vmware's balloon driver yet (I only saw
that there was quite some activity recently). I guess it should have
similar problems. (I mean reading and dumping data nobody cares about is
certainly not desired)

Can you share if something like this is also desired for vmware's
implementation? (I tagged this as RFC to get some more feedback)

It should in theory be as simple as adding a handful of
_SetPageOffline()/_ClearPageOffline() at the right spots.

-- 

Thanks,

David / dhildenb
