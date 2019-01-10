Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 976C38E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 09:07:31 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id d3so6342822pgv.23
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 06:07:31 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j6si15207902pfc.57.2019.01.10.06.07.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 Jan 2019 06:07:30 -0800 (PST)
Date: Thu, 10 Jan 2019 06:07:26 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rpmsg PATCH v2 1/1] rpmsg: virtio_rpmsg_bus: fix unexpected
 huge vmap mappings
Message-ID: <20190110140726.GA6223@infradead.org>
References: <1545812449-32455-1-git-send-email-fugang.duan@nxp.com>
 <CAKv+Gu-zfTZAZfiQt1iUn9otqeDkJP-y-siuBUrWUR-Kq=BsVQ@mail.gmail.com>
 <20181226145048.GA24307@infradead.org>
 <VI1PR0402MB3600AC833D6F29ECC34C8D4CFFB60@VI1PR0402MB3600.eurprd04.prod.outlook.com>
 <20181227121901.GA20892@infradead.org>
 <VI1PR0402MB3600799A06B6BFE5EBF8837FFFB70@VI1PR0402MB3600.eurprd04.prod.outlook.com>
 <VI1PR0402MB36000BD05AF4B242E13D9D05FF840@VI1PR0402MB3600.eurprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <VI1PR0402MB36000BD05AF4B242E13D9D05FF840@VI1PR0402MB3600.eurprd04.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Duan <fugang.duan@nxp.com>
Cc: Christoph Hellwig <hch@infradead.org>, "bjorn.andersson@linaro.org" <bjorn.andersson@linaro.org>, "ohad@wizery.com" <ohad@wizery.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Robin Murphy <robin.murphy@arm.com>, "linux-remoteproc@vger.kernel.org" <linux-remoteproc@vger.kernel.org>, "anup@brainfault.org" <anup@brainfault.org>, "loic.pallardy@st.com" <loic.pallardy@st.com>, dl-linux-imx <linux-imx@nxp.com>, Richard Zhu <hongxing.zhu@nxp.com>, Jason Liu <jason.hui.liu@nxp.com>, Peng Fan <peng.fan@nxp.com>

On Thu, Jan 10, 2019 at 01:45:20AM +0000, Andy Duan wrote:
> Do you have any other comments for the patch ? 
> Current driver break remoteproc on NXP i.MX8 platform , the patch is bugfix the virtio rpmsg bus, we hope the patch enter to next and stable tree if no other comments. 

The answer remains that you CAN NOT call vmalloc_to_page or virt_to_page
on DMA coherent memory, and the driver has been broken ever since it
was merged.  We need to fix the root cause and not the symptom.
