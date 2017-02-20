Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 819136B0038
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 07:35:55 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id x4so10083418wme.3
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 04:35:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 187si12175044wmx.37.2017.02.20.04.35.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Feb 2017 04:35:54 -0800 (PST)
Date: Mon, 20 Feb 2017 13:35:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/8] mm: cma: Export a few symbols
Message-ID: <20170220123550.GH2431@dhcp22.suse.cz>
References: <cover.7101c7323e6f22e281ad70b93488cf44caca4ca0.1486655917.git-series.maxime.ripard@free-electrons.com>
 <2dee6c0baaf08e2c7d48ceb7e97e511c914d0f87.1486655917.git-series.maxime.ripard@free-electrons.com>
 <20170209192046.GB31906@dhcp22.suse.cz>
 <20170213134416.akgmtv3lv5m65fwx@lukather>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170213134416.akgmtv3lv5m65fwx@lukather>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Cc: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Chen-Yu Tsai <wens@csie.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, dri-devel@lists.freedesktop.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Joonsoo Kim <js1304@gmail.com>, m.szyprowski@samsung.com

On Mon 13-02-17 14:44:16, Maxime Ripard wrote:
> Hi Michal,
> 
> On Thu, Feb 09, 2017 at 08:20:47PM +0100, Michal Hocko wrote:
> > [CC CMA people]
> > 
> > On Thu 09-02-17 17:39:17, Maxime Ripard wrote:
> > > Modules might want to check their CMA pool size and address for debugging
> > > and / or have additional checks.
> > > 
> > > The obvious way to do this would be through dev_get_cma_area and
> > > cma_get_base and cma_get_size, that are currently not exported, which
> > > results in a build failure.
> > > 
> > > Export them to prevent such a failure.
> > 
> > Who actually uses those exports. None of the follow up patches does
> > AFAICS.
> 
> This is for the ARM Mali GPU driver that is out of tree, unfortunately.

We do not export symbols which do not have any in-tree users.

> In one case (using the legacy fbdev API), the driver wants to (and
> probably should) validate that the buffer as indeed been allocated
> from the memory allocation pool.
> 
> Rob suggested that instead of hardcoding it to cover the whole RAM
> (which defeats the purpose of that check in the first place), we used
> the memory-region bindings in the DT and follow that, which does work
> great, but we still have to retrieve the base address and size of that
> region, hence why this patches are needed.

Anyway I would suggest talking to CMA people to find a better API for
modules to use...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
