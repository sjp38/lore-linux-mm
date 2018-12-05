Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C110B6B73F3
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 05:59:52 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id t72so16442688pfi.21
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 02:59:52 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h36si17454880pgm.200.2018.12.05.02.59.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 02:59:51 -0800 (PST)
Date: Wed, 5 Dec 2018 11:59:49 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v1] drivers/base/memory.c: Use DEVICE_ATTR_RO and friends
Message-ID: <20181205105949.GD16376@kroah.com>
References: <20181203111611.10633-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203111611.10633-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rafael@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Oscar Salvador <osalvador@suse.com>, Michal Hocko <mhocko@kernel.org>, Wei Yang <richard.weiyang@gmail.com>

On Mon, Dec 03, 2018 at 12:16:11PM +0100, David Hildenbrand wrote:
> Let's use the easier to read (and not mess up) variants:
> - Use DEVICE_ATTR_RO
> - Use DEVICE_ATTR_WO
> - Use DEVICE_ATTR_RW
> instead of the more generic DEVICE_ATTR() we're using right now.
> 
> We have to rename most callback functions. By fixing the intendations we
> can even save some LOCs.
> 
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
> Cc: Oscar Salvador <osalvador@suse.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> Reviewed-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  drivers/base/memory.c | 79 ++++++++++++++++++++-----------------------
>  1 file changed, 36 insertions(+), 43 deletions(-)

Thanks, I'll take this through my tree.

greg k-h
