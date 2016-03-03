Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id B2F05828E2
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 03:34:38 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id p65so21392798wmp.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 00:34:38 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id ja2si47408911wjb.5.2016.03.03.00.34.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 00:34:37 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 021CA1C58AB
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 08:34:37 +0000 (GMT)
Date: Thu, 3 Mar 2016 08:34:35 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH RFC 2/2] powerpc/mm: Enable page parallel initialisation
Message-ID: <20160303083435.GJ2854@techsingularity.net>
References: <1456988501-29046-1-git-send-email-zhlcindy@gmail.com>
 <1456988501-29046-3-git-send-email-zhlcindy@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1456988501-29046-3-git-send-email-zhlcindy@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhang <zhlcindy@gmail.com>
Cc: mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Zhang <zhlcindy@linux.vnet.ibm.com>

On Thu, Mar 03, 2016 at 03:01:41PM +0800, Li Zhang wrote:
> From: Li Zhang <zhlcindy@linux.vnet.ibm.com>
> 
> Parallel initialisation has been enabled for X86,
> boot time is improved greatly.
> On Power8, for small memory, it is improved greatly.
> Here is the result from my test on Power8 platform:
> 
> For 4GB memory: 57% is improved
> For 50GB memory: 22% is improve
> 
> Signed-off-by: Li Zhang <zhlcindy@linux.vnet.ibm.com>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
