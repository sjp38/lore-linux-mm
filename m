Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0D4696B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 13:38:34 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so18793780igb.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 10:38:33 -0700 (PDT)
Received: from mail-io0-x230.google.com (mail-io0-x230.google.com. [2607:f8b0:4001:c06::230])
        by mx.google.com with ESMTPS id i34si14318363ioo.198.2015.09.15.10.38.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 10:38:33 -0700 (PDT)
Received: by iofh134 with SMTP id h134so207042956iof.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 10:38:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150915094509.46cca84d@gandalf.local.home>
References: <9b705747a138c96c26faee5218f7b47403195b28.1442305897.git.viresh.kumar@linaro.org>
	<27d37898b4be6b9b9f31b90135f8206ca079a868.1442305897.git.viresh.kumar@linaro.org>
	<1442313464.1914.21.camel@sipsolutions.net>
	<20150915110447.GI6350@linux>
	<20150915094509.46cca84d@gandalf.local.home>
Date: Tue, 15 Sep 2015 10:38:32 -0700
Message-ID: <CA+55aFxVQ9jD=jUqPZt76EMe_Tb-_SA8v=rOHeR9Ljdsc6=xGQ@mail.gmail.com>
Subject: Re: [PATCH V3 2/2] debugfs: don't assume sizeof(bool) to be 4 bytes
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Viresh Kumar <viresh.kumar@linaro.org>, Johannes Berg <johannes@sipsolutions.net>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>, Rafael Wysocki <rjw@rjwysocki.net>, "sboyd@codeaurora.org" <sboyd@codeaurora.org>, "arnd@arndb.de" <arnd@arndb.de>, Mark Brown <broonie@kernel.org>, Akinobu Mita <akinobu.mita@gmail.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Arik Nemtsov <arik@wizery.com>, "open list:QUALCOMM ATHEROS ATH10K WIRELESS DRIVER" <ath10k@lists.infradead.org>, "open list:QUALCOMM ATHEROS ATH9K WIRELESS DRIVER" <ath9k-devel@lists.ath9k.org>, "Altman, Avri" <avri.altman@intel.com>, "open list:B43 WIRELESS DRIVER" <b43-dev@lists.infradead.org>, Borislav Petkov <bp@alien8.de>, Brian Silverman <bsilver16384@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Charles Keepax <ckeepax@opensource.wolfsonmicro.com>, "Ivgi, Chaya Rachel" <chaya.rachel.ivgi@intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Dmitry Monakhov <dmonakhov@openvz.org>, Doug Thompson <dougthompson@xmission.com>, Eliad Peller <eliad@wizery.com>, "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>, Florian Fainelli <f.fainelli@gmail.com>, Gustavo Padovan <gustavo@padovan.org>, Haggai Eran <haggaie@mellanox.com>, Hariprasad S <hariprasad@chelsio.com>, Ingo Molnar <mingo@kernel.org>, Intel Linux Wireless <ilw@linux.intel.com>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, "James E.J. Bottomley" <JBottomley@odin.com>, Jaroslav Kysela <perex@perex.cz>, Jiri Slaby <jirislaby@gmail.com>, Joe Perches <joe@perches.com>, Joerg Roedel <joro@8bytes.org>, Johan Hedberg <johan.hedberg@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <js1304@gmail.com>, Kalle Valo <kvalo@qca.qualcomm.com>, Larry Finger <Larry.Finger@lwfinger.net>, Len Brown <lenb@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, "open list:ACPI" <linux-acpi@vger.kernel.org>, "moderated list:ARM64 PORT (AARCH64 ARCHITECTURE)" <linux-arm-kernel@lists.infradead.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:CISCO SCSI HBA DRIVER" <linux-scsi@vger.kernel.org>, "open list:ULTRA-WIDEBAND (UWB) SUBSYSTEM:" <linux-usb@vger.kernel.org>, "open list:NETWORKING DRIVERS (WIRELESS)" <linux-wireless@vger.kernel.org>, "Coelho, Luciano" <luciano.coelho@intel.com>, "Luis R. Rodriguez" <mcgrof@do-not-panic.com>, Marcel Holtmann <marcel@holtmann.org>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.com>, Narsimhulu Musini <nmusini@cisco.com>, "open list:CXGB4 ETHERNET DRIVER (CXGB4)" <netdev@vger.kernel.org>, Nick Kossifidis <mickflemm@gmail.com>, "open list:WOLFSON MICROELECTRONICS DRIVERS" <patches@opensource.wolfsonmicro.com>, Peter Zijlstra <peterz@infradead.org>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Richard Fitzgerald <rf@opensource.wolfsonmicro.com>, Sasha Levin <sasha.levin@oracle.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Sesidhar Baddela <sebaddel@cisco.com>, Stanislaw Gruszka <sgruszka@redhat.com>, Takashi Iwai <tiwai@suse.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "Winkler, Tomas" <tomas.winkler@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Wang Long <long.wanglong@huawei.com>, Will Deacon <will.deacon@arm.com>

On Tue, Sep 15, 2015 at 6:45 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
>
> Linus, This patch changes a lot of u32s into bools in structures.
> What's your take on that?

So in general, I'd tend to prefer "bool" to be used primarily as a
return value for functions, but I have to say, in the case of
something that is explicitly called "debugfs_create_bool()" it kind of
makes sense to actually take a bool pointer.

In structures, it depends a bit on usage. If the intent is to pack
things better, I tend to prefer using "char" etc that is explicitly a
byte. Or just use explicit bits in an "unsigned int flags" or
something. Because while "bool" is _typically_ one byte, but it's very
very explicitly documented to not be guaranteed that way, and there
are legacy models where "bool" ends up being "int".

But in this case, the use of "bool" is not about packing or anything
like that, it is more about the logical data type for
"debugfs_create_bool()", and so I don't mind "bool" in this context
even in structures.

But exactly because of the whole ambiguoity about "bool", what I do
*not* want to see in any way is "bool" in structures that are exported
to user space. That's when we want primarily those explicitly sized
types like "u32" etc. We should generally try to avoid even things
like "int" in those kinds of structures, and bool is even _less_ well
defined than "int" is.

But that user interface issue doesn't seem to be the case here, an I
can't say that I mind the patch. It looks fairly sane.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
