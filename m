Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA1A6B025D
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 02:34:38 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so13667704wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 23:34:38 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.10])
        by mx.google.com with ESMTPS id t9si22199581wiz.2.2015.09.14.23.34.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 23:34:37 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH V2] debugfs: don't assume sizeof(bool) to be 4 bytes
Date: Tue, 15 Sep 2015 08:30:55 +0200
Message-ID: <11729827.zzMdq0fFyE@wuerfel>
In-Reply-To: <20150915020438.GG32551@linux>
References: <81516fb9c662cc338b5af5b63fbbcde5374e0893.1442202447.git.viresh.kumar@linaro.org> <20150914160348.GA7290@kroah.com> <20150915020438.GG32551@linux>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, linaro-kernel@lists.linaro.org, "open list:NETWORKING DRIVERS WIRELESS" <linux-wireless@vger.kernel.org>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>, Avri Altman <avri.altman@intel.com>, Stanislaw Gruszka <sgruszka@redhat.com>, Jiri Slaby <jirislaby@gmail.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Brown <broonie@kernel.org>, Jaroslav Kysela <perex@perex.cz>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Kalle Valo <kvalo@qca.qualcomm.com>, Emmanuel Grumbach <emmanuel.grumbach@intel.com>, Wang Long <long.wanglong@huawei.com>, Richard Fitzgerald <rf@opensource.wolfsonmicro.com>, Ingo Molnar <mingo@kernel.org>, Johan Hedberg <johan.hedberg@gmail.com>, Davidlohr Bueso <dave@stgolabs.net>, Joonsoo Kim <js1304@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "open list:WOLFSON MICROELECTRONICS DRIVERS" <patches@opensource.wolfsonmicro.com>, Sebastian Ott <sebott@linux.vnet.ibm.com>, "open list:QUALCOMM ATHEROS ATH10K WIRELESS DRIVER" <ath10k@lists.infradead.org>, Intel Linux Wireless <ilw@linux.intel.com>, "open list:ACPI" <linux-acpi@vger.kernel.org>, "open list:QUALCOMM ATHEROS ATH9K WIRELESS DRIVER" <ath9k-devel@lists.ath9k.org>, Nick Kossifidis <mickflemm@gmail.com>, "open list:B43 WIRELESS DRIVER" <b43-dev@lists.infradead.org>, Luciano Coelho <luciano.coelho@intel.com>, Doug Thompson <dougthompson@xmission.com>, Gustavo Padovan <gustavo@padovan.org>, Sasha Levin <sasha.levin@oracle.com>, Tomas Winkler <tomas.winkler@intel.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, sboyd@codeaurora.org, Len Brown <lenb@kernel.org>, Takashi Iwai <tiwai@suse.com>, Hariprasad S <hariprasad@chelsio.com>, Johannes Berg <johannes.berg@intel.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, Vlastimil Babka <vbabka@suse.cz>, Arik Nemtsov <arik@wizery.com>, Marcel Holtmann <marcel@holtmann.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Akinobu Mita <akinobu.mita@gmail.com>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Tejun Heo <tj@kernel.org>, Florian Fainelli <f.fainelli@gmail.com>, Borislav Petkov <bp@alien8.de>, Oleg Nesterov <oleg@redhat.com>, Charles Keepax <ckeepax@opensource.wolfsonmicro.com>, Mel Gorman <mgorman@suse.de>, "moderated list:ARM64 PORT AARCH64 ARCHITECTURE" <linux-arm-kernel@lists.infradead.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, Haggai Eran <haggaie@mellanox.com>, "James E.J. Bottomley" <JBottomley@odin.com>, Chaya Rachel Ivgi <chaya.rachel.ivgi@intel.com>, "open list:CISCO SCSI HBA DRIVER" <linux-scsi@vger.kernel.org>, Brian Silverman <bsilver16384@gmail.com>, "Luis R. Rodriguez" <mcgrof@do-not-panic.com>, "open list:CXGB4 ETHERNET DRIVER CXGB4" <netdev@vger.kernel.org>, "open list:ULTRA-WIDEBAND UWB SUBSYSTEM:" <linux-usb@vger.kernel.org>, Rafael Wysocki <rjw@rjwysocki.net>, Liam Girdwood <lgirdwood@gmail.com>, Sesidhar Baddela <sebaddel@cisco.com>, open list <linux-kernel@vger.kernel.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:AMD IOMMU AMD-VI" <iommu@lists.linux-foundation.org>, Dmitry Monakhov <dmonakhov@openvz.org>, Thomas Gleixner <tglx@linutronix.de>, Narsimhulu Musini <nmusini@cisco.com>, Johannes Weiner <hannes@cmpxchg.org>, Joe Perches <joe@perches.com>, Eliad Peller <eliad@wizery.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Duyck <alexander.h.duyck@redhat.com>, Larry Finger <Larry.Finger@lwfinger.net>

On Tuesday 15 September 2015 07:34:38 Viresh Kumar wrote:
> On 14-09-15, 09:03, Greg KH wrote:
> > What ever ones you think it is relevant for :)
> 
> "Relevant" is a relevant term :)
> 
> So, the patch which defined the type bool as _Bool was added in v2.6.19 :)
> 
> 6e2182874324 ("[PATCH] Generic boolean")
> 
> So, I will try at least for v3.10+ as they are used by a lot of
> people, as they are LTS kernels. But wasn't sure if I should do it
> right from 2.6.19.

I don't think there is any use in backporting the global type change,
that is too invasive and does not change much. The specific bug
in the acpi code dates back to when acpi_ec_add_debugfs() was
added in 2.6.36, so that is the earliest point it could be backported
to. Then again, as I said it is only a problem on big-endian 64-bit
architectures, and on ACPI that would specifically mean arm64, which
only very recently gained ACPI support, so backporting to 4.1 is probably
enough.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
