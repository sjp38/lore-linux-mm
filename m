Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 8877A6B0062
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 13:35:14 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 8 Apr 2013 13:35:13 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 42D3738C806A
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 13:35:11 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r38HZ8uv51839154
	for <linux-mm@kvack.org>; Mon, 8 Apr 2013 13:35:08 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r38HZ8ii032564
	for <linux-mm@kvack.org>; Mon, 8 Apr 2013 13:35:08 -0400
Message-ID: <5162FFB2.9010201@linux.vnet.ibm.com>
Date: Mon, 08 Apr 2013 10:34:42 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: when handling percpu_pagelist_fraction, use on_each_cpu()
 to set percpu pageset fields.
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com> <1365194030-28939-4-git-send-email-cody@linux.vnet.ibm.com> <5160D242.4010404@gmail.com>
In-Reply-To: <5160D242.4010404@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/06/2013 06:56 PM, Simon Jeons wrote:
> Hi Cody,
> On 04/06/2013 04:33 AM, Cody P Schafer wrote:
>> In free_hot_cold_page(), we rely on pcp->batch remaining stable.
>> Updating it without being on the cpu owning the percpu pageset
>> potentially destroys this stability.
>
> If cpu is off, can its pcp pageset be used in free_hot_code_page()?
>

I don't expect it to be as we use this_cpu_ptr() to access the pcp 
pageset. Unless there is some crazy mode where we can override the cpu a 
task believes it is running on...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
