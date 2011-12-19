Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 3F46A6B005D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 05:39:19 -0500 (EST)
Date: Mon, 19 Dec 2011 10:39:54 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Android low memory killer vs. memory pressure notifications
Message-ID: <20111219103954.354d68af@pyramind.ukuu.org.uk>
In-Reply-To: <20111219025328.GA26249@oksana.dev.rtsoft.ru>
References: <20111219025328.GA26249@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Arve =?ISO-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Rik van Riel <riel@redhat.com>, Pavel Machek <pavel@ucw.cz>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>   The main downside of this approach is that mem_cg needs 20 bytes per
>   page (on a 32 bit machine). So on a 32 bit machine with 4K pages
>   that's approx. 0.5% of RAM, or, in other words, 5MB on a 1GB machine.

The obvious question would be why? Would fixing memcg make more sense ?

The only problem I see with having a user space manager is that manager
probably has to be mlock to avoid awkward fail cases and that may in fact
make it smaller kernel side.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
