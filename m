Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 700D76B0007
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 11:14:33 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id r10-v6so2309469itc.2
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:14:33 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id p65-v6si1134906iop.187.2018.07.26.08.14.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 08:14:32 -0700 (PDT)
Date: Thu, 26 Jul 2018 11:14:20 -0400
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: Re: [PATCH v3 2/5] mm: access zone->node via zone_to_nid() and
 zone_set_nid()
Message-ID: <20180726151420.uigttpoclcka6h4h@xakep.localdomain>
References: <20180725220144.11531-1-osalvador@techadventures.net>
 <20180725220144.11531-3-osalvador@techadventures.net>
 <20180726080500.GX28386@dhcp22.suse.cz>
 <20180726081215.GC22028@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180726081215.GC22028@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, Oscar Salvador <osalvador@suse.de>

Hi Oscar,

Below is updated patch, with comment about OpenGrok and Acked-by Michal added.

Thank you,
Pavel
