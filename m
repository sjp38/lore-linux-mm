Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 069A06B0256
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 11:47:23 -0400 (EDT)
Received: by iofb144 with SMTP id b144so171098919iof.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:47:22 -0700 (PDT)
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com. [209.85.220.48])
        by mx.google.com with ESMTPS id m5si8629477igx.20.2015.09.14.08.47.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 08:47:22 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so147368366pad.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:47:22 -0700 (PDT)
Date: Mon, 14 Sep 2015 21:17:08 +0530
From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [PATCH V2] debugfs: don't assume sizeof(bool) to be 4 bytes
Message-ID: <20150914154708.GF32551@linux>
References: <81516fb9c662cc338b5af5b63fbbcde5374e0893.1442202447.git.viresh.kumar@linaro.org>
 <1708603.aKpYchk1pa@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1708603.aKpYchk1pa@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linaro-kernel@lists.linaro.org, gregkh@linuxfoundation.org, "open list:NETWORKING DRIVERS WIRELESS" <linux-wireless@vger.kernel.org>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>, Avri Altman <avri.altman@intel.com>, Stanislaw Gruszka <sgruszka@redhat.com>, Jiri Slaby <jirislaby@gmail.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Brown <broonie@kernel.org>, Jaroslav Kysela <perex@perex.cz>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Kalle Valo <kvalo@qca.qualcomm.com>, Emmanuel Grumbach <emmanuel.grumbach@intel.com>, Wang Long <long.wanglong@huawei.com>, Richard Fitzgerald <rf@opensource.wolfsonmicro.com>, Ingo Molnar <mingo@kernel.org>, Johan Hedberg <johan.hedberg@gmail.com>, Davidlohr Bueso <dave@stgolabs.net>, Joonsoo Kim <js1304@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "open list:WOLFSON MICROELECTRONICS DRIVERS" <patches@opensource.wolfsonmicro.com>, Sebastian Ott <sebott@linux.vnet.ibm.com>, "open list:QUALCOMM ATHEROS ATH10K WIRELESS DRIVER" <ath10k@lists.infradead.org>, Intel Linux Wireless <ilw@linux.intel.com>, "open list:ACPI" <linux-acpi@vger.kernel.org>, "open list:QUALCOMM ATHEROS ATH9K WIRELESS DRIVER" <ath9k-devel@lists.ath9k.org>, Nick Kossifidis <mickflemm@gmail.com>, "open list:B43 WIRELESS DRIVER" <b43-dev@lists.infradead.org>, Luciano Coelho <luciano.coelho@intel.com>, Doug Thompson <dougthompson@xmission.com>, Gustavo Padovan <gustavo@padovan.org>, Sasha Levin <sasha.levin@oracle.com>, Tomas Winkler <tomas.winkler@intel.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, sboyd@codeaurora.org, Len Brown <lenb@kernel.org>, Takashi Iwai <tiwai@suse.com>, Hariprasad S <hariprasad@chelsio.com>, Johannes Berg <johannes.berg@intel.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, Vlastimil Babka <vbabka@suse.cz>, Arik Nemtsov <arik@wizery.com>, Marcel Holtmann <marcel@holtmann.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Akinobu Mita <akinobu.mita@gmail.com>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Tejun Heo <tj@kernel.org>, Florian Fainelli <f.fainelli@gmail.com>, Borislav Petkov <bp@alien8.de>, Oleg Nesterov <oleg@redhat.com>, Charles Keepax <ckeepax@opensource.wolfsonmicro.com>, Mel Gorman <mgorman@suse.de>, "moderated list:ARM64 PORT AARCH64 ARCHITECTURE" <linux-arm-kernel@lists.infradead.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, Haggai Eran <haggaie@mellanox.com>, "James E.J. Bottomley" <JBottomley@odin.com>, Chaya Rachel Ivgi <chaya.rachel.ivgi@intel.com>, "open list:CISCO SCSI HBA DRIVER" <linux-scsi@vger.kernel.org>, Brian Silverman <bsilver16384@gmail.com>, "Luis R. Rodriguez" <mcgrof@do-not-panic.com>, "open list:CXGB4 ETHERNET DRIVER CXGB4" <netdev@vger.kernel.org>, "open list:ULTRA-WIDEBAND UWB SUBSYSTEM:" <linux-usb@vger.kernel.org>, Rafael Wysocki <rjw@rjwysocki.net>, Liam Girdwood <lgirdwood@gmail.com>, Sesidhar Baddela <sebaddel@cisco.com>, open list <linux-kernel@vger.kernel.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:AMD IOMMU AMD-VI" <iommu@lists.linux-foundation.org>, Dmitry Monakhov <dmonakhov@openvz.org>, Thomas Gleixner <tglx@linutronix.de>, Narsimhulu Musini <nmusini@cisco.com>, Johannes Weiner <hannes@cmpxchg.org>, Joe Perches <joe@perches.com>, Eliad Peller <eliad@wizery.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Duyck <alexander.h.duyck@redhat.com>, Larry Finger <Larry.Finger@lwfinger.net>

On 14-09-15, 17:39, Arnd Bergmann wrote:
> On Monday 14 September 2015 09:21:54 Viresh Kumar wrote:
> > diff --git a/drivers/acpi/ec_sys.c b/drivers/acpi/ec_sys.c
> > index b4c216bab22b..bea8e425a8de 100644
> > --- a/drivers/acpi/ec_sys.c
> > +++ b/drivers/acpi/ec_sys.c
> > @@ -128,7 +128,7 @@ static int acpi_ec_add_debugfs(struct acpi_ec *ec, unsigned int ec_device_count)
> >  	if (!debugfs_create_x32("gpe", 0444, dev_dir, (u32 *)&first_ec->gpe))
> >  		goto error;
> >  	if (!debugfs_create_bool("use_global_lock", 0444, dev_dir,
> > -				 (u32 *)&first_ec->global_lock))
> > +				 &first_ec->global_lock))
> >  		goto error;
> >  
> >  	if (write_support)
> 
> This one might need a separate patch that can be backported to stable, as
> the original code is already broken on big-endian 64-bit machines:
> global_lock is 'unsigned long'.

Hmmm, so you suggest a single patch that will do s/unsigned long/u32
and that will be followed with this patch (almost) as is. Right?

Also, regarding the stable thing, we will surely not be able to
backport it straight away. But we should get it backported for sure.

@Greg: What all kernel versions you want this to be backported for?

-- 
viresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
