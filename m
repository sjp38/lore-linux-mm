Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id BCB776B004A
	for <linux-mm@kvack.org>; Fri, 30 Mar 2012 06:00:01 -0400 (EDT)
Date: Fri, 30 Mar 2012 11:59:00 +0200
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 00/17] mark const init data with __initconst instead of
 __initdata
Message-ID: <20120330095859.GT15647@pengutronix.de>
References: <20120329211131.GA31250@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20120329211131.GA31250@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, Anatolij Gustschin <agust@denx.de>, Andreas Koensgen <ajk@comnets.uni-bremen.de>, Andrew Lunn <andrew@lunn.ch>, Andrew Victor <linux@maxim.org.za>, Arnd Bergmann <arnd@arndb.de>, Barry Song <baohua.song@csr.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Bryan Huntsman <bryanh@codeaurora.org>, cbe-oss-dev@lists.ozlabs.org, Christoph Lameter <cl@linux-foundation.org>, Daniel Walker <dwalker@fifo99.com>, David Brown <davidb@codeaurora.org>, David Howells <dhowells@redhat.com>, "David S. Miller" <davem@davemloft.net>, David Woodhouse <dwmw2@infradead.org>, davinci-linux-open-source@linux.davincidsp.com, Eric Miao <eric.y.miao@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>, Grant Likely <grant.likely@secretlab.ca>, Guenter Roeck <guenter.roeck@ericsson.com>, Haojian Zhuang <haojian.zhuang@gmail.com>, Henrique de Moraes Holschuh <ibm-acpi@hmh.eng.br>, ibm-acpi-devel@lists.sourceforge.net, Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>, Jean Delvare <khali@linux-fr.org>, Jean-Paul Roubelat <jpr@f6fbb.org>, Joerg Reuter <jreuter@yaina.de>, Josh Boyer <jwboyer@gmail.com>, Kevin Hilman <khilman@ti.com>, Klaus Kudielka <klaus.kudielka@ieee.org>, Kukjin Kim <kgene.kim@samsung.com>, Kumar Gala <galak@kernel.crashing.org>, Kyungmin Park <kyungmin.park@samsung.com>, Lennert Buytenhek <kernel@wantstofly.org>, Linus Walleij <linus.walleij@linaro.org>, Linus Walleij <linus.walleij@stericsson.com>, linux-arm-kernel@lists.infradead.org, linux-arm-msm@vger.kernel.org, linux-hams@vger.kernel.org, linux-ia64@vger.kernel.org, linux-ide@vger.kernel.org, linux-media@vger.kernel.org, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-omap@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-samsung-soc@vger.kernel.org, lm-sensors@lm-sensors.org, Lucas De Marchi <lucas.demarchi@profusion.mobi>, Matthew Garrett <mjg59@srcf.ucam.org>, Matt Porter <mporter@kernel.crashing.org>, Mauro Carvalho Chehab <mchehab@infradead.org>, netdev@vger.kernel.org, Nicolas Ferre <nicolas.ferre@atmel.com>, Nicolas Pitre <nico@fluxnic.net>, Paul Mackerras <paulus@samba.org>, platform-driver-x86@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, Randy Dunlap <rdunlap@xenotime.net>, Russell King <linux@arm.linux.org.uk>, Samuel Ortiz <sameo@linux.intel.com>, Sascha Hauer <kernel@pengutronix.de>, Sekhar Nori <nsekhar@ti.com>, Shawn Guo <shawn.guo@linaro.org>, Tejun Heo <tj@kernel.org>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Tony Lindgren <tony@atomide.com>, Tony Luck <tony.luck@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>

On Thu, Mar 29, 2012 at 11:11:31PM +0200, Uwe Kleine-Ki? 1/2 nig wrote:
> Hello,
> 
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
After a question by Shawn Guo I noticed that my command to do the changes
was to lax and changed things that must not be changed (at least not
with further care). Affected are lines like:

	static const char *at91_dt_board_compat[] __initconst = {

While at91_dt_board_compat[0] is const, at91_dt_board_compat is not.

I will send a fixed series later today.

Best regards
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
