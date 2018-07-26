Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 11CAA6B0003
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 13:19:27 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k9-v6so1660685iob.16
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 10:19:27 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id t13-v6si1454470itt.105.2018.07.26.10.19.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 10:19:25 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6QHJNj2058017
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 17:19:24 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2120.oracle.com with ESMTP id 2kbvsp42u1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 17:19:24 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6QHJNUV011317
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 17:19:24 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w6QHJNP1017669
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 17:19:23 GMT
Received: by mail-oi0-f51.google.com with SMTP id v8-v6so4315285oie.5
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 10:19:23 -0700 (PDT)
MIME-Version: 1.0
References: <20180725220144.11531-1-osalvador@techadventures.net>
 <20180725220144.11531-3-osalvador@techadventures.net> <20180726080500.GX28386@dhcp22.suse.cz>
 <20180726081215.GC22028@techadventures.net> <20180726151420.uigttpoclcka6h4h@xakep.localdomain>
 <20180726164304.GP28386@dhcp22.suse.cz>
In-Reply-To: <20180726164304.GP28386@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 26 Jul 2018 13:18:46 -0400
Message-ID: <CAGM2reatUAekg=e9FQM1-UVLOSBKb74-FYo7FcPqO_WaR7AmOQ@mail.gmail.com>
Subject: Re: [PATCH v3 2/5] mm: access zone->node via zone_to_nid() and zone_set_nid()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: osalvador@techadventures.net, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, dan.j.williams@intel.com, osalvador@suse.de

> > OpenGrok was used to find places where zone->node is accessed. A public one
> > is available here: http://src.illumos.org/source/
>
> I assume that tool uses some pattern matching or similar so steps to use
> the tool to get your results would be more helpful. This is basically
> the same thing as coccinelle generated patches.

OpenGrok is very easy to use, it is source browser, similar to cscope
except obviously you can't edit the browsed code. I could have used
cscope just as well here.

Pavel
