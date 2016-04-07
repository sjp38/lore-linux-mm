Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f50.google.com (mail-lf0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 29BD66B025E
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 15:48:03 -0400 (EDT)
Received: by mail-lf0-f50.google.com with SMTP id e190so62880142lfe.0
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 12:48:03 -0700 (PDT)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com. [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id i12si4951069lfe.14.2016.04.07.12.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 12:48:01 -0700 (PDT)
Received: by mail-lb0-x231.google.com with SMTP id bk9so29395509lbc.3
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 12:48:01 -0700 (PDT)
Date: Thu, 7 Apr 2016 22:47:59 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v5 2/2] mm, thp: avoid unnecessary swapin in khugepaged
Message-ID: <20160407194759.GA1982@uranus.lan>
References: <1460049861-10646-1-git-send-email-ebru.akagunduz@gmail.com>
 <1460050081-10765-1-git-send-email-ebru.akagunduz@gmail.com>
 <20160407185854.GO2258@uranus.lan>
 <1460057945.25336.0.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1460057945.25336.0.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, hughd@google.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com

On Thu, Apr 07, 2016 at 03:39:05PM -0400, Rik van Riel wrote:
> > This !=) looks like someone got fun ;)
> 
> Looks like someone sent out emails before refreshing the
> patch, which is a such an easy mistake to make I must have
> done it a dozen times by now :)

I've been there many times as well :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
