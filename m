Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5CCBB800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 16:34:54 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id v10so4028427pde.18
        for <linux-mm@kvack.org>; Fri, 07 Nov 2014 13:34:54 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ca3si10148840pdb.140.2014.11.07.13.34.52
        for <linux-mm@kvack.org>;
        Fri, 07 Nov 2014 13:34:53 -0800 (PST)
Message-ID: <545D3AFB.1080308@intel.com>
Date: Fri, 07 Nov 2014 13:34:51 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] proc/smaps: add proportional size of anonymous page
References: <1415349088-24078-1-git-send-email-xiaokang.qin@intel.com>
In-Reply-To: <1415349088-24078-1-git-send-email-xiaokang.qin@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiaokang Qin <xiaokang.qin@intel.com>, linux-mm@kvack.org
Cc: fengwei.yin@intel.com

On 11/07/2014 12:31 AM, Xiaokang Qin wrote:
> The "proportional anonymous page size" (PropAnonymous) of a process is the count of
> anonymous pages it has in memory, where each anonymous page is devided by the number
> of processes sharing it.

This seems like the kind of thing that should just be accounted for in
the existing pss metric.  Why do we need a new, separate one?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
