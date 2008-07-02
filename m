Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id m62JJPcQ031723
	for <linux-mm@kvack.org>; Wed, 2 Jul 2008 20:19:25 +0100
Received: from an-out-0708.google.com (andd33.prod.google.com [10.100.30.33])
	by spaceape23.eur.corp.google.com with ESMTP id m62JIdFN021832
	for <linux-mm@kvack.org>; Wed, 2 Jul 2008 20:19:25 +0100
Received: by an-out-0708.google.com with SMTP id d33so93000and.19
        for <linux-mm@kvack.org>; Wed, 02 Jul 2008 12:19:24 -0700 (PDT)
Message-ID: <6599ad830807021219u1cc48e9fx4ebbcab7961a7408@mail.gmail.com>
Date: Wed, 2 Jul 2008 12:19:24 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm] [6/7] res_counter distance to limit
In-Reply-To: <20080702211510.6f1fe470.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080702211510.6f1fe470.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 2, 2008 at 5:15 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> I wonder wheher there is better name rather than "distance"...
> give me a hint ;)

How about res_counter_report_spare() and res_counter_charge_and_report_spare() ?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
