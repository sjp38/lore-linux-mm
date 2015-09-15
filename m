Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 343DD6B0254
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 10:05:09 -0400 (EDT)
Received: by igxx6 with SMTP id x6so13447155igx.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:05:09 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0211.hostedemail.com. [216.40.44.211])
        by mx.google.com with ESMTP id kj5si6931429igb.0.2015.09.15.07.05.05
        for <linux-mm@kvack.org>;
        Tue, 15 Sep 2015 07:05:05 -0700 (PDT)
Date: Tue, 15 Sep 2015 10:04:54 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH V3 2/2] debugfs: don't assume sizeof(bool) to be 4 bytes
Message-ID: <20150915100454.70dcc04d@gandalf.local.home>
In-Reply-To: <27d37898b4be6b9b9f31b90135f8206ca079a868.1442305897.git.viresh.kumar@linaro.org>
References: <9b705747a138c96c26faee5218f7b47403195b28.1442305897.git.viresh.kumar@linaro.org>
	<27d37898b4be6b9b9f31b90135f8206ca079a868.1442305897.git.viresh.kumar@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: gregkh@linuxfoundation.org, linaro-kernel@lists.linaro.org, Rafael Wysocki <rjw@rjwysocki.net>, sboyd@codeaurora.org, arnd@arndb.de, Mark Brown <broonie@kernel.org>, Akinobu Mita <akinobu.mita@gmail.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, alsa-devel@alsa-project.org, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Arik Nemtsov <arik@wizery.com>, "open
 list:QUALCOMM ATHEROS ATH10K WIRELESS DRIVER" <ath10k@lists.infradead.org>, ath9k-devel@lists.ath9k.org, Avri Altman <avri.altman@intel.com>, "open list:B43
 WIRELESS DRIVER" <b43-dev@lists.infradead.org>, Borislav Petkov <bp@alien8.de>, Brian Silverman <bsilver16384@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Charles Keepax <ckeepax@opensource.wolfsonmicro.com>, Chaya Rachel Ivgi <chaya.rachel.ivgi@intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Dmitry Monakhov <dmonakhov@openvz.org>, Doug Thompson <dougthompson@xmission.com>, Eliad Peller <eliad@wizery.com>, Emmanuel Grumbach <emmanuel.grumbach@intel.com>, Florian Fainelli <f.fainelli@gmail.com>, Gustavo Padovan <gustavo@padovan.org>, Haggai Eran <haggaie@mellanox.com>, Hariprasad S <hariprasad@chelsio.com>, Ingo Molnar <mingo@kernel.org>, Intel Linux Wireless <ilw@linux.intel.com>, "open list:AMD IOMMU AMD-VI" <iommu@lists.linux-foundation.org>, "James
 E.J. Bottomley" <JBottomley@odin.com>, Jaroslav Kysela <perex@perex.cz>, Jiri Slaby <jirislaby@gmail.com>, Joe Perches <joe@perches.com>, Joerg Roedel <joro@8bytes.org>, Johan Hedberg <johan.hedberg@gmail.com>, Johannes Berg <johannes.berg@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <js1304@gmail.com>, Kalle Valo <kvalo@qca.qualcomm.com>, Larry Finger <Larry.Finger@lwfinger.net>, Len Brown <lenb@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, "open list:ACPI" <linux-acpi@vger.kernel.org>, "moderated list:ARM64 PORT AARCH64
 ARCHITECTURE" <linux-arm-kernel@lists.infradead.org>, "open list:BLUETOOTH
 DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, open list <linux-kernel@vger.kernel.org>, "open
 list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:CISCO SCSI
 HBA DRIVER" <linux-scsi@vger.kernel.org>, "open list:ULTRA-WIDEBAND UWB
 SUBSYSTEM:" <linux-usb@vger.kernel.org>, "open list:NETWORKING DRIVERS
 WIRELESS" <linux-wireless@vger.kernel.org>, Luciano Coelho <luciano.coelho@intel.com>, "Luis R. Rodriguez" <mcgrof@do-not-panic.com>, Marcel Holtmann <marcel@holtmann.org>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.com>, Narsimhulu Musini <nmusini@cisco.com>, "open
 list:CXGB4 ETHERNET DRIVER CXGB4" <netdev@vger.kernel.org>, Nick Kossifidis <mickflemm@gmail.com>, "open list:WOLFSON MICROELECTRONICS
 DRIVERS" <patches@opensource.wolfsonmicro.com>, Peter Zijlstra <peterz@infradead.org>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Richard Fitzgerald <rf@opensource.wolfsonmicro.com>, Sasha Levin <sasha.levin@oracle.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Sesidhar Baddela <sebaddel@cisco.com>, Stanislaw Gruszka <sgruszka@redhat.com>, Takashi Iwai <tiwai@suse.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Tomas Winkler <tomas.winkler@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Wang Long <long.wanglong@huawei.com>, Will Deacon <will.deacon@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 15 Sep 2015 14:04:59 +0530
Viresh Kumar <viresh.kumar@linaro.org> wrote:

> diff --git a/drivers/acpi/ec.c b/drivers/acpi/ec.c
> index 2614a839c60d..f11e17ad7834 100644
> --- a/drivers/acpi/ec.c
> +++ b/drivers/acpi/ec.c
> @@ -1237,7 +1237,7 @@ ec_parse_device(acpi_handle handle, u32 Level, void *context, void **retval)
>  	/* Use the global lock for all EC transactions? */
>  	tmp = 0;
>  	acpi_evaluate_integer(handle, "_GLK", NULL, &tmp);
> -	ec->global_lock = tmp;
> +	ec->global_lock = !!tmp;

BTW, the above is equivalent if global_lock is of type bool.

-- Steve

>  	ec->handle = handle;
>  	return AE_CTRL_TERMINATE;
>  }
> diff --git a/drivers/acpi/internal.h b/drivers/acpi/internal.h
> index 9db196de003c..5a72e2b140fc 100644
> --- a/drivers/acpi/internal.h
> +++ b/drivers/acpi/internal.h
> @@ -138,7 +138,7 @@ struct acpi_ec {
>  	unsigned long gpe;
>  	unsigned long command_addr;
>  	unsigned long data_addr;
> -	u32 global_lock;
> +	bool global_lock;
>  	unsigned long flags;
>  	unsigned long reference_count;
>  	struct mutex mutex;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
