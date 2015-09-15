Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id AE8F96B0254
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 10:12:15 -0400 (EDT)
Received: by obbzf10 with SMTP id zf10so80110590obb.2
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:12:15 -0700 (PDT)
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com. [209.85.220.48])
        by mx.google.com with ESMTPS id y3si9831074oiy.124.2015.09.15.07.12.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 07:12:14 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so177998852pad.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:12:14 -0700 (PDT)
Date: Tue, 15 Sep 2015 19:42:08 +0530
From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [PATCH V3 2/2] debugfs: don't assume sizeof(bool) to be 4 bytes
Message-ID: <20150915141208.GK6350@linux>
References: <9b705747a138c96c26faee5218f7b47403195b28.1442305897.git.viresh.kumar@linaro.org>
 <27d37898b4be6b9b9f31b90135f8206ca079a868.1442305897.git.viresh.kumar@linaro.org>
 <20150915100454.70dcc04d@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150915100454.70dcc04d@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: gregkh@linuxfoundation.org, linaro-kernel@lists.linaro.org, Rafael Wysocki <rjw@rjwysocki.net>, sboyd@codeaurora.org, arnd@arndb.de, Mark Brown <broonie@kernel.org>, Akinobu Mita <akinobu.mita@gmail.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Arik Nemtsov <arik@wizery.com>, "open list:QUALCOMM ATHEROS ATH10K WIRELESS DRIVER" <ath10k@lists.infradead.org>, "open list:QUALCOMM ATHEROS ATH9K WIRELESS DRIVER" <ath9k-devel@lists.ath9k.org>, Avri Altman <avri.altman@intel.com>, "open list:B43 WIRELESS DRIVER" <b43-dev@lists.infradead.org>, Borislav Petkov <bp@alien8.de>, Brian Silverman <bsilver16384@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Charles Keepax <ckeepax@opensource.wolfsonmicro.com>, Chaya Rachel Ivgi <chaya.rachel.ivgi@intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Dmitry Monakhov <dmonakhov@openvz.org>, Doug Thompson <dougthompson@xmission.com>, Eliad Peller <eliad@wizery.com>, Emmanuel Grumbach <emmanuel.grumbach@intel.com>, Florian Fainelli <f.fainelli@gmail.com>, Gustavo Padovan <gustavo@padovan.org>, Haggai Eran <haggaie@mellanox.com>, Hariprasad S <hariprasad@chelsio.com>, Ingo Molnar <mingo@kernel.org>, Intel Linux Wireless <ilw@linux.intel.com>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, "James E.J. Bottomley" <JBottomley@odin.com>, Jaroslav Kysela <perex@perex.cz>, Jiri Slaby <jirislaby@gmail.com>, Joe Perches <joe@perches.com>, Joerg Roedel <joro@8bytes.org>, Johan Hedberg <johan.hedberg@gmail.com>, Johannes Berg <johannes.berg@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <js1304@gmail.com>, Kalle Valo <kvalo@qca.qualcomm.com>, Larry Finger <Larry.Finger@lwfinger.net>, Len Brown <lenb@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, "open list:ACPI" <linux-acpi@vger.kernel.org>, "moderated list:ARM64 PORT (AARCH64 ARCHITECTURE)" <linux-arm-kernel@lists.infradead.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:CISCO SCSI HBA DRIVER" <linux-scsi@vger.kernel.org>, "open list:ULTRA-WIDEBAND (UWB) SUBSYSTEM:" <linux-usb@vger.kernel.org>, "open list:NETWORKING DRIVERS (WIRELESS)" <linux-wireless@vger.kernel.org>, Luciano Coelho <luciano.coelho@intel.com>, "Luis R. Rodriguez" <mcgrof@do-not-panic.com>, Marcel Holtmann <marcel@holtmann.org>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.com>, Narsimhulu Musini <nmusini@cisco.com>, "open list:CXGB4 ETHERNET DRIVER (CXGB4)" <netdev@vger.kernel.org>, Nick Kossifidis <mickflemm@gmail.com>, "open list:WOLFSON MICROELECTRONICS DRIVERS" <patches@opensource.wolfsonmicro.com>, Peter Zijlstra <peterz@infradead.org>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Richard Fitzgerald <rf@opensource.wolfsonmicro.com>, Sasha Levin <sasha.levin@oracle.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Sesidhar Baddela <sebaddel@cisco.com>, Stanislaw Gruszka <sgruszka@redhat.com>, Takashi Iwai <tiwai@suse.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Tomas Winkler <tomas.winkler@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Wang Long <long.wanglong@huawei.com>, Will Deacon <will.deacon@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>

On 15-09-15, 10:04, Steven Rostedt wrote:
> On Tue, 15 Sep 2015 14:04:59 +0530
> Viresh Kumar <viresh.kumar@linaro.org> wrote:
> 
> > diff --git a/drivers/acpi/ec.c b/drivers/acpi/ec.c
> > index 2614a839c60d..f11e17ad7834 100644
> > --- a/drivers/acpi/ec.c
> > +++ b/drivers/acpi/ec.c
> > @@ -1237,7 +1237,7 @@ ec_parse_device(acpi_handle handle, u32 Level, void *context, void **retval)
> >  	/* Use the global lock for all EC transactions? */
> >  	tmp = 0;
> >  	acpi_evaluate_integer(handle, "_GLK", NULL, &tmp);
> > -	ec->global_lock = tmp;
> > +	ec->global_lock = !!tmp;
> 
> BTW, the above is equivalent if global_lock is of type bool.

Ah, yes. Thanks for letting me know (I just testedit as well).

But will it look sane enough to set a boolean to anything apart from
true/false or 1/0? Yes, it will always be set to 0/1 only, but still..

-- 
viresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
