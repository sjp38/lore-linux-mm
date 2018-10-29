Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D8376B036E
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 06:43:26 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id x9-v6so409350oix.3
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 03:43:26 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h9si9082505otl.322.2018.10.29.03.43.25
        for <linux-mm@kvack.org>;
        Mon, 29 Oct 2018 03:43:25 -0700 (PDT)
Date: Mon, 29 Oct 2018 10:43:20 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH V2] kmemleak: Add config to select auto scan
Message-ID: <20181029104320.GC168424@arrakis.emea.arm.com>
References: <1540231723-7087-1-git-send-email-prpatel@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1540231723-7087-1-git-send-email-prpatel@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prateek Patel <prpatel@nvidia.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-tegra@vger.kernel.org, snikam@nvidia.com, vdumpa@nvidia.com, talho@nvidia.com, swarren@nvidia.com, Sri Krishna chowdary <schowdary@nvidia.com>

On Mon, Oct 22, 2018 at 11:38:43PM +0530, Prateek Patel wrote:
> From: Sri Krishna chowdary <schowdary@nvidia.com>
> 
> Kmemleak scan can be cpu intensive and can stall user tasks at times.
> To prevent this, add config DEBUG_KMEMLEAK_AUTO_SCAN to enable/disable
> auto scan on boot up.
> Also protect first_run with DEBUG_KMEMLEAK_AUTO_SCAN as this is meant
> for only first automatic scan.
> 
> Signed-off-by: Sri Krishna chowdary <schowdary@nvidia.com>
> Signed-off-by: Sachin Nikam <snikam@nvidia.com>
> Signed-off-by: Prateek <prpatel@nvidia.com>

Looks fine to me.

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
