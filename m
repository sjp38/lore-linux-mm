Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id CE0C66B0038
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 13:42:39 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so30299590wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 10:42:39 -0700 (PDT)
Received: from sipsolutions.net (s3.sipsolutions.net. [5.9.151.49])
        by mx.google.com with ESMTPS id z1si6081642wjw.9.2015.09.25.10.42.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 10:42:38 -0700 (PDT)
Message-ID: <1443202945.2161.8.camel@sipsolutions.net>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of
 'global_lock'
From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 25 Sep 2015 19:42:25 +0200
In-Reply-To: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org> (sfid-20150925_184230_610012_AD3DF607)
References: 
	<e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
	 (sfid-20150925_184230_610012_AD3DF607)
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linaro-kernel@lists.linaro.org, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org, linux-bluetooth@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org, linux-edac@vger.kernel.org, linux-mm@kvack.org, alsa-devel@alsa-project.org

On Fri, 2015-09-25 at 09:41 -0700, Viresh Kumar wrote:

> Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
> ---
> V3->V4:
> - Create a local variable instead of changing type of global_lock
>   (Rafael)

Err, surely that wasn't what Rafael meant, since it's clearly
impossible to use a pointer to the stack, assign to it once, and the
expect anything to wkr at all ...

johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
