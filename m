Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 3DF936B0062
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 11:24:28 -0500 (EST)
Message-ID: <4EEF6532.3090201@redhat.com>
Date: Mon, 19 Dec 2011 11:24:18 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Android low memory killer vs. memory pressure notifications
References: <20111219025328.GA26249@oksana.dev.rtsoft.ru> <20111219103954.354d68af@pyramind.ukuu.org.uk> <4EEF6360.4000306@gmail.com>
In-Reply-To: <4EEF6360.4000306@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Anton Vorontsov <anton.vorontsov@linaro.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, =?UTF-8?B?QXJ2ZSBIasO4?= =?UTF-8?B?bm5ldsOlZw==?= <arve@android.com>, Pavel Machek <pavel@ucw.cz>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/19/2011 11:16 AM, KOSAKI Motohiro wrote:
> (12/19/11 5:39 AM), Alan Cox wrote:
>>> The main downside of this approach is that mem_cg needs 20 bytes per
>>> page (on a 32 bit machine). So on a 32 bit machine with 4K pages
>>> that's approx. 0.5% of RAM, or, in other words, 5MB on a 1GB machine.
>>
>> The obvious question would be why? Would fixing memcg make more sense ?
>
> Just historical reason. Initial memcg implement by IBM was just crap.

And the reason for that, I suspect, is that the "proper"
implementation changes the VM by so much that it would
never have been merged in the first place...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
