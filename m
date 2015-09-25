Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7ECF16B0258
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 16:05:10 -0400 (EDT)
Received: by lahh2 with SMTP id h2so108484917lah.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 13:05:09 -0700 (PDT)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id cb6si2383274lad.160.2015.09.25.13.05.08
        for <linux-mm@kvack.org>;
        Fri, 25 Sep 2015 13:05:09 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of 'global_lock'
Date: Fri, 25 Sep 2015 22:33:24 +0200
Message-ID: <4357538.Wlf88yQie6@vostro.rjw.lan>
In-Reply-To: <4331507.W3ZDWldbWu@vostro.rjw.lan>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org> <20150925185256.GG5951@linux> <4331507.W3ZDWldbWu@vostro.rjw.lan>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Johannes Berg <johannes@sipsolutions.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linaro-kernel@lists.linaro.org, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org, linux-bluetooth@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org, linux-edac@vger.kernel.org, linux-mm@kvack.org, alsa-devel@alsa-project.org

On Friday, September 25, 2015 10:26:22 PM Rafael J. Wysocki wrote:
> On Friday, September 25, 2015 11:52:56 AM Viresh Kumar wrote:
> > On 25-09-15, 20:49, Johannes Berg wrote:
> > > Ok, then, but that means Rafael is completely wrong ...
> > > debugfs_create_bool() takes a *pointer* and it needs to be long-lived,
> > > it can't be on the stack. You also don't get a call when it changes.
> > 
> > Ahh, ofcourse. My bad as well...
> 
> Well, sorry about the wrong suggestion.
> 
> > I think we can change structure definition but will wait for Rafael's
> > comment before that.
> 
> OK, change the structure then.

But here's a question.

You're going to change that into bool in the next patch, right?

So what if bool is a byte and the field is not word-aligned and changing
that byte requires a read-modify-write.  How do we ensure that things remain
consistent in that case?

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
