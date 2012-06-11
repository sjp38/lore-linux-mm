Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 3BBAC6B0136
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 10:31:56 -0400 (EDT)
Message-ID: <4FD60127.1000805@jp.fujitsu.com>
Date: Mon, 11 Jun 2012 10:31:03 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix protection column misplacing in /proc/zoneinfo
References: <1339422650-9798-1-git-send-email-kosaki.motohiro@gmail.com> <alpine.DEB.2.00.1206110856180.31180@router.home>
In-Reply-To: <alpine.DEB.2.00.1206110856180.31180@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com
Cc: kosaki.motohiro@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com

On 6/11/2012 10:02 AM, Christoph Lameter wrote:
> On Mon, 11 Jun 2012, kosaki.motohiro@gmail.com wrote:
> 
>> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>
>> commit 2244b95a7b (zoned vm counters: basic ZVC (zoned vm counter)
>> implementation) broke protection column. It is a part of "pages"
>> attribute. but not it is showed after vmstats column.
>>
>> This patch restores the right position.
> 
> Well this reorders the output. vmstats are also counts of pages. I am not
> sure what the difference is.

No. In this case, "pages" mean zone attribute. In the other hand, vmevent
is a statistics.


> You are not worried about breaking something that may scan the zoneinfo
> output with this change? Its been this way for 6 years and its likely that
> tools expect the current layout.

I don't worry about this. Because of, /proc/zoneinfo is cray machine unfrinedly
format and afaik no application uses it.

btw, I believe we should aim /sys/devices/system/node/<node-num>/zones new directory
and export zone infos as machine readable format.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
