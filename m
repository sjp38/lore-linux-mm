Return-Path: <owner-linux-mm@kvack.org>
From: owner-linux-mm@kvack.org
Subject: BOUNCE linux-mm@kvack.org: Header field too long (>2048)
Message-Id: <20120330200458.65C1C6B004A@kanga.kvack.org>
Date: Fri, 30 Mar 2012 16:04:58 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm-approval@kvack.org

>From bcrl@kvack.org  Fri Mar 30 16:04:58 2012
Return-Path: <bcrl@kvack.org>
X-Original-To: int-list-linux-mm@kvack.org
Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46AFA6B004D; Fri, 30 Mar 2012 16:04:58 -0400 (EDT)
X-Original-To: linux-mm@kvack.org
Delivered-To: linux-mm@kvack.org
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 99D676B0044
	for <linux-mm@kvack.org>; Fri, 30 Mar 2012 16:04:57 -0400 (EDT)
Received: from metis.ext.pengutronix.de ([92.198.50.35]) (using TLSv1) by na3sys010amx137.postini.com ([74.125.244.10]) with SMTP;
	Fri, 30 Mar 2012 15:04:57 CDT
Received: from dude.hi.pengutronix.de ([2001:6f8:1178:2:21e:67ff:fe11:9c5c])
	by metis.ext.pengutronix.de with esmtp (Exim 4.72)
	(envelope-from <ukl@pengutronix.de>)
	id 1SDi3Z-0002ah-Lz; Fri, 30 Mar 2012 22:04:21 +0200
Received: from ukl by dude.hi.pengutronix.de with local (Exim 4.77)
	(envelope-from <ukl@pengutronix.de>)
	id 1SDi3C-0003aa-3i; Fri, 30 Mar 2012 22:03:58 +0200
Date: Fri, 30 Mar 2012 22:03:58 +0200
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Anatolij Gustschin <agust@denx.de>,
	Andreas Koensgen <ajk@comnets.uni-bremen.de>,
	Andrew Lunn <andrew@lunn.ch>, Andrew Victor <linux@maxim.org.za>,
	Arnd Bergmann <arnd@arndb.de>, Barry Song <baohua.song@csr.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Bryan Huntsman <bryanh@codeaurora.org>,
	cbe-oss-dev@lists.ozlabs.org,
	Christoph Lameter <cl@linux-foundation.org>,
	Daniel Walker <dwalker@fifo99.com>,
	David Brown <davidb@codeaurora.org>,
	David Howells <dhowells@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	David Woodhouse <dwmw2@infradead.org>,
	davinci-linux-open-source@linux.davincidsp.com,
	Eric Miao <eric.y.miao@gmail.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Guenter Roeck <guenter.roeck@ericsson.com>,
	Haojian Zhuang <haojian.zhuang@gmail.com>,
	Henrique de Moraes Holschuh <ibm-acpi@hmh.eng.br>,
	ibm-acpi-devel@lists.sourceforge.net,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Jean Delvare <khali@linux-fr.org>,
	Jean-Paul Roubelat <jpr@f6fbb.org>, Joerg Reuter <jreuter@yaina.de>,
	Josh Boyer <jwboyer@gmail.com>, Kevin Hilman <khilman@ti.com>,
	Klaus Kudielka <klaus.kudielka@ieee.org>,
	Kukjin Kim <kgene.kim@samsung.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Linus Walleij <linus.walleij@stericsson.com>,
	linux-arm-kernel@lists.infradead.org, linux-arm-msm@vger.kernel.org,
	linux-hams@vger.kernel.org, linux-ia64@vger.kernel.org,
	linux-ide@vger.kernel.org, linux-media@vger.kernel.org,
	linux-mips@linux-mips.org, linux-mm@kvack.org,
	linux-mtd@lists.infradead.org, linux-omap@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-samsung-soc@vger.kernel.org,
	lm-sensors@lm-sensors.org,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	Matt Porter <mporter@kernel.crashing.org>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	netdev@vger.kernel.org, Nicolas Ferre <nicolas.ferre@atmel.com>,
	Nicolas Pitre <nico@fluxnic.net>, Paul Mackerras <paulus@samba.org>,
	platform-driver-x86@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Russell King <linux@arm.linux.org.uk>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Sascha Hauer <kernel@pengutronix.de>, Sekhar Nori <nsekhar@ti.com>,
	Shawn Guo <shawn.guo@linaro.org>, Tejun Heo <tj@kernel.org>,
	Tomasz Stanislawski <t.stanislaws@samsung.com>,
	Tony Lindgren <tony@atomide.com>, Tony Luck <tony.luck@intel.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>
Subject: [PATCH v2 00/15] mark const init data with __initconst instead of
 __initdata
Message-ID: <20120330200358.GV15647@pengutronix.de>
References: <20120329211131.GA31250@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20120329211131.GA31250@pengutronix.de>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-SA-Exim-Connect-IP: 2001:6f8:1178:2:21e:67ff:fe11:9c5c
X-SA-Exim-Mail-From: ukl@pengutronix.de
X-SA-Exim-Scanned: No (on metis.ext.pengutronix.de); SAEximRunCond expanded to false
X-PTX-Original-Recipient: linux-mm@kvack.org
X-pstn-neptune: 0/0/0.00/0
X-pstn-levels:     (S:99.90000/99.90000 CV:99.9000 FC:95.5390 LC:95.5390 R:95.9108 P:95.9108 M:97.0282 C:98.6951 )
X-pstn-dkim: 0 skipped:not-enabled
X-pstn-settings: 3 (1.0000:1.0000) s cv gt3 gt2 gt1 r p m c 
X-pstn-addresses: from <u.kleine-koenig@pengutronix.de> [db-null] 
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.2

Hello,

On Thu, Mar 29, 2012 at 11:11:31PM +0200, Uwe Kleine-Ki? 1/2 nig wrote:
> this series fixes a common error to use __initdata to mark const
> variables. Most of the time this works well enough to go unnoticed
> (though I wonder why the linker doesn't warn about that).
> Just try adding something like
> 
> 	int something __initdata;
> 
> to one of the patched files and compile to see the error.
> 
> While touching these annotations I also corrected the position where it
> was wrong to go between the variable name and the =.
> 
> Note this series is not compile tested.
I now dropped the wrong annotations. So two patches became obsolete
(mtd and percpu). Note that I also dropped fixing the position of
__initdata if changing it to __initconst was wrong. (I think if
__initdata is placed before the variable name it doesn't have any
effect.)

I didn't promote the Acks I got because all acked changes changed in v2.

For the details changed in each patch see the changelogs in the
respective patch mails that I follow up to this mail.

Thanks
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-Ki? 1/2 nig            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
