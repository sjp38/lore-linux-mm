Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id D94816B0255
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 11:41:50 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so118522563wib.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 08:41:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qc8si22087091wjc.78.2015.07.27.08.41.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jul 2015 08:41:49 -0700 (PDT)
Date: Mon, 27 Jul 2015 16:41:46 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: vmemmap_verify() BUGs during memory hotplug (4.2-rc1 regression)
Message-ID: <20150727154146.GP2561@suse.de>
References: <55B64F1D.8090807@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <55B64F1D.8090807@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Jul 27, 2015 at 04:32:45PM +0100, David Vrabel wrote:
> Mel,
> 
> As of commit 8a942fdea560d4ac0e9d9fabcd5201ad20e0c382 (mm: meminit: make
> __early_pfn_to_nid SMP-safe and introduce meminit_pfn_in_nid)
> vmemmap_verify() will BUG_ON() during memory hotplug because of its use
> of early_pfn_to_nid().  Previously, it would have reported bogus (or
> failed to report valid) warnings.
> 

Please test "mm, meminit: Allow early_pfn_to_nid to be used during
runtime"

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
