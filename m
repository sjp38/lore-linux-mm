Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id B8CE06B198D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 08:07:25 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id n68so68084653qkn.8
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 05:07:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i17si7943416qte.298.2018.11.19.05.07.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 05:07:24 -0800 (PST)
Subject: Re: [PATCH v1 4/8] xen/balloon: mark inflated pages PG_offline
References: <20181119101616.8901-1-david@redhat.com>
 <20181119101616.8901-5-david@redhat.com>
 <fc69e0cf-c005-472a-b3f6-09d0c963cf52@suse.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <554d4e68-8fa9-6849-8480-fc9446bea79d@redhat.com>
Date: Mon, 19 Nov 2018 14:07:18 +0100
MIME-Version: 1.0
In-Reply-To: <fc69e0cf-c005-472a-b3f6-09d0c963cf52@suse.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>

On 19.11.18 13:22, Juergen Gross wrote:
> On 19/11/2018 11:16, David Hildenbrand wrote:
>> Mark inflated and never onlined pages PG_offline, to tell the world that
>> the content is stale and should not be dumped.
>>
>> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
>> Cc: Juergen Gross <jgross@suse.com>
>> Cc: Stefano Stabellini <sstabellini@kernel.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: "Michael S. Tsirkin" <mst@redhat.com>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>>  drivers/xen/balloon.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
>> index 12148289debd..14dd6b814db3 100644
>> --- a/drivers/xen/balloon.c
>> +++ b/drivers/xen/balloon.c
>> @@ -425,6 +425,7 @@ static int xen_bring_pgs_online(struct page *pg, unsigned int order)
>>  	for (i = 0; i < size; i++) {
>>  		p = pfn_to_page(start_pfn + i);
>>  		__online_page_set_limits(p);
>> +		__SetPageOffline(p);
>>  		__balloon_append(p);
>>  	}
> 
> This seems not to be based on current master. Could you please tell
> against which tree this should be reviewed?
> 
Hi Juergen,

this is based on linux-next/master.

Thanks!

> 
> Juergen
> 


-- 

Thanks,

David / dhildenb
