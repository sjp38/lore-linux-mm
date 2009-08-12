Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5C7C06B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 03:43:54 -0400 (EDT)
Message-ID: <4A8272B2.3030309@redhat.com>
Date: Wed, 12 Aug 2009 10:43:46 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Page allocation failures in guest
References: <20090713115158.0a4892b0@mjolnir.ossman.eu>	<20090811083233.3b2be444@mjolnir.ossman.eu>	<4A811545.5090209@redhat.com>	<200908121249.51973.rusty@rustcorp.com.au> <20090812081934.33e8280f@mjolnir.ossman.eu>
In-Reply-To: <20090812081934.33e8280f@mjolnir.ossman.eu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus-list@drzeus.cx>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Minchan Kim <minchan.kim@gmail.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On 08/12/2009 09:19 AM, Pierre Ossman wrote:
> Will it still trigger the OOM killer with this patch, or will things
> behave slightly more gracefully?
>    

I don't think you mentioned the OOM killer in your original report?  Did 
it trigger?


-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
