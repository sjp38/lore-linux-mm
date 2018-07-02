Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4B56A6B0003
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 21:56:27 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id n18-v6so12213671iog.10
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 18:56:27 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id q187-v6si4317125itd.104.2018.07.01.18.56.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 18:56:26 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w621sEj4097925
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 01:56:25 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2130.oracle.com with ESMTP id 2jwyccjpqa-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 02 Jul 2018 01:56:25 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w621uPtM025904
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 01:56:25 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w621uOUF027644
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 01:56:24 GMT
Received: by mail-oi0-f52.google.com with SMTP id i12-v6so9083806oik.2
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 18:56:24 -0700 (PDT)
MIME-Version: 1.0
References: <20180630030944.9335-1-pasha.tatashin@oracle.com>
 <20180630030944.9335-3-pasha.tatashin@oracle.com> <20180702013918.GJ3223@MiWiFi-R3L-srv>
 <CAGM2reYRYNOe0nweMrSxLZ_RRQbu500iSRKWrbO4_CzyWTEtjQ@mail.gmail.com> <20180702015211.GK3223@MiWiFi-R3L-srv>
In-Reply-To: <20180702015211.GK3223@MiWiFi-R3L-srv>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Sun, 1 Jul 2018 21:55:47 -0400
Message-ID: <CAGM2reYQaz0qr8nvHrSG_Vw_raR-d7cQeH=rZyC1nrTKfFhZ-g@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] mm/sparse: start using sparse_init_nid(), and
 remove old code
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bhe@redhat.com
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

>
> Yes, if they are equal at 501, 'continue' to for loop. If nid is not
> equal to nid_begin, we execute sparse_init_nid(), here should it be that
> nid_begin is the current node, nid is next node?

Nevermind, I forgot about the continue, I will fix it. Thank you again!

Pavel
