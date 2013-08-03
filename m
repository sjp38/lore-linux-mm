Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id A2F756B0031
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 16:17:06 -0400 (EDT)
Message-ID: <51FD653A.3060004@jp.fujitsu.com>
Date: Sat, 03 Aug 2013 16:16:58 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH resend] drop_caches: add some documentation and info message
References: <1374842669-22844-1-git-send-email-mhocko@suse.cz> <20130729135743.c04224fb5d8e64b2730d8263@linux-foundation.org> <51F9D1F6.4080001@jp.fujitsu.com> <20130731201708.efa5ae87.akpm@linux-foundation.org> <CAHGf_=r7mek+ueJWfu_6giMOueDTnMs8dY1jJrKyX+gfPys6uA@mail.gmail.com> <20130802073304.GA17746@dhcp22.suse.cz>
In-Reply-To: <20130802073304.GA17746@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, kamezawa.hiroyu@jp.fujitsu.com, bp@suse.de, dave@linux.vnet.ibm.com

>>> You missed the "!".  I'm proposing that setting the new bit 2 will
>>> permit people to prevent the new printk if it is causing them problems.
>>
>> No I don't. I'm sure almost all abuse users think our usage is correct. Then,
>> I can imagine all crazy applications start to use this flag eventually.
> 
> I guess we do not care about those. If somebody wants to shoot his feet
> then we cannot do much about it. The primary motivation was to find out
> those that think this is right and they are willing to change the setup
> once they know this is not the right way to do things.
> 
> I think that giving a way to suppress the warning is a good step. Log
> level might be to coarse and sysctl would be an overkill.

When Dave Hansen reported this issue originally, he explained a lot of userland
developer misuse /proc/drop_caches because they don't understand what
drop_caches do.
So, if they never understand the fact, why can we trust them? I have no
idea.
Or, if you have different motivation w/ Dave, please let me know it.

While the purpose is to shoot misuse, I don't think we can trust userland app.
If "If somebody wants to shoot his feet then we cannot do much about it." is true,
this patch is useless. OK, we still catch the right user. But we never want to know
who is the right users, right?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
