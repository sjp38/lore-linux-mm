Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B2FA6B0269
	for <linux-mm@kvack.org>; Wed, 23 May 2018 09:15:02 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id d5-v6so20900115qtg.17
        for <linux-mm@kvack.org>; Wed, 23 May 2018 06:15:02 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id m4-v6si9593942qtf.368.2018.05.23.06.15.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 06:15:01 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w4NDBDq9108911
	for <linux-mm@kvack.org>; Wed, 23 May 2018 13:15:01 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2j4nh7bvsm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 23 May 2018 13:15:01 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w4NDF0w2020304
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 23 May 2018 13:15:00 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w4NDExaN016731
	for <linux-mm@kvack.org>; Wed, 23 May 2018 13:15:00 GMT
Received: by mail-ot0-f170.google.com with SMTP id l12-v6so25123527oth.6
        for <linux-mm@kvack.org>; Wed, 23 May 2018 06:14:59 -0700 (PDT)
MIME-Version: 1.0
References: <20180523125555.30039-1-mhocko@kernel.org> <20180523125555.30039-3-mhocko@kernel.org>
In-Reply-To: <20180523125555.30039-3-mhocko@kernel.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 23 May 2018 09:14:23 -0400
Message-ID: <CAGM2reZLSpad28EbrqLLoXHC_F9y=XTF08wQ59iUPaREbq5sgw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: do not warn on offline nodes unless the specific
 node is explicitly requested
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, osalvador@techadventures.net, Vlastimil Babka <vbabka@suse.cz>, arbab@linux.vnet.ibm.com, imammedo@redhat.com, vkuznets@redhat.com, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>

Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
