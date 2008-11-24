Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id mAOHcFu7013362
	for <linux-mm@kvack.org>; Mon, 24 Nov 2008 09:38:15 -0800
Received: from an-out-0708.google.com (anac3.prod.google.com [10.100.54.3])
	by zps35.corp.google.com with ESMTP id mAOHc6ER006896
	for <linux-mm@kvack.org>; Mon, 24 Nov 2008 09:38:14 -0800
Received: by an-out-0708.google.com with SMTP id c3so781316ana.44
        for <linux-mm@kvack.org>; Mon, 24 Nov 2008 09:38:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.0811220152300.18236@chino.kir.corp.google.com>
References: <604427e00811211605j20fd00bby1bac86b4cc3c380b@mail.gmail.com>
	 <alpine.DEB.2.00.0811211618160.20523@chino.kir.corp.google.com>
	 <6599ad830811211818g5ade68cua396713be94f80dc@mail.gmail.com>
	 <alpine.DEB.2.00.0811220152300.18236@chino.kir.corp.google.com>
Date: Mon, 24 Nov 2008 09:38:13 -0800
Message-ID: <604427e00811240938n5eca39cetb37b4a63f20a0854@mail.gmail.com>
Subject: Re: [PATCH][V2] Make get_user_pages interruptible
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Paul Menage <menage@google.com>, linux-mm@kvack.org, akpm <akpm@linux-foundation.org>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

--Ying

On Sat, Nov 22, 2008 at 12:07 PM, David Rientjes <rientjes@google.com> wrote:
> On Fri, 21 Nov 2008, Paul Menage wrote:
>
>> No, I didn't exactly write it originally - the only thing I added in
>> our kernel was the use of sigkill_pending() rather than checking for
>> TIF_MEMDIE.
>>
>
> That's what this patch does, its title just appears to be wrong since it
> was already interruptible.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
