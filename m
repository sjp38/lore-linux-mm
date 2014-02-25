Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 20E646B00DF
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 07:33:48 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id x12so327626wgg.8
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 04:33:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id dd1si7982757wib.18.2014.02.25.04.33.44
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 04:33:45 -0800 (PST)
Message-ID: <530C8D84.2050505@redhat.com>
Date: Tue, 25 Feb 2014 07:33:08 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ksm: Expose configuration via sysctl
References: <1393284484-27637-1-git-send-email-agraf@suse.de>
In-Reply-To: <1393284484-27637-1-git-send-email-agraf@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Graf <agraf@suse.de>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>

On 02/24/2014 06:28 PM, Alexander Graf wrote:
> Configuration of tunables and Linux virtual memory settings has traditionally
> happened via sysctl. Thanks to that there are well established ways to make
> sysctl configuration bits persistent (sysctl.conf).
> 
> KSM introduced a sysfs based configuration path which is not covered by user
> space persistent configuration frameworks.
> 
> In order to make life easy for sysadmins, this patch adds all access to all
> KSM tunables via sysctl as well. That way sysctl.conf works for KSM as well,
> giving us a streamlined way to make KSM configuration persistent.
> 
> Reported-by: Sasche Peilicke <speilicke@suse.com>
> Signed-off-by: Alexander Graf <agraf@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
