Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id D833B6B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 11:00:46 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so5186574pdb.27
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 08:00:46 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ro4si5620144pac.2.2014.07.18.08.00.45
        for <linux-mm@kvack.org>;
        Fri, 18 Jul 2014 08:00:45 -0700 (PDT)
Message-ID: <53C9369B.4070608@intel.com>
Date: Fri, 18 Jul 2014 08:00:43 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] memory-hotplug: x86_64: suitable memory should go
 to ZONE_MOVABLE
References: <1405670163-53747-1-git-send-email-wangnan0@huawei.com> <1405670163-53747-2-git-send-email-wangnan0@huawei.com>
In-Reply-To: <1405670163-53747-2-git-send-email-wangnan0@huawei.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Nan <wangnan0@huawei.com>, Ingo Molnar <mingo@redhat.com>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Pei Feiyue <peifeiyue@huawei.com>, linux-mm@kvack.org, x86@kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org

On 07/18/2014 12:55 AM, Wang Nan wrote:
> +	if (!zone_is_empty(movable_zone))
> +		if (zone_spans_pfn(movable_zone, start_pfn) ||
> +				(zone_end_pfn(movable_zone) <= start_pfn))
> +			zone = movable_zone;
> +

It's nice that you hit so many architectures, but is there a way to do
this that doesn't involve copying and pasting the same bit of code in to
each architecture?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
