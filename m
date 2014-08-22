Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id AC00C6B0035
	for <linux-mm@kvack.org>; Fri, 22 Aug 2014 18:22:03 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so17281756pad.25
        for <linux-mm@kvack.org>; Fri, 22 Aug 2014 15:22:03 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ha1si42515399pbc.104.2014.08.22.15.22.02
        for <linux-mm@kvack.org>;
        Fri, 22 Aug 2014 15:22:02 -0700 (PDT)
Message-ID: <53F7C286.50800@intel.com>
Date: Fri, 22 Aug 2014 15:21:58 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memory-hotplug: add sysfs zones_online_to attribute
References: <1407902811-4873-1-git-send-email-zhenzhang.zhang@huawei.com>	<53EAE534.8030303@huawei.com>	<1408138647.26567.42.camel@misato.fc.hp.com>	<53F17230.5020409@huawei.com> <20140822151622.6786c1089548ea5ceb3732bf@linux-foundation.org>
In-Reply-To: <20140822151622.6786c1089548ea5ceb3732bf@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: Toshi Kani <toshi.kani@hp.com>, David Rientjes <rientjes@google.com>, isimatu.yasuaki@jp.fujitsu.com, n-horiguchi@ah.jp.nec.com, wangnan0@huawei.com, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On 08/22/2014 03:16 PM, Andrew Morton wrote:
> Also, it's not really clear to me why we need this sysfs file at all. 
> Do people really read sysfs files, make onlining decisions and manually
> type in commands?  Or is this stuff all automated?  If the latter then
> the script can take care of all this?  For example, attempt to online
> the memory into the desired zone and report failure if that didn't
> succeed?

I guess we can just iterate over all possible zone types from userspace
until we find one.  Seems a bit hokey, but it would work at least until
we add a new zone type and we have to teach the scripts about the new
type.  But that's a pretty rare event I guess.  Let's hope the script
writers get this right, and don't make omissions like ZONE_MOVABLE
because it's not that common in practice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
