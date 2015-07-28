Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 99CFC6B0253
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 18:27:00 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so76284656pac.3
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 15:27:00 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id v5si12881640pdr.5.2015.07.28.15.26.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 15:26:59 -0700 (PDT)
Received: by pachj5 with SMTP id hj5so76284490pac.3
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 15:26:59 -0700 (PDT)
Date: Tue, 28 Jul 2015 15:26:54 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: hugetlb pages not accounted for in rss
Message-ID: <20150728222654.GA28456@Sligo.logfs.org>
References: <55B6BE37.3010804@oracle.com>
 <20150728183248.GB1406@Sligo.logfs.org>
 <55B7F0F8.8080909@oracle.com>
 <alpine.DEB.2.10.1507281509420.23577@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.10.1507281509420.23577@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, Jul 28, 2015 at 03:15:17PM -0700, David Rientjes wrote:
> 
> Starting to account hugetlb pages in rss may lead to breakage in userspace 
> and I would agree with your earlier suggestion that just removing any test 
> for rss would be appropriate.

What would you propose for me then?  I have 80% RAM or more in reserved
hugepages.  OOM-killer is not a concern, as it panics the system - the
alternatives were almost universally silly and we didn't want to deal
with system in unpredictable states.  But knowing how much memory is
used by which process is a concern.  And if you only tell me about the
small (and continuously shrinking) portion, I essentially fly blind.

That is not a case of "may lead to breakage", it _is_ broken.

Ideally we would have fixed this in 2002 when hugetlbfs was introduced.
By now we might have to introduce a new field, rss_including_hugepages
or whatever.  Then we have to update tools like top etc. to use the new
field when appropriate.  No fun, but might be necessary.

If we can get away with including hugepages in rss and fixing the OOM
killer to be less silly, I would strongly prefer that.  But I don't know
how much of a mess we are already in.

Jorn

--
Time? What's that? Time is only worth what you do with it.
-- Theo de Raadt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
