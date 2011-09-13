Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 63ECD900137
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 02:07:15 -0400 (EDT)
Message-ID: <4E6EF310.7060603@profihost.ag>
Date: Tue, 13 Sep 2011 08:07:12 +0200
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
MIME-Version: 1.0
Subject: Re: system freezing with 3.0.4
References: <4E69A496.9040707@profihost.ag> <20110912201606.GA24927@infradead.org>
In-Reply-To: <20110912201606.GA24927@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux-scsi@vger.kernel.org

Hi,

> On Fri, Sep 09, 2011 at 07:31:02AM +0200, Stefan Priebe - Profihost AG wrote:
>> Hi list,
>>
>> here's an updated post of my one yesterday.
>>
>> We've updated some systems from 2.6.32 to 3.0.4 vanilla kernel.
>> Since then we're expecting freezes every now and then. All in memory
>> apps are still working but nothing which reads or writes from or to
>> disk (at least it seems like that).
>
> What storage driver(s) do you use?

aacraid - but i'm also seeing this on other systems.

Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
