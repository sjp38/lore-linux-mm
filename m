Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id DC4B26B2FAE
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 08:41:46 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c53so5889095edc.9
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:41:46 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c43si754280edc.97.2018.11.23.05.41.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 05:41:45 -0800 (PST)
Subject: Re: [PATCH v2 4/8] xen/balloon: mark inflated pages PG_offline
References: <20181122100627.5189-1-david@redhat.com>
 <20181122100627.5189-5-david@redhat.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <3d5250b7-870e-e702-a6e4-937d2362fea4@suse.com>
Date: Fri, 23 Nov 2018 14:41:43 +0100
MIME-Version: 1.0
In-Reply-To: <20181122100627.5189-5-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>

On 22/11/2018 11:06, David Hildenbrand wrote:
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

Reviewed-by: Juergen Gross <jgross@suse.com>


Juergen
