Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B6B3F6B007B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 12:00:17 -0500 (EST)
Message-ID: <4B797D93.5090307@redhat.com>
Date: Mon, 15 Feb 2010 12:00:03 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: tracking memory usage/leak in "inactive" field in /proc/meminfo?
References: <4B71927D.6030607@nortel.com>	 <20100210093140.12D9.A69D9226@jp.fujitsu.com>	 <4B72E74C.9040001@nortel.com>	 <28c262361002101645g3fd08cc7t6a72d27b1f94db62@mail.gmail.com>	 <4B74524D.8080804@nortel.com> <28c262361002111838q7db763feh851a9bea4fdd9096@mail.gmail.com> <4B7504D2.1040903@nortel.com> <4B796D31.7030006@nortel.com>
In-Reply-To: <4B796D31.7030006@nortel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Friesen <cfriesen@nortel.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 02/15/2010 10:50 AM, Chris Friesen wrote:

> Looking at the code, it looks like page_remove_rmap() clears the
> Anonpage flag and removes it from NR_ANON_PAGES, and the caller is
> responsible for removing it from the LRU.  Is that right?

Nope.

> I'll keep digging in the code, but does anyone know where the removal
> from the LRU is supposed to happen in the above code paths?

Removal from the LRU is done from the page freeing code, on
the final free of the page.

It appears you have code somewhere that increments the reference
count on user pages and then forgets to lower it afterwards.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
