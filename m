Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 53E576B00A2
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 12:26:46 -0400 (EDT)
Message-ID: <4AC04800.70708@crca.org.au>
Date: Mon, 28 Sep 2009 15:22:08 +1000
From: Nigel Cunningham <ncunningham@crca.org.au>
MIME-Version: 1.0
Subject: Re: No more bits in vm_area_struct's vm_flags.
References: <4AB9A0D6.1090004@crca.org.au>	<20090924100518.78df6b93.kamezawa.hiroyu@jp.fujitsu.com>	<4ABC80B0.5010100@crca.org.au>	<20090925174009.79778649.kamezawa.hiroyu@jp.fujitsu.com>	<4AC0234F.2080808@crca.org.au>	<20090928120450.c2d8a4e2.kamezawa.hiroyu@jp.fujitsu.com>	<20090928033624.GA11191@localhost>	<20090928125705.6656e8c5.kamezawa.hiroyu@jp.fujitsu.com>	<4AC03D9C.3020907@crca.org.au> <20090928135315.083aca18.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090928135315.083aca18.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi.

KAMEZAWA Hiroyuki wrote:
> Seems good to me.
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> But
>> +	if (vma->vm_hints)
>> +		return 0;
>>  	return 1;
> 
> Maybe adding a comment (or more detailed patch description) is necessary.

Thinking about this some more, I think we should also be looking at whether the new hints are non zero. Perhaps I should just add the new value to the
function parameters and be done with it.

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
