Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id C5F8A6B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 10:26:54 -0400 (EDT)
Date: Thu, 26 Apr 2012 15:26:43 +0100
From: Richard Davies <richard.davies@elastichosts.com>
Subject: Re: [RFC][PATCH] avoid swapping out with swappiness==0
Message-ID: <20120426142643.GA18863@alpha.arachsys.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB951A45F@USINDEVS02.corp.hds.com>
 <20120424082019.GA18395@alpha.arachsys.com>
 <65795E11DBF1E645A09CEC7EAEE94B9C014649EC4D@USINDEVS02.corp.hds.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9C014649EC4D@USINDEVS02.corp.hds.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "riel@redhat.com" <riel@redhat.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "shaohua.li@intel.com" <shaohua.li@intel.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>, Minchan Kim <minchan.kim@gmail.com>

Satoru Moriya wrote:
> > I have run into problems with heavy swapping with swappiness==0 and 
> > was pointed to this thread ( 
> > http://marc.info/?l=linux-mm&m=133522782307215 )
> 
> Did you test this patch with your workload?

I haven't yet tested this patch. It takes a long time since these are
production machines, and the bug itself takes several weeks of production
use to really show up.

Rik van Riel has pointed out a lot of VM tweaks that he put into 3.4:
http://marc.info/?l=linux-mm&m=133536506926326

My intention is to reboot half of our machines into plain 3.4 once it is
out, and half onto 3.4 + your patch.

Then we can compare behaviour.


Will your patch apply cleanly on 3.4?

Richard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
