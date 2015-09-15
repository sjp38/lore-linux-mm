Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 053AE6B0253
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:04:54 -0400 (EDT)
Received: by igcrk20 with SMTP id rk20so11633913igc.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 04:04:53 -0700 (PDT)
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com. [209.85.220.51])
        by mx.google.com with ESMTPS id h127si6986861ioh.207.2015.09.15.04.04.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 04:04:52 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so174444784pac.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 04:04:52 -0700 (PDT)
Date: Tue, 15 Sep 2015 16:34:47 +0530
From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [PATCH V3 2/2] debugfs: don't assume sizeof(bool) to be 4 bytes
Message-ID: <20150915110447.GI6350@linux>
References: <9b705747a138c96c26faee5218f7b47403195b28.1442305897.git.viresh.kumar@linaro.org>
 <27d37898b4be6b9b9f31b90135f8206ca079a868.1442305897.git.viresh.kumar@linaro.org>
 <1442313464.1914.21.camel@sipsolutions.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442313464.1914.21.camel@sipsolutions.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Berg <johannes@sipsolutions.net>
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>, Rafael Wysocki <rjw@rjwysocki.net>, "sboyd@codeaurora.org" <sboyd@codeaurora.org>, "arnd@arndb.de" <arnd@arndb.de>, Mark Brown <broonie@kernel.org>, Akinobu Mita <akinobu.mita@gmail.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, "moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..." <alsa-devel@alsa-project.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Arik Nemtsov <arik@wizery.com>, "open list:QUALCOMM ATHEROS ATH10K WIRELESS DRIVER" <ath10k@lists.infradead.org>, "open list:QUALCOMM ATHEROS ATH9K WIRELESS DRIVER" <ath9k-devel@lists.ath9k.org>, "Altman, Avri" <avri.altman@intel.com>, "open list:B43 WIRELESS DRIVER" <b43-dev@lists.infradead.org>, Borislav Petkov <bp@alien8.de>, Brian Silverman <bsilver16384@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Charles Keepax <ckeepax@opensource.wolfsonmicro.com>, "Ivgi, Chaya Rachel" <chaya.rachel.ivgi@intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Dmitry Monakhov <dmonakhov@openvz.org>, Doug Thompson <dougthompson@xmission.com>, Eliad Peller <eliad@wizery.com>, "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>, Florian Fainelli <f.fainelli@gmail.com>, Gustavo Padovan <gustavo@padovan.org>, Haggai Eran <haggaie@mellanox.com>, Hariprasad S <hariprasad@chelsio.com>, Ingo Molnar <mingo@kernel.org>, Intel Linux Wireless <ilw@linux.intel.com>, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, "James E.J. Bottomley" <JBottomley@odin.com>, Jaroslav Kysela <perex@perex.cz>, Jiri Slaby <jirislaby@gmail.com>, Joe Perches <joe@perches.com>, Joerg Roedel <joro@8bytes.org>, Johan Hedberg <johan.hedberg@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <js1304@gmail.com>, Kalle Valo <kvalo@qca.qualcomm.com>, Larry Finger <Larry.Finger@lwfinger.net>, Len Brown <lenb@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, "open list:ACPI" <linux-acpi@vger.kernel.org>, "moderated list:ARM64 PORT (AARCH64 ARCHITECTURE)" <linux-arm-kernel@lists.infradead.org>, "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:EDAC-CORE" <linux-edac@vger.kernel.org>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:CISCO SCSI HBA DRIVER" <linux-scsi@vger.kernel.org>, "open list:ULTRA-WIDEBAND (UWB) SUBSYSTEM:" <linux-usb@vger.kernel.org>, "open list:NETWORKING DRIVERS (WIRELESS)" <linux-wireless@vger.kernel.org>, "Coelho, Luciano" <luciano.coelho@intel.com>, "Luis R. Rodriguez" <mcgrof@do-not-panic.com>, Marcel Holtmann <marcel@holtmann.org>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.com>, Narsimhulu Musini <nmusini@cisco.com>, "open list:CXGB4 ETHERNET DRIVER (CXGB4)" <netdev@vger.kernel.org>, Nick Kossifidis <mickflemm@gmail.com>, "open list:WOLFSON MICROELECTRONICS DRIVERS" <patches@opensource.wolfsonmicro.com>, Peter Zijlstra <peterz@infradead.org>, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Richard Fitzgerald <rf@opensource.wolfsonmicro.com>, Sasha Levin <sasha.levin@oracle.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Sesidhar Baddela <sebaddel@cisco.com>, Stanislaw Gruszka <sgruszka@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Takashi Iwai <tiwai@suse.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "Winkler, Tomas" <tomas.winkler@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Wang Long <long.wanglong@huawei.com>, Will Deacon <will.deacon@arm.com>

Hi Johannes,

On 15-09-15, 12:37, Johannes Berg wrote:
> This email has far too many people Cc'ed on it - I don't think vger is
> even accepting it for that reason. You should probably restrict it to
> just a few lists when you resubmit.

Hmm, I know the list is too long and yes its blocked for Admin's
approval on most of the lists. But that's what was generated by
get_maintainers and I didn't wanted to miss cc'ing anybody who might
be able to catch a bug in there.

> > The problem with current code is that it reads/writes 4 bytes for a
> > boolean, which will read/update 3 excess bytes following the boolean
> > variable (when sizeof(bool) is 1 byte). And that can lead to hard to 
> > fix bugs. It was a nightmare cracking this one.
> 
> Unless you're ignoring (or worse, casting away) type warnings, there's
> no problem/bug at all, you just have to define all the variables used
> with debugfs_create_bool() as actual u32 variables.
> 
> It sounds like you are/were doing something like the following:
> 
> bool a, b, c;
> ...
> debugfs_create_bool("a", 0600, dir, (u32 *)&a);
> 
> which is quite clearly invalid.
> 
> Had you properly defined them as u32, as everyone (except for the ACPI
> case) does, there wouldn't have been any problem:
> 
> u32 a, b, c;
> ...
> debugfs_create_bool("a", 0600, dir, &a);
> 
> 
> As far as I can tell, there's no bug in the API. It might be a bit
> strange to have a set of functions called debugfs_create_<type> and
> then one of them doesn't actually use the type from the name, but
> that's only a problem if you blindly add casts or ignore the compiler
> warnings you'd get without casts.
> 
> In other words, I think your commit log is extremely misleading. The
> API perhaps has some inconsistent naming, but all this talk about the
> sizeof(bool) etc. is simply completely irrelevant since "bool" is not
> the type used here at all. There's nothing to fix in any of the code
> you're changing (again, apart from ACPI.)
> 
> That said, I don't actually object to this change itself, being able to
> actually use bool variables with debugfs_create_bool would be nice.
> However, that shouldn't be documented as a bugfix or anything like
> that, merely as a cleanup to make the API naming more consistent and to
> be able to use the (smaller and often more convenient) bool type.
> 
> Clearly, it would also lead to less confusion, as we see in ACPI and
> hear from your OPP code. Note that ACPI is even more confused though
> since it uses "unsigned long", so it's entirely possible that somebody
> actually thought about that case and decided not to worry about 64-bit
> big-endian platforms.
> 
> Of course this also means that only the ACPI patch is a candidate for s
> table.

Yeah, that's right. Its just a trivial cleanup rather. What about this
simple changelog instead?

--
viresh

-------------------------8<-------------------------

Subject: [PATCH] debugfs: Pass bool pointer to debugfs_create_bool()

Its a bit odd that debugfs_create_bool() takes 'u32 *' as an argument,
when all it needs is a boolean pointer.

It would be better to update this API to make it accept 'bool *'
instead, as that will make it more consistent and often more convenient.
Over that bool takes just a byte.

That required updates to all user sites as well in a single commit.
regmap core was also using debugfs_{read|write}_file_bool(), directly
and variable types were updated for that to be bool as well.

Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
