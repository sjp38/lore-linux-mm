Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id C6A196B0068
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 12:36:37 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id x10so256440pdj.9
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 09:36:37 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id mp8si4306781pbc.82.2014.02.25.09.36.36
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 09:36:36 -0800 (PST)
Message-ID: <530CD443.7010400@intel.com>
Date: Tue, 25 Feb 2014 09:34:59 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ksm: Expose configuration via sysctl
References: <1393284484-27637-1-git-send-email-agraf@suse.de>
In-Reply-To: <1393284484-27637-1-git-send-email-agraf@suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Graf <agraf@suse.de>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>

On 02/24/2014 03:28 PM, Alexander Graf wrote:
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

Doesn't this essentially mean "don't use sysfs for configuration"?
Seems like at least /sys/kernel/mm/transparent_hugepage would need the
same treatment.

Couldn't we also (maybe in parallel) just teach the sysctl userspace
about sysfs?  This way we don't have to do parallel sysctls and sysfs
for *EVERYTHING* in the kernel:

	sysfs.kernel.mm.transparent_hugepage.enabled=enabled

Or do we just say "sysctls are the way to go for anything that might
need to be persistent, don't use sysfs"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
