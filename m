Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 980CB6B0011
	for <linux-mm@kvack.org>; Tue,  3 May 2011 23:55:48 -0400 (EDT)
Received: by wyf19 with SMTP id 19so727879wyf.14
        for <linux-mm@kvack.org>; Tue, 03 May 2011 20:55:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110503082550.GD18927@tiehlicka.suse.cz>
References: <20110425182849.ab708f12.kamezawa.hiroyu@jp.fujitsu.com>
 <20110429133313.GB306@tiehlicka.suse.cz> <20110501150410.75D2.A69D9226@jp.fujitsu.com>
 <20110503064945.GA18927@tiehlicka.suse.cz> <BANLkTimmpHcSJuO_8+P=GjYf+wB=Nyq=4w@mail.gmail.com>
 <20110503082550.GD18927@tiehlicka.suse.cz>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 4 May 2011 12:55:19 +0900
Message-ID: <BANLkTi=ZNWG97XgTGoK6moHds4MTQHXAHg@mail.gmail.com>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

>> Ah, right. So, do you have an alternative idea?
>
> Why cannot we just keep the global reclaim semantic and make it free
> memory (hard_limit - usage_in_bytes) based with low limit as the trigger
> for reclaiming?

Because it's not free memory. the cgroup doesn't reach a limit. but....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
