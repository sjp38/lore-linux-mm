Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5FA996B0320
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 14:01:34 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id g6-v6so16203488iti.7
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 11:01:34 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id d135-v6si6408581itb.102.2018.07.09.11.01.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 11:01:33 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w69HwfDi105464
	for <linux-mm@kvack.org>; Mon, 9 Jul 2018 18:01:32 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2k2p75nbdv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 09 Jul 2018 18:01:32 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w69I1URY029609
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 9 Jul 2018 18:01:30 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w69I1TqM020531
	for <linux-mm@kvack.org>; Mon, 9 Jul 2018 18:01:30 GMT
Received: by mail-oi0-f46.google.com with SMTP id k12-v6so37524281oiw.8
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 11:01:29 -0700 (PDT)
MIME-Version: 1.0
References: <20180709083650.23549-1-daniel.vetter@ffwll.ch> <20180709083650.23549-6-daniel.vetter@ffwll.ch>
In-Reply-To: <20180709083650.23549-6-daniel.vetter@ffwll.ch>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 9 Jul 2018 14:00:52 -0400
Message-ID: <CAGM2reYoHuB25eUFgHCaiL-453G1LUgh=Gx1g9PWus3ztr3_mA@mail.gmail.com>
Subject: Re: [PATCH 06/12] mm: use for_each_if
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: daniel.vetter@ffwll.ch
Cc: LKML <linux-kernel@vger.kernel.org>, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, daniel.vetter@intel.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, rientjes@google.com, kemi.wang@intel.com, =?UTF-8?B?UGV0ciBUZXNhxZnDrWs=?= <ptesarik@suse.com>, yasu.isimatu@gmail.com, aryabinin@virtuozzo.com, nborisov@suse.com, Linux Memory Management List <linux-mm@kvack.org>

LGTM:

Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
