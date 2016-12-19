Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 423246B0277
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 04:10:05 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m203so18355151wma.2
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 01:10:05 -0800 (PST)
Received: from farmhouse.coelho.fi (paleale.coelho.fi. [176.9.41.70])
        by mx.google.com with ESMTPS id f125si14028820wmf.44.2016.12.19.01.10.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Dec 2016 01:10:03 -0800 (PST)
Message-ID: <1482138568.26174.8.camel@coelho.fi>
From: Luca Coelho <luca@coelho.fi>
Date: Mon, 19 Dec 2016 11:09:28 +0200
In-Reply-To: <1481778865-27667-6-git-send-email-mst@redhat.com>
References: <1481778865-27667-1-git-send-email-mst@redhat.com>
	 <1481778865-27667-6-git-send-email-mst@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 5/8] linux: drop __bitwise__ everywhere
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Cc: Kukjin Kim <kgene@kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>, Javier Martinez Canillas <javier@osg.samsung.com>, Russell King <linux@armlinux.org.uk>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Shaohua Li <shli@kernel.org>, Johannes Berg <johannes.berg@intel.com>, Emmanuel Grumbach <emmanuel.grumbach@intel.com>, Intel Linux Wireless <linuxwifi@intel.com>, Kalle Valo <kvalo@codeaurora.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.com>, Lee Duncan <lduncan@suse.com>, Chris Leech <cleech@redhat.com>, "James E.J.
 Bottomley" <jejb@linux.vnet.ibm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, "Nicholas A. Bellinger" <nab@linux-iscsi.org>, Jason Wang <jasowang@redhat.com>, Alexander Aring <aar@pengutronix.de>, Stefan Schmidt <stefan@osg.samsung.com>, "David S.
 Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-raid@vger.kernel.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, linux-mm@kvack.org, open-iscsi@googlegroups.com, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-wpan@vger.kernel.org

On Thu, 2016-12-15 at 07:15 +0200, Michael S. Tsirkin wrote:
> __bitwise__ used to mean "yes, please enable sparse checks
> unconditionally", but now that we dropped __CHECK_ENDIAN__
> __bitwise is exactly the same.
> There aren't many users, replace it by __bitwise everywhere.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  arch/arm/plat-samsung/include/plat/gpio-cfg.h    | 2 +-
>  drivers/md/dm-cache-block-types.h                | 6 +++---
>  drivers/net/ethernet/sun/sunhme.h                | 2 +-
>  drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h | 4 ++--

For drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h:

Acked-by: Luca Coelho <luciano.coelho@intel.com>

--
Luca.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
