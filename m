Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8297F6B0271
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 11:46:10 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l13-v6so10621760qth.8
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 08:46:10 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id p85-v6si691275qkl.273.2018.07.30.08.46.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 08:46:09 -0700 (PDT)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6UFiJt9073215
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 15:46:08 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2130.oracle.com with ESMTP id 2kgfwsw6p9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 15:46:08 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w6UFk7pl006274
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 15:46:08 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6UFk7AI022585
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 15:46:07 GMT
Received: by mail-oi0-f46.google.com with SMTP id q11-v6so22082455oic.12
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 08:46:07 -0700 (PDT)
MIME-Version: 1.0
References: <20180727165454.27292-1-david@redhat.com> <20180730113029.GM24267@dhcp22.suse.cz>
 <6cc416e7-522c-a67e-2706-f37aadff084f@redhat.com> <20180730120529.GN24267@dhcp22.suse.cz>
 <7b58af7b-5187-2c76-b458-b0f49875a1fc@redhat.com> <CAGM2reahiWj5LFq1npRpwK2k-4K-L9hr3AHUV9uYcmT2s3Bnuw@mail.gmail.com>
 <56e97799-fbe1-9546-46ab-a9b8ee8794e0@redhat.com> <20180730141058.GV24267@dhcp22.suse.cz>
 <80641d1a-72fe-26b2-7927-98fcac5e5d71@redhat.com> <20180730145035.GY24267@dhcp22.suse.cz>
 <0be90c23-e5a0-2628-c671-9923d8e45b0a@redhat.com>
In-Reply-To: <0be90c23-e5a0-2628-c671-9923d8e45b0a@redhat.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 30 Jul 2018 11:45:31 -0400
Message-ID: <CAGM2rebjVFpeWKV1wx5=3f6=Tx6h5qT9jszacGpB9pEcYKO1FA@mail.gmail.com>
Subject: Re: [PATCH v1] mm: inititalize struct pages when adding a section
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@redhat.com
Cc: mhocko@kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, gregkh@linuxfoundation.org, mingo@kernel.org, Andrew Morton <akpm@linux-foundation.org>, dan.j.williams@intel.com, jack@suse.cz, mawilcox@microsoft.com, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, kirill.shutemov@linux.intel.com, Vlastimil Babka <vbabka@suse.cz>, osalvador@techadventures.net, yasu.isimatu@gmail.com, malat@debian.org, Mel Gorman <mgorman@suse.de>, iamjoonsoo.kim@lge.com

>
> So i guess we agree that the right fix for this is to not touch struct
> pages when removing memory, correct?

Yes in my opinion that would be the correct fix.

Thank you,
Pavel

>
> --
>
> Thanks,
>
> David / dhildenb
>
