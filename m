Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 95D5B6B0005
	for <linux-mm@kvack.org>; Mon,  9 May 2016 16:12:00 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id zy2so321383162pac.1
        for <linux-mm@kvack.org>; Mon, 09 May 2016 13:12:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id lc4si40617614pab.144.2016.05.09.13.11.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 May 2016 13:11:59 -0700 (PDT)
Date: Mon, 9 May 2016 13:11:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] memory-hotplug: improve rezoning capability
Message-Id: <20160509131158.d5429d4dba4a24c5b1aac9ca@linux-foundation.org>
In-Reply-To: <1462816419-4479-1-git-send-email-arbab@linux.vnet.ibm.com>
References: <1462816419-4479-1-git-send-email-arbab@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Tang Chen <tangchen@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Vrabel <david.vrabel@citrix.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Banman <abanman@sgi.com>, Chen Yucong <slaoub@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yasunori Goto <y-goto@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Shaohua Li <shaohua.li@intel.com>

On Mon,  9 May 2016 12:53:36 -0500 Reza Arbab <arbab@linux.vnet.ibm.com> wrote:

> While it is currently possible to rezone memory when it is onlined, there are
> implicit assumptions about the zones:
> 
> * To "online_kernel" a block into ZONE_NORMAL, it must currently
>   be in ZONE_MOVABLE.
> 
> * To "online_movable" a block into ZONE_MOVABLE, it must currently
>   be in (ZONE_MOVABLE - 1).
> 
> So on powerpc, where new memory is hotplugged into ZONE_DMA, these operations
> do not work.
> 
> This patchset replaces the qualifications above with a more general
> validation of zone movement.
> 

The patches look good from a first scan.  It's late for 4.6 so I'll
queue them for 4.7-rc1, unless there are convincing reasons otherwise?

Hopefully the other memory-hotplug developers will be able to find time
to review these.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
