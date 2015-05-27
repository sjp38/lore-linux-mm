Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id ACC576B00F8
	for <linux-mm@kvack.org>; Wed, 27 May 2015 09:32:44 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so15394412pdb.1
        for <linux-mm@kvack.org>; Wed, 27 May 2015 06:32:44 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id c7si25977955pdn.193.2015.05.27.06.32.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 May 2015 06:32:43 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NP0009PCGAF1E20@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 27 May 2015 14:32:39 +0100 (BST)
Message-id: <5565C768.6030906@samsung.com>
Date: Wed, 27 May 2015 15:32:24 +0200
From: Beata Michalska <b.michalska@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC v2 1/4] fs: Add generic file system event notifications
References: <20150428135653.GD9955@quack.suse.cz>
 <20150428140936.GA13406@kroah.com> <553F9D56.6030301@samsung.com>
 <20150428173900.GA16708@kroah.com> <5540822C.10000@samsung.com>
 <20150429074259.GA31089@quack.suse.cz> <20150429091303.GA4090@kroah.com>
 <5548B4BB.7050503@samsung.com> <554B5329.8040907@samsung.com>
 <5564A1D4.4040309@samsung.com> <20150527023412.GA20070@kroah.com>
In-reply-to: <20150527023412.GA20070@kroah.com>
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

On 05/27/2015 04:34 AM, Greg KH wrote:
> On Tue, May 26, 2015 at 06:39:48PM +0200, Beata Michalska wrote:
>> Hi,
>>
>> Things has gone a bit quiet thread wise ...
>> As I believe I've managed to snap back to reality, I was hoping we could continue with this?
>> I'm not sure if we've got everything cleared up or ... have we reached a dead end?
>> Please let me know if we can move to the next stage? Or, if there are any showstoppers?
> 
> Please resend if you think it's ready and you have addressed the issues
> raised so far.
> 
> thanks,
> 
> greg k-h
> 

Alright.
I'm still running some tests so I'll resend it most probably tomorrow
or on Friday.

Best Regards
Beata

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
