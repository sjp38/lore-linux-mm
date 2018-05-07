Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id BABE76B000C
	for <linux-mm@kvack.org>; Mon,  7 May 2018 09:25:54 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id q67-v6so6718578wrb.12
        for <linux-mm@kvack.org>; Mon, 07 May 2018 06:25:54 -0700 (PDT)
Received: from perceval.ideasonboard.com (perceval.ideasonboard.com. [2001:4b98:dc2:55:216:3eff:fef7:d647])
        by mx.google.com with ESMTPS id e15-v6si9439959wrj.238.2018.05.07.06.25.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 May 2018 06:25:53 -0700 (PDT)
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: Are media drivers abusing of GFP_DMA? - was: Re: [LSF/MM TOPIC NOTES] x86 ZONE_DMA love
Date: Mon, 07 May 2018 16:26:08 +0300
Message-ID: <3561479.qPIcrWnXEC@avalon>
In-Reply-To: <20180505130815.53a26955@vento.lan>
References: <20180426215406.GB27853@wotan.suse.de> <20180505130815.53a26955@vento.lan>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: Fabien Dessenne <fabien.dessenne@st.com>, Jean-Christophe Trotin <jean-christophe.trotin@st.com>, Yasunari Takiguchi <Yasunari.Takiguchi@sony.com>, Sakari Ailus <sakari.ailus@linux.intel.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org

Hi Mauro,

On Saturday, 5 May 2018 19:08:15 EEST Mauro Carvalho Chehab wrote:
> There was a recent discussion about the use/abuse of GFP_DMA flag when
> allocating memories at LSF/MM 2018 (see Luis notes enclosed).
> 
> The idea seems to be to remove it, using CMA instead. Before doing that,
> better to check if what we have on media is are valid use cases for it, or
> if it is there just due to some misunderstanding (or because it was
> copied from some other code).
> 
> Hans de Goede sent us today a patch stopping abuse at gspca, and I'm
> also posting today two other patches meant to stop abuse of it on USB
> drivers. Still, there are 4 platform drivers using it:
> 
> 	$ git grep -l -E "GFP_DMA\\b" drivers/media/
> 	drivers/media/platform/omap3isp/ispstat.c
> 	drivers/media/platform/sti/bdisp/bdisp-hw.c
> 	drivers/media/platform/sti/hva/hva-mem.c
> 	drivers/media/spi/cxd2880-spi.c
> 
> Could you please check if GFP_DMA is really needed there, or if it is
> just because of some cut-and-paste from some other place?

I started looking at that for the omap3isp driver but Sakari beat me at 
submitting a patch. GFP_DMA isn't needed for omap3isp.

-- 
Regards,

Laurent Pinchart
