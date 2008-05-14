Date: Wed, 14 May 2008 09:52:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: memory_hotplug: always initialize pageblock bitmap.
Message-Id: <20080514095256.741fe70a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080513185242.GA6465@osiris.boeblingen.de.ibm.com>
References: <20080509060609.GB9840@osiris.boeblingen.de.ibm.com>
	<20080509153910.6b074a30.kamezawa.hiroyu@jp.fujitsu.com>
	<20080510124501.GA4796@osiris.boeblingen.de.ibm.com>
	<20080512105500.ff89c0d3.kamezawa.hiroyu@jp.fujitsu.com>
	<20080512181928.cd41c055.kamezawa.hiroyu@jp.fujitsu.com>
	<20080513115825.GB12339@osiris.boeblingen.de.ibm.com>
	<20080513185242.GA6465@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 May 2008 20:52:42 +0200
Heiko Carstens <heiko.carstens@de.ibm.com> wrote:
> Oops... the patch is tested and works for me. However it was not Signed-off
> by Andrew. And in addition I forgot to add [PATCH] to the subject.
> Sorry about that!
> 
> If all agree that this patch is ok it should probably also go into
> -stable, since it fixes the above mentioned regression.
> 
Thank you very much! The patch seems ok to me.
(But I cannot test this until my box is available...)

If other memory-hotplug guys say ok, I have no objection to -stable.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
