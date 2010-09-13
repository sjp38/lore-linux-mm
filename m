Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B7E246B0047
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 15:09:56 -0400 (EDT)
Received: by qwf7 with SMTP id 7so4876323qwf.14
        for <linux-mm@kvack.org>; Mon, 13 Sep 2010 12:09:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100913152138.GA16334@sig21.net>
References: <20100907133429.GB3430@sig21.net> <20100909120044.GA27765@sig21.net>
 <20100910120235.455962c4@schatten.dmk.lab> <20100910160247.GA637@sig21.net> <20100913152138.GA16334@sig21.net>
From: dave b <db.pub.mail@gmail.com>
Date: Tue, 14 Sep 2010 05:09:31 +1000
Message-ID: <AANLkTikoUAgRV18axesaiYnpBWe2V-xhALgh7dtF7p3Y@mail.gmail.com>
Subject: Re: block cache replacement strategy?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Johannes Stezenbach <js@sig21.net>
Cc: Florian Mickler <florian@mickler.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 14 September 2010 01:21, Johannes Stezenbach <js@sig21.net> wrote:
> On Fri, Sep 10, 2010 at 06:02:48PM +0200, Johannes Stezenbach wrote:
>>
>> Linear read heuristic might be a good guess, but it would
>> be nice to hear a comment from a vm/fs expert which
>> confirms this works as intended.
>
> Apparently I'm unworthy to get a response from someone knowledgable :-(
>
> Anyway I found lmdd (from lmbench) can do random reads,
> and indeed causes the data to enter the block (page?) cache,
> replacing the previous data.


I am no expert, but what did you think would happen if you did dd
twice from /dev/zero?
but... Honestly what do you think will be cached?
If you want 'COW', use btrfs.

--
Conscience doth make cowards of us all.		-- Shakespeare

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
