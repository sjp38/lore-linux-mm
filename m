Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4B8DB8E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 05:14:55 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id 32so7471070ots.15
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 02:14:55 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q11si6570579oia.196.2018.12.12.02.14.54
        for <linux-mm@kvack.org>;
        Wed, 12 Dec 2018 02:14:54 -0800 (PST)
Date: Wed, 12 Dec 2018 10:14:49 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH V2] kmemleak: Add config to select auto scan
Message-ID: <20181212101448.GA65138@arrakis.emea.arm.com>
References: <1540231723-7087-1-git-send-email-prpatel@nvidia.com>
 <20181029104320.GC168424@arrakis.emea.arm.com>
 <a51a7d4b-6366-ea10-f220-992525ec1d42@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a51a7d4b-6366-ea10-f220-992525ec1d42@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prateek Patel <prpatel@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-tegra@vger.kernel.org, snikam@nvidia.com, vdumpa@nvidia.com, talho@nvidia.com, swarren@nvidia.com, treding@nvidia.com

On Wed, Dec 12, 2018 at 12:14:29PM +0530, Prateek Patel wrote:
> On 10/29/2018 4:13 PM, Catalin Marinas wrote:
> > On Mon, Oct 22, 2018 at 11:38:43PM +0530, Prateek Patel wrote:
> > > From: Sri Krishna chowdary <schowdary@nvidia.com>
> > > 
> > > Kmemleak scan can be cpu intensive and can stall user tasks at times.
> > > To prevent this, add config DEBUG_KMEMLEAK_AUTO_SCAN to enable/disable
> > > auto scan on boot up.
> > > Also protect first_run with DEBUG_KMEMLEAK_AUTO_SCAN as this is meant
> > > for only first automatic scan.
> > > 
> > > Signed-off-by: Sri Krishna chowdary <schowdary@nvidia.com>
> > > Signed-off-by: Sachin Nikam <snikam@nvidia.com>
> > > Signed-off-by: Prateek <prpatel@nvidia.com>
> > Looks fine to me.
> > 
> > Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> 
> Can you mark this patch as acknowledged so that it can be picked up by the
> maintainer.

I thought Reviewed-by was sufficient. Anyway:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
