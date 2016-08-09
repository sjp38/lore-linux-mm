Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 907466B0253
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 13:39:47 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h186so35320659pfg.2
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 10:39:47 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id xg5si43626618pac.220.2016.08.09.10.39.39
        for <linux-mm@kvack.org>;
        Tue, 09 Aug 2016 10:39:45 -0700 (PDT)
Subject: Re: [QUESTION] mmap of device file with huge pages
References: <85d8c7bb8bcc4a30865a4512dd174cf8@IL-EXCH02.marvell.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57AA155B.70009@intel.com>
Date: Tue, 9 Aug 2016 10:39:39 -0700
MIME-Version: 1.0
In-Reply-To: <85d8c7bb8bcc4a30865a4512dd174cf8@IL-EXCH02.marvell.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yehuda Yitschak <yehuday@marvell.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Shadi Ammouri <shadi@marvell.com>

On 08/09/2016 02:58 AM, Yehuda Yitschak wrote:
> I would appreciate any advice on this issue

This is kinda a FAQ at this point.  But, the thing I generally suggest
is that you allocate hugetlbfs memory or anonymous transparent huge
pages in your applciation via the _normal_ mechanisms, and then hand a
pointer to that in to your driver.

It's backwards from how you're doing it now, but it makes things easier
down the road.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
