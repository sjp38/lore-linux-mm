Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id A764D6B025E
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 16:11:57 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id u206so101582935wme.1
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 13:11:57 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id s6si10110551wju.74.2016.04.07.13.11.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 13:11:56 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id u206so101582593wme.1
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 13:11:56 -0700 (PDT)
Date: Thu, 7 Apr 2016 23:11:43 +0300
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: [PATCH v5 2/2] mm, thp: avoid unnecessary swapin in khugepaged
Message-ID: <20160407201143.GA4055@debian>
References: <1460049861-10646-1-git-send-email-ebru.akagunduz@gmail.com>
 <1460050081-10765-1-git-send-email-ebru.akagunduz@gmail.com>
 <20160407185854.GO2258@uranus.lan>
 <1460057945.25336.0.camel@redhat.com>
 <20160407194759.GA1982@uranus.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160407194759.GA1982@uranus.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: riel@redhat.com, linux-mm@kvack.org, hughd@google.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com

On Thu, Apr 07, 2016 at 10:47:59PM +0300, Cyrill Gorcunov wrote:
> On Thu, Apr 07, 2016 at 03:39:05PM -0400, Rik van Riel wrote:
> > > This !=) looks like someone got fun ;)
> > 
> > Looks like someone sent out emails before refreshing the
> > patch, which is a such an easy mistake to make I must have
> > done it a dozen times by now :)
> 
> I've been there many times as well :)

I apologize for inconvenience. When making
last checks on this patch, this happened and
I wasn't aware of it. I'll fix this, test and
send in next version.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
