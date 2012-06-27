Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 3AF276B005A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 22:09:36 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1SjhhE-0001KM-7B
	for linux-mm@kvack.org; Wed, 27 Jun 2012 04:09:32 +0200
Received: from 121.50.20.41 ([121.50.20.41])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 04:09:32 +0200
Received: from minchan by 121.50.20.41 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 04:09:32 +0200
From: Minchan Kim <minchan@kernel.org>
Subject: Re: needed lru_add_drain_all() change
Date: Wed, 27 Jun 2012 11:09:31 +0900
Message-ID: <4FEA6B5B.5000205@kernel.org>
References: <20120626143703.396d6d66.akpm@linux-foundation.org> <4FEA59EE.8060804@kernel.org> <20120626181504.23b8b73d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
In-Reply-To: <20120626181504.23b8b73d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>

On 06/27/2012 10:15 AM, Andrew Morton wrote:

>> Considering mlock and CPU pinning
>> > of realtime thread is very rare, it might be rather expensive solution.
>> > Unfortunately, I have no idea better than you suggested. :(
>> > 
>> > And looking 8891d6da17, mlock's lru_add_drain_all isn't must.
>> > If it's really bother us, couldn't we remove it?
> "grep lru_add_drain_all mm/*.c".  They're all problematic.


Yeb but I'm not sure such system modeling is good.
Potentially, It could make problem once we use workqueue of other CPU.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
