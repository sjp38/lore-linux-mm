Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6154C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 19:45:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B523A20C01
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 19:45:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B523A20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F8748E0004; Thu, 28 Feb 2019 14:45:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A64C8E0001; Thu, 28 Feb 2019 14:45:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 371C58E0004; Thu, 28 Feb 2019 14:45:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id F1BA28E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 14:45:39 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id y66so16827262pfg.16
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:45:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BPjc1PNzjmcp4DWACW4ahWWzCTU959GTTMfvYwR1Brk=;
        b=ZTGXz7YJZ7X/R2aUWxEI+6ie4rC6mR53eVTJBC7Ics4Ngk94OgiOHRTsgniXJ3XSOU
         K/NajaRwV32BjdWYABFjOxRmUH0fhI2IyysNSSuBxWXGmD9BT3QgXgeYL/8xjkRgxbIw
         mBJ9U9xj2kJbuZvHgcCY73LD8scejr/OMEK6LUMToH1dADKc/QMEZbtMKIPzEGshlnoR
         5QxLTc5/UG37JLftMHfR5Say+Gt3qDn+NOJVWkjGNp1sdtBRTzRUaD67PHkutbgkriJ8
         mwUwSVjLRomlODr0O0yCdMUQo8WroADvGkkxMNJlngtpC6c9sOCbqPM5LpEhFPdLBIyq
         6ySg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWC1jcrg14ZLwd1MC0z66d6soHK1ZpJI9OB5e7X2T3FeDd+xLBV
	MW0OB9K5PjsRSXicQuWbfvMOKWuKWXp+aezWtHWmkYbAeLjWnmHirhADkzlv3cA5P7oi5k3jBv4
	7BJ5u33wBk5U/E0TaMnqrjP3FR9FsTMgMjGxGUovNmj88IckBUvkQajTP9+ZoWdzagA==
X-Received: by 2002:a17:902:2dc3:: with SMTP id p61mr1107348plb.166.1551383139660;
        Thu, 28 Feb 2019 11:45:39 -0800 (PST)
X-Google-Smtp-Source: APXvYqwSBBfHsoHwNikHYKYzfRTI7Fa1cluo3lHxaFVKkmD6os11DqNWnnmwFoTztnv+tT5cLYBH
X-Received: by 2002:a17:902:2dc3:: with SMTP id p61mr1107271plb.166.1551383138591;
        Thu, 28 Feb 2019 11:45:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551383138; cv=none;
        d=google.com; s=arc-20160816;
        b=aukq5kr0pAIuzeLXu2CztkYoP/oaBnGAm5TX+2yBdBdlJbDS8vK5Gmo6Uh4A+unvJd
         /WWcA2hiPuiMvlSMXPEkrj3g0a24gvJJIyB+mviK6FII1p0qhWPvKenDd3PkRqgNqCGq
         UptXbjoGJDhXAtK2seshziCUIEa0OdAkAn0yP63fQfbP7JqMmK0pBrQWmpqhst1H5D7V
         jhb6Ylm4FQ6IJE4geky3XV/udPOJmg9F7m69Z7G6xiEVpfAGMbSEa7NhzDghHZ5Gx1F8
         a80n67UmsFrITmMDYchFZQW8dMJzQu40LioNRRP9FuJzg0IUVcqrobLmkQV9lkddhyd7
         AVRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=BPjc1PNzjmcp4DWACW4ahWWzCTU959GTTMfvYwR1Brk=;
        b=VlgCSqmDDMDpwAAt9K1ucRRyw5Kb76KyXq8XYWVbjm1qAJ4JzwP0/pszZ6+Xqo6UWu
         Trip7eqKPrw2Uuf6xzytyZ4WAiSwbTncMGSTrxtE4l0dhb49aJlZ5eJguaDKT8fXGj1Q
         V+YJjgsmEZ63fmOkQTydJNkKnm8Y8jFCRgxEu2N0O50bDLNZKAOYelDZiyzEgXy8otbF
         q54rSUYy5Dl7j11LrYMgPjjbvh32O1mT8srOkKSBHiNbVu+brIY6hkmAW3E0KB8Xdh6u
         +GXSAvL8rJsdC+91kCrPJpktJRISudmP4mophh3cl01lJYBC34cRNyJuRq7NCID1HTIH
         3/wA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cm2si20196979plb.327.2019.02.28.11.45.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 11:45:38 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id EE495B1CB;
	Thu, 28 Feb 2019 19:45:36 +0000 (UTC)
Date: Thu, 28 Feb 2019 11:45:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Dave Young <dyoung@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org,
 linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, kexec-ml
 <kexec@lists.infradead.org>, pv-drivers@vmware.com, Alexander Duyck
 <alexander.h.duyck@linux.intel.com>, Alexey Dobriyan <adobriyan@gmail.com>,
 Arnd Bergmann <arnd@arndb.de>, Baoquan He <bhe@redhat.com>, Borislav Petkov
 <bp@alien8.de>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Christian
 Hansen <chansen3@cisco.com>, David Rientjes <rientjes@google.com>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, Haiyang Zhang
 <haiyangz@microsoft.com>, Jonathan Corbet <corbet@lwn.net>, Juergen Gross
 <jgross@suse.com>, Julien Freche <jfreche@vmware.com>, Kairui Song
 <kasong@redhat.com>, Kazuhito Hagio <k-hagio@ab.jp.nec.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin
 Khlebnikov <koct9i@gmail.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Len
 Brown <len.brown@intel.com>, Lianbo Jiang <lijiang@redhat.com>, Matthew
 Wilcox <willy@infradead.org>, "Michael S. Tsirkin" <mst@redhat.com>, Michal
 Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, Mike Rapoport
 <rppt@linux.vnet.ibm.com>, Miles Chen <miles.chen@mediatek.com>, Nadav Amit
 <namit@vmware.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Omar
 Sandoval <osandov@fb.com>, Pankaj gupta <pagupta@redhat.com>, Pavel Machek
 <pavel@ucw.cz>, Pavel Tatashin <pasha.tatashin@oracle.com>,
 "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki"
 <rjw@rjwysocki.net>, Stefano Stabellini <sstabellini@kernel.org>, Stephen
 Hemminger <sthemmin@microsoft.com>, Stephen Rothwell
 <sfr@canb.auug.org.au>, Vitaly Kuznetsov <vkuznets@redhat.com>, Vlastimil
 Babka <vbabka@suse.cz>, Xavier Deguillard <xdeguillard@vmware.com>
Subject: Re: [PATCH v2 0/8] mm/kdump: allow to exclude pages that are
 logically offline
Message-Id: <20190228114535.150dfaebbe4d00ae48716bf0@linux-foundation.org>
In-Reply-To: <20190227053214.GA12302@dhcp-128-65.nay.redhat.com>
References: <20181122100627.5189-1-david@redhat.com>
	<20190227053214.GA12302@dhcp-128-65.nay.redhat.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2019 13:32:14 +0800 Dave Young <dyoung@redhat.com> wrote:

> This series have been in -next for some days, could we get this in
> mainline? 

It's been in -next for two months?

> Andrew, do you have plan about them, maybe next release?

They're all reviewed except for "xen/balloon: mark inflated pages
PG_offline". 
(https://ozlabs.org/~akpm/mmotm/broken-out/xen-balloon-mark-inflated-pages-pg_offline.patch).
Yes, I plan on sending these to Linus during the merge window for 5.1

