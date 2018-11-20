Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE8836B2071
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 09:27:43 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id k90so111206qte.0
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 06:27:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s16si3303747qtk.382.2018.11.20.06.27.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 06:27:43 -0800 (PST)
Subject: Re: [RFC PATCH 1/3] mm, memory_hotplug: try to migrate full section
 worth of pages
References: <20181120134323.13007-1-mhocko@kernel.org>
 <20181120134323.13007-2-mhocko@kernel.org>
 <65271adc-93b4-19fc-e54b-11db582359c5@redhat.com>
 <20181120142517.GL22247@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <e7935648-104d-a0b8-f5ad-4460f2815b9b@redhat.com>
Date: Tue, 20 Nov 2018 15:27:40 +0100
MIME-Version: 1.0
In-Reply-To: <20181120142517.GL22247@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, LKML <linux-kernel@vger.kernel.org>

On 20.11.18 15:25, Michal Hocko wrote:
> On Tue 20-11-18 15:18:41, David Hildenbrand wrote:
> [...]
>> (we could also check for pending signals inside that function if really
>> required)
> 
> do_migrate_pages is not the proper layer to check signals. Because the
> loop only isolates pages and that is not expensive. The most expensive
> part is deeper down in the migration core. We wait for page lock or
> writeback and that can take a long. None of that is killable wait which
> is a larger surgery but something that we should consider should there
> be any need to address this.

Indeed, that makes sense.

> 
>> Reviewed-by: David Hildenbrand <david@redhat.com>
> 
> Thanks!
> 


-- 

Thanks,

David / dhildenb
