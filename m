Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 357F16B0098
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 19:03:01 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id hm4so5235311wib.2
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 16:03:00 -0800 (PST)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id gt3si8798wib.8.2014.02.25.16.02.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 16:03:00 -0800 (PST)
Received: by mail-wi0-f174.google.com with SMTP id f8so5236437wiw.13
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 16:02:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <530CD443.7010400@intel.com>
References: <1393284484-27637-1-git-send-email-agraf@suse.de> <530CD443.7010400@intel.com>
From: Kay Sievers <kay@vrfy.org>
Date: Wed, 26 Feb 2014 01:02:39 +0100
Message-ID: <CAPXgP10NhyepKXVboF+=AbXD=0kH6XFbijUL-s8aUjcLKq4myQ@mail.gmail.com>
Subject: Re: [PATCH] ksm: Expose configuration via sysctl
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Alexander Graf <agraf@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>

On Tue, Feb 25, 2014 at 6:34 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 02/24/2014 03:28 PM, Alexander Graf wrote:
>> Configuration of tunables and Linux virtual memory settings has traditionally
>> happened via sysctl. Thanks to that there are well established ways to make
>> sysctl configuration bits persistent (sysctl.conf).
>>
>> KSM introduced a sysfs based configuration path which is not covered by user
>> space persistent configuration frameworks.
>>
>> In order to make life easy for sysadmins, this patch adds all access to all
>> KSM tunables via sysctl as well. That way sysctl.conf works for KSM as well,
>> giving us a streamlined way to make KSM configuration persistent.
>
> Doesn't this essentially mean "don't use sysfs for configuration"?
> Seems like at least /sys/kernel/mm/transparent_hugepage would need the
> same treatment.
>
> Couldn't we also (maybe in parallel) just teach the sysctl userspace
> about sysfs?  This way we don't have to do parallel sysctls and sysfs
> for *EVERYTHING* in the kernel:
>
>         sysfs.kernel.mm.transparent_hugepage.enabled=enabled
>
> Or do we just say "sysctls are the way to go for anything that might
> need to be persistent, don't use sysfs"?

Support in sysctl for setting static data in /sys might make sense for
some rare use cases.

It's still not obvious how to handle the dynamic nature of most of the
data that is created by modules, and which data belongs into udev
rules and which in the "sysctl /sys" settings.

Kay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
