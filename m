Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id F31646B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 12:46:35 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id c1so1116041igq.16
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 09:46:35 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id u6si2926048icp.74.2014.04.24.09.46.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 09:46:35 -0700 (PDT)
Message-ID: <53593FE3.5000606@oracle.com>
Date: Thu, 24 Apr 2014 12:46:27 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: hangs in collapse_huge_page
References: <534DE5C0.2000408@oracle.com>
In-Reply-To: <534DE5C0.2000408@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/15/2014 10:06 PM, Sasha Levin wrote:
> Hi all,
> 
> I often see hung task triggering in khugepaged within collapse_huge_page().
> 
> I've initially assumed the case may be that the guests are too loaded and
> the warning occurs because of load, but after increasing the timeout to
> 1200 sec I still see the warning.

Ping? It happens quite often right now.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
