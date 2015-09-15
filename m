Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id C9C4D6B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 13:47:41 -0400 (EDT)
Received: by igxx6 with SMTP id x6so17484787igx.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 10:47:41 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0139.hostedemail.com. [216.40.44.139])
        by mx.google.com with ESMTP id t11si14395281ioi.49.2015.09.15.10.47.40
        for <linux-mm@kvack.org>;
        Tue, 15 Sep 2015 10:47:41 -0700 (PDT)
Date: Tue, 15 Sep 2015 13:47:32 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH V3 2/2] debugfs: don't assume sizeof(bool) to be 4 bytes
Message-ID: <20150915134732.7ff50d03@gandalf.local.home>
In-Reply-To: <CA+55aFxVQ9jD=jUqPZt76EMe_Tb-_SA8v=rOHeR9Ljdsc6=xGQ@mail.gmail.com>
References: <9b705747a138c96c26faee5218f7b47403195b28.1442305897.git.viresh.kumar@linaro.org>
	<27d37898b4be6b9b9f31b90135f8206ca079a868.1442305897.git.viresh.kumar@linaro.org>
	<1442313464.1914.21.camel@sipsolutions.net>
	<20150915110447.GI6350@linux>
	<20150915094509.46cca84d@gandalf.local.home>
	<CA+55aFxVQ9jD=jUqPZt76EMe_Tb-_SA8v=rOHeR9Ljdsc6=xGQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Viresh Kumar <viresh.kumar@linaro.org>, Johannes Berg <johannes@sipsolutions.net>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>, Rafael Wysocki <rjw@rjwysocki.net>, "sboyd@codeaurora.org" <sboyd@codeaurora.org>, "arnd@arndb.de" <arnd@arndb.de>, Mark Brown <broonie@kernel.org>, Akinobu Mita <akinobu.mita@gmail.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Arik Nemtsov <arik@wizery.com>, "open list:QUALCOMM ATHEROS ATH10K WIRELESS DRIVER" <ath10k@lists.infradead.org>, "open list:QUALCOMM ATHEROS ATH9K WIRELESS
 DRIVER" <ath9k-devel@lists.ath9k.org>, "Altman, Avri" <avri.altman@intel.com>, "open list:B43 WIRELESS DRIVER" <b43-dev@lists.infradead.org>, Borislav Petkov <bp@alien8.de>, Brian Silverman <bsilver16384@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Charles Keepax <ckeepax@opensource.wolfsonmicro.com>, "Ivgi, Chaya Rachel" <chaya.rachel.ivgi@intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Dmitry Monakhov <dmonakhov@openvz.org>, Doug Thompson <dougthompson@xmission.com>, Eliad Peller <eliad@wizery.com>, "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>, Florian Fainelli <f.fainelli@gmail.com>, Gustavo Padovan <gustavo@padovan.org>, Haggai Eran <haggaie@mellanox.com>, Hariprasad S <hariprasad@chelsio.com>, Ingo Molnar <mingo@kernel.org>, Intel Linux Wireless <ilw@linux.intel.com>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, "James E.J. Bottomley" <JBottomley@odin.com>, Jaroslav Kysela <perex@perex.cz>, Jiri Slaby <jirislaby@gmail.com>, Joe Perches <joe@perches.com>, Joerg Roedel <joro@8bytes.org>, Johan Hedberg <johan.hedberg@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <js1304@gmail.com>, Kalle Valo <kvalo@qca.qualcomm.com>, Larry Finger <Larry.Finger@lwfinger.net>, Len Brown <lenb@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, "open list:ACPI" <linux-acpi@vger.kernel.org>, "moderated list:ARM64 PORT (AARCH64 ARCHITECTURE)" <linux-arm-kernel@lists.infradead.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:CISCO SCSI
 HBA DRIVER" <linux-scsi@vger.kernel.org>, "open list:ULTRA-WIDEBAND (UWB)
 SUBSYSTEM:" <linux-usb@vger.kernel.org>, "open list:NETWORKING DRIVERS
 (WIRELESS)" <linux-wireless@vger.kernel.org>, "Coelho, Luciano" <luciano.coelho@intel.com>, "Luis R. Rodriguez" <mcgrof@do-not-panic.com>, Marcel Holtmann <marcel@holtmann.org>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.com>, Narsimhulu Musini <nmusini@cisco.com>, "open list:CXGB4 ETHERNET DRIVER (CXGB4)" <netdev@vger.kernel.org>, Nick Kossifidis <mickflemm@gmail.com>, "open
 list:WOLFSON MICROELECTRONICS DRIVERS" <patches@opensource.wolfsonmicro.com>, Peter Zijlstra <peterz@infradead.org>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Richard Fitzgerald <rf@opensource.wolfsonmicro.com>, Sasha Levin <sasha.levin@oracle.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Sesidhar Baddela <sebaddel@cisco.com>, Stanislaw Gruszka <sgruszka@redhat.com>, Takashi Iwai <tiwai@suse.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "Winkler,
 Tomas" <tomas.winkler@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Wang Long <long.wanglong@huawei.com>, Will Deacon <will.deacon@arm.com>

On Tue, 15 Sep 2015 10:38:32 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:


> But that user interface issue doesn't seem to be the case here, an I
> can't say that I mind the patch. It looks fairly sane.

If Linus is fine with it, I'm fine with it too.

But please, next time, go easy on the Cc list. Maybe just use bcc for
those not on the list, stating that you BCC'd a lot of people to make
sure this is sane, but didn't want to spam everyone with every reply.

What do others think when there's a change that goes across the board
this much? BCC OK with you, as just an FYI, I'm doing this? Or should
just the lists be enough and if you don't see it, too bad?

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
