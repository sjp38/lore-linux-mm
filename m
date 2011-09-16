Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 438609000BD
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 13:52:59 -0400 (EDT)
Received: by vws7 with SMTP id 7so5060360vws.35
        for <linux-mm@kvack.org>; Fri, 16 Sep 2011 10:52:57 -0700 (PDT)
Message-ID: <4E738CF6.4020808@vflare.org>
Date: Fri, 16 Sep 2011 13:52:54 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com> <20110909203447.GB19127@kroah.com> <4E6ACE5B.9040401@vflare.org> <4E6E18C6.8080900@linux.vnet.ibm.com> <4E6EB802.4070109@vflare.org> <4E6F7DA7.9000706@linux.vnet.ibm.com> <4E6FC8A1.8070902@vflare.org 4E72284B.2040907@linux.vnet.ibm.com> <075c4e4c-a22d-47d1-ae98-31839df6e722@default> <4E725109.3010609@linux.vnet.ibm.com>
In-Reply-To: <4E725109.3010609@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Greg KH <greg@kroah.com>, gregkh@suse.de, devel@driverdev.osuosl.org, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, dave@linux.vnet.ibm.com, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

On 09/15/2011 03:24 PM, Seth Jennings wrote:

> On 09/15/2011 12:29 PM, Dan Magenheimer wrote:
>>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>>> Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
>>>


>>
>> Seth, I am still not clear why it is not possible to support
>> either allocation algorithm, selectable at runtime.  Or even
>> dynamically... use xvmalloc to store well-compressible pages
>> and xcfmalloc for poorly-compressible pages.  I understand
>> it might require some additional coding, perhaps even an
>> ugly hack or two, but it seems possible.
> 
> But why do an ugly hack if we can just use a single allocator
> that has the best overall performance for the allocation range
> the zcache requires.  Why make it more complicated that it
> needs to be?
> 
>>


I agree with Seth here: a mix of different allocators for the (small)
range of sizes which zcache requires, looks like a bad idea to me.
Maintaining two allocators is a pain and this will also complicate
future plans like compaction etc.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
