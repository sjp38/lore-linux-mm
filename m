Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD876B1864
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 07:22:28 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id w15so4012754edl.21
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 04:22:27 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gx11-v6si13985839ejb.297.2018.11.19.04.22.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 04:22:26 -0800 (PST)
Subject: Re: [PATCH v1 4/8] xen/balloon: mark inflated pages PG_offline
References: <20181119101616.8901-1-david@redhat.com>
 <20181119101616.8901-5-david@redhat.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <fc69e0cf-c005-472a-b3f6-09d0c963cf52@suse.com>
Date: Mon, 19 Nov 2018 13:22:22 +0100
MIME-Version: 1.0
In-Reply-To: <20181119101616.8901-5-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>

On 19/11/2018 11:16, David Hildenbrand wrote:
> Mark inflated and never onlined pages PG_offline, to tell the world that
> the content is stale and should not be dumped.
> 
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: Juergen Gross <jgross@suse.com>
> Cc: Stefano Stabellini <sstabellini@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/xen/balloon.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index 12148289debd..14dd6b814db3 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -425,6 +425,7 @@ static int xen_bring_pgs_online(struct page *pg, unsigned int order)
>  	for (i = 0; i < size; i++) {
>  		p = pfn_to_page(start_pfn + i);
>  		__online_page_set_limits(p);
> +		__SetPageOffline(p);
>  		__balloon_append(p);
>  	}

This seems not to be based on current master. Could you please tell
against which tree this should be reviewed?


Juergen
