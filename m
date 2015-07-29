Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5CBF19003C7
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 12:03:19 -0400 (EDT)
Received: by ykba194 with SMTP id a194so11656283ykb.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 09:03:19 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id 202si18977531ykw.64.2015.07.29.09.03.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 09:03:18 -0700 (PDT)
Message-ID: <55B8F92B.2060900@citrix.com>
Date: Wed, 29 Jul 2015 17:02:51 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 06/10] xen/balloon: only hotplug additional memory if
 required
References: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
 <1437738468-24110-7-git-send-email-david.vrabel@citrix.com>
 <20150729155535.GL3492@olila.local.net-space.pl>
In-Reply-To: <20150729155535.GL3492@olila.local.net-space.pl>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <daniel.kiper@oracle.com>
Cc: xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 29/07/15 16:55, Daniel Kiper wrote:
> On Fri, Jul 24, 2015 at 12:47:44PM +0100, David Vrabel wrote:
>> --- a/drivers/xen/balloon.c
>> +++ b/drivers/xen/balloon.c
>> @@ -75,12 +75,14 @@
>>   * balloon_process() state:
>>   *
>>   * BP_DONE: done or nothing to do,
>> + * BP_WAIT: wait to be rescheduled,
> 
> BP_SLEEP? BP_WAIT suggests that balloon process waits for something in a loop.

Waiting in a loop is what wait_event() does.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
