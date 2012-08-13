Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id E14F06B0044
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 16:36:28 -0400 (EDT)
Message-ID: <50296522.2000809@sandia.gov>
Date: Mon, 13 Aug 2012 14:35:46 -0600
From: "Jim Schutt" <jaschut@sandia.gov>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/5] Improve hugepage allocation success rates
 under load V3
References: <1344520165-24419-1-git-send-email-mgorman@suse.de>
 <5023FE83.4090200@sandia.gov> <20120809204630.GJ12690@suse.de>
 <50243BE0.9060007@sandia.gov> <20120810110225.GO12690@suse.de>
 <502542C7.8050306@sandia.gov> <20120812202257.GA4177@suse.de>
In-Reply-To: <20120812202257.GA4177@suse.de>
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>

Hi Mel,

On 08/12/2012 02:22 PM, Mel Gorman wrote:

>
> I went through the patch again but only found the following which is a
> weak candidate. Still, can you retest with the following patch on top and
> CONFIG_PROVE_LOCKING set please?
>

I've gotten in several hours of testing on this patch with
no issues at all, and no output from CONFIG_PROVE_LOCKING
(I'm assuming it would show up on a serial console).  So,
it seems to me this patch has done the trick.

CPU utilization is staying under control, and write-out rate
is good.

You can add my Tested-by: as you see fit.  If you work
up any refinements and would like me to test, please
let me know.

Thanks -- Jim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
