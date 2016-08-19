Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C64FF82F5F
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 01:48:11 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 4so97005156oih.2
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 22:48:11 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id z68si2818245itd.12.2016.08.18.22.48.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 22:48:11 -0700 (PDT)
Subject: Re: [PATCH v3] mm/slab: Improve performance of gathering slabinfo
 stats
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com>
 <20160818115218.GJ30162@dhcp22.suse.cz>
From: aruna.ramakrishna@oracle.com
Message-ID: <57B69D8F.5000101@oracle.com>
Date: Thu, 18 Aug 2016 22:47:59 -0700
MIME-Version: 1.0
In-Reply-To: <20160818115218.GJ30162@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On 08/18/2016 04:52 AM, Michal Hocko wrote:
> I am not opposing the patch (to be honest it is quite neat) but this
> is buggering me for quite some time. Sorry for hijacking this email
> thread but I couldn't resist. Why are we trying to optimize SLAB and
> slowly converge it to SLUB feature-wise. I always thought that SLAB
> should remain stable and time challenged solution which works reasonably
> well for many/most workloads, while SLUB is an optimized implementation
> which experiment with slightly different concepts that might boost the
> performance considerably but might also surprise from time to time. If
> this is not the case then why do we have both of them in the kernel. It
> is a lot of code and some features need tweaking both while only one
> gets testing coverage. So this is mainly a question for maintainers. Why
> do we maintain both and what is the purpose of them.

Michal,

Speaking about this patch specifically - I'm not trying to optimize SLAB 
or make it more similar to SLUB. This patch is a bug fix for an issue 
where the slowness of 'cat /proc/slabinfo' caused timeouts in other 
drivers. While optimizing that flow, it became apparent (as Christoph 
pointed out) that one could converge this patch to SLUB's current 
implementation. Though I have not done that in this patch (because that 
warrants a separate patch), I think it makes sense to converge where 
appropriate, since they both do share some common data structures and 
code already.

Thanks,
Aruna

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
