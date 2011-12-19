Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id DC9A86B0062
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 11:16:30 -0500 (EST)
Received: by yenq10 with SMTP id q10so4244697yen.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 08:16:30 -0800 (PST)
Message-ID: <4EEF6360.4000306@gmail.com>
Date: Mon, 19 Dec 2011 11:16:32 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: Android low memory killer vs. memory pressure notifications
References: <20111219025328.GA26249@oksana.dev.rtsoft.ru> <20111219103954.354d68af@pyramind.ukuu.org.uk>
In-Reply-To: <20111219103954.354d68af@pyramind.ukuu.org.uk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, =?ISO-8859-1?Q?Arve_Hj=F8nnev=E5g?= <arve@android.com>, Rik van Riel <riel@redhat.com>, Pavel Machek <pavel@ucw.cz>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(12/19/11 5:39 AM), Alan Cox wrote:
>>    The main downside of this approach is that mem_cg needs 20 bytes per
>>    page (on a 32 bit machine). So on a 32 bit machine with 4K pages
>>    that's approx. 0.5% of RAM, or, in other words, 5MB on a 1GB machine.
>
> The obvious question would be why? Would fixing memcg make more sense ?

Just historical reason. Initial memcg implement by IBM was just crap. 
People need very long time to fix it.


> The only problem I see with having a user space manager is that manager
> probably has to be mlock to avoid awkward fail cases and that may in fact
> make it smaller kernel side.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
