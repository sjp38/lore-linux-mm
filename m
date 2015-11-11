Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7B7E26B0253
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 20:11:18 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so13834856pac.3
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 17:11:18 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id gx4si8621545pbc.234.2015.11.10.17.11.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 17:11:17 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so14013440pab.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 17:11:17 -0800 (PST)
Date: Tue, 10 Nov 2015 17:11:15 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH selftests 5/6] selftests: vm: Try harder to allocate huge
 pages
In-Reply-To: <1447192104.6006.148.camel@decadent.org.uk>
Message-ID: <alpine.DEB.2.10.1511101710470.19847@chino.kir.corp.google.com>
References: <1446334510.2595.13.camel@decadent.org.uk> <1446334747.2595.19.camel@decadent.org.uk> <alpine.DEB.2.10.1511101159480.29993@chino.kir.corp.google.com> <1447192104.6006.148.camel@decadent.org.uk>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-1583944356-1447204275=:19847"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-api@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-1583944356-1447204275=:19847
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Tue, 10 Nov 2015, Ben Hutchings wrote:

> > I know this patch is in -mm and hasn't been merged by Linus yet, but I'm 
> > wondering why the multiple /proc/sys/vm/drop_caches is helping?A  Would it 
> > simply suffice to put a sleep in there instead or is drop_caches actually 
> > doing something useful a second time around?
> 
> Initially I just retried setting nr_hugepages up to 10 times, which
> wasn't sufficient. A Then I added the drop_caches, and after that
> setting nr_hugepages tended to worked first time so I reduced the retry
> count. A It might not be necessary to retry at all.
> 

Ok, thanks.  I was just trying to make sure that the additional 
drop_caches wasn't actually required for the test, in which case we would 
have to fix drop_caches :)
--397176738-1583944356-1447204275=:19847--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
