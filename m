Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF0FB6B0033
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 18:46:52 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 107so6820161wra.7
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 15:46:52 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i206si8346408wmf.180.2017.11.20.15.46.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 15:46:51 -0800 (PST)
Date: Mon, 20 Nov 2017 15:46:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] zswap: Same-filled pages handling
Message-Id: <20171120154648.6c2f96804c4c1668bd8d572a@linux-foundation.org>
In-Reply-To: <20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
References: <CGME20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
	<20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: srividya.dr@samsung.com
Cc: "sjenning@redhat.com" <sjenning@redhat.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "penberg@kernel.org" <penberg@kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, RAJIB BASU <rajib.basu@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

On Wed, 18 Oct 2017 10:48:32 +0000 Srividya Desireddy <srividya.dr@samsung.com> wrote:

> +/* Enable/disable handling same-value filled pages (enabled by default) */
> +static bool zswap_same_filled_pages_enabled = true;
> +module_param_named(same_filled_pages_enabled, zswap_same_filled_pages_enabled,
> +		   bool, 0644);

Do we actually need this?  Being able to disable the new feature shows
a certain lack of confidence ;) I guess we can remove it later as that
confidence grows.

Please send a patch to document this parameter in
Documentation/vm/zswap.txt.  And if you have time, please check that
the rest of that file is up-to-date?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
