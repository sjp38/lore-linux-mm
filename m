Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 05CE68E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 10:19:54 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g11-v6so7051701edi.8
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 07:19:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w46-v6si3118236edm.238.2018.09.10.07.19.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 07:19:48 -0700 (PDT)
Date: Mon, 10 Sep 2018 16:19:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memory_hotplug: fix the panic when memory end is not on
 the section boundary
Message-ID: <20180910141946.GJ10951@dhcp22.suse.cz>
References: <20180910123527.71209-1-zaslonko@linux.ibm.com>
 <20180910131754.GG10951@dhcp22.suse.cz>
 <e8d75768-9122-332b-3b16-cad032aeb27f@microsoft.com>
 <20180910135959.GI10951@dhcp22.suse.cz>
 <CAGM2reZuGAPmfO8x0TnHnqHci_Hsga3-CfM9+udJs=gUQCw-1g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reZuGAPmfO8x0TnHnqHci_Hsga3-CfM9+udJs=gUQCw-1g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: "zaslonko@linux.ibm.com" <zaslonko@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "osalvador@suse.de" <osalvador@suse.de>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>

On Mon 10-09-18 14:11:45, Pavel Tatashin wrote:
> Hi Michal,
> 
> It is tricky, but probably can be done. Either change
> memmap_init_zone() or its caller to also cover the ends and starts of
> unaligned sections to initialize and reserve pages.
> 
> The same thing would also need to be done in deferred_init_memmap() to
> cover the deferred init case.

Well, I am not sure TBH. I have to think about that much more. Maybe it
would be much more simple to make sure that we will never add incomplete
memblocks and simply refuse them during the discovery. At least for now.
-- 
Michal Hocko
SUSE Labs
