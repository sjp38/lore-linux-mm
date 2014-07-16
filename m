Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 49E536B007D
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 15:38:49 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so1883481pad.10
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 12:38:49 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id j15si104738pdm.313.2014.07.16.12.38.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 12:38:48 -0700 (PDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so1345145pab.0
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 12:38:48 -0700 (PDT)
Date: Wed, 16 Jul 2014 12:37:04 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch v2] mm, tmp: only collapse hugepages to nodes with affinity
 for zone_reclaim_mode
In-Reply-To: <53C69E92.70608@suse.cz>
Message-ID: <alpine.LSU.2.11.1407161234160.3956@eggly.anvils>
References: <alpine.DEB.2.02.1407141807030.8808@chino.kir.corp.google.com> <alpine.DEB.2.02.1407151712520.12279@chino.kir.corp.google.com> <53C5D3D2.8080000@oracle.com> <53C69E92.70608@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Bob Liu <bob.liu@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I shall worry less if you change the Subject from "mm, tmp:" to "mm, thp:"

Hugh :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
