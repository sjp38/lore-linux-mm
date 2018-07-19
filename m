Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1276B0274
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:44:19 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x204-v6so6523955qka.6
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:44:19 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id e19-v6si6008299qta.24.2018.07.19.06.44.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 06:44:18 -0700 (PDT)
Subject: Re: [PATCH v2 2/5] mm: access zone->node via zone_to_nid() and
 zone_set_nid()
References: <20180719132740.32743-1-osalvador@techadventures.net>
 <20180719132740.32743-3-osalvador@techadventures.net>
 <20180719134018.GB7193@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <760195c6-7cfb-76db-1c5c-b85456f3a4ad@oracle.com>
Date: Thu, 19 Jul 2018 09:44:09 -0400
MIME-Version: 1.0
In-Reply-To: <20180719134018.GB7193@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, osalvador@techadventures.net
Cc: akpm@linux-foundation.org, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>



On 07/19/2018 09:40 AM, Michal Hocko wrote:
> On Thu 19-07-18 15:27:37, osalvador@techadventures.net wrote:
>> From: Pavel Tatashin <pasha.tatashin@oracle.com>
>>
>> zone->node is configured only when CONFIG_NUMA=y, so it is a good idea to
>> have inline functions to access this field in order to avoid ifdef's in
>> c files.
> 
> Is this a manual find & replace or did you use some scripts?

I used opengrok:

http://src.illumos.org/source/search?q=%22zone-%3Enode%22&defs=&refs=&path=&hist=&project=linux-master

http://src.illumos.org/source/search?q=%22z-%3Enode%22&defs=&refs=&path=&hist=&project=linux-master

> 
> The change makes sense, but I haven't checked that all the places are
> replaced properly. If not we can replace them later.
> 
>> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>> Signed-off-by: Oscar Salvador <osalvador@suse.de>
>> Reviewed-by: Oscar Salvador <osalvador@suse.de>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thank you,
Pavel
