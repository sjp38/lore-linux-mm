Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 993B36B0083
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 14:24:39 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so4966069qcs.14
        for <linux-mm@kvack.org>; Tue, 17 Apr 2012 11:24:38 -0700 (PDT)
Message-ID: <4F8DB564.2060205@gmail.com>
Date: Tue, 17 Apr 2012 14:24:36 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [NEW]: Introducing shrink_all_memory from user space
References: <1334483226.20721.YahooMailNeo@web162003.mail.bf1.yahoo.com>
In-Reply-To: <1334483226.20721.YahooMailNeo@web162003.mail.bf1.yahoo.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "pintu.k@samsung.com" <pintu.k@samsung.com>, kosaki.motohiro@gmail.com

(4/15/12 5:47 AM), PINTU KUMAR wrote:
> Dear All,
>
> This is regarding a small proposal for shrink_all_memory( ) function which is found in mm/vmscan.c.
> For those who are not aware, this function helps in reclaiming specified amount of physical memory and returns number of freed pages.
>
> Currently this function is under CONFIG_HIBERNATION flag, so cannot be used by others without enabling hibernation.
> Moreover this function is not exported to the outside world, so no driver can use it directly without including EXPORT_SYMBOL(shrink_all_memory) and recompiling the kernel.
> The purpose of using it under hibernation(kernel/power/snapshot.c) is to regain enough physical pages to create hibernation image.

This is intended. current shrink_all_memory() is not designed for generic purpose. It doesn't care numa affinity etc..
In future, we may remove this function completely because actually hibernation don't depend on it. it only help to
improvement hibernation speed-up a bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
