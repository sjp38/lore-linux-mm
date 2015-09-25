Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB1B6B0255
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 14:52:59 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so113031274pac.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 11:52:59 -0700 (PDT)
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com. [209.85.220.54])
        by mx.google.com with ESMTPS id vs7si7390404pab.78.2015.09.25.11.52.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 11:52:58 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so113193258pad.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 11:52:58 -0700 (PDT)
Date: Fri, 25 Sep 2015 11:52:56 -0700
From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of
 'global_lock'
Message-ID: <20150925185256.GG5951@linux>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
 <1443202945.2161.8.camel@sipsolutions.net>
 <20150925184741.GF5951@linux>
 <1443206945.2161.9.camel@sipsolutions.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1443206945.2161.9.camel@sipsolutions.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Berg <johannes@sipsolutions.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linaro-kernel@lists.linaro.org, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org, linux-bluetooth@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org, linux-edac@vger.kernel.org, linux-mm@kvack.org, alsa-devel@alsa-project.org

On 25-09-15, 20:49, Johannes Berg wrote:
> Ok, then, but that means Rafael is completely wrong ...
> debugfs_create_bool() takes a *pointer* and it needs to be long-lived,
> it can't be on the stack. You also don't get a call when it changes.

Ahh, ofcourse. My bad as well...

I think we can change structure definition but will wait for Rafael's
comment before that.

-- 
viresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
