Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8FE156B0246
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 21:02:38 -0400 (EDT)
Received: by pvc30 with SMTP id 30so656994pvc.14
        for <linux-mm@kvack.org>; Tue, 06 Jul 2010 18:02:35 -0700 (PDT)
Message-ID: <4C33D240.80102@vflare.org>
Date: Wed, 07 Jul 2010 06:32:56 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH V3 3/8] Cleancache: core ops functions and configuration
References: <20100621231939.GA19505@ca-server1.us.oracle.com> <1277223988.9782.20.camel@nimitz> <20100706205121.GA32627@phenom.dumpdata.com>
In-Reply-To: <20100706205121.GA32627@phenom.dumpdata.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Dave Hansen <dave@sr71.net>, Dan Magenheimer <dan.magenheimer@oracle.com>, chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@Sun.COM, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com
List-ID: <linux-mm.kvack.org>

On 07/07/2010 02:21 AM, Konrad Rzeszutek Wilk wrote:
> On Tue, Jun 22, 2010 at 09:26:28AM -0700, Dave Hansen wrote:
>> On Mon, 2010-06-21 at 16:19 -0700, Dan Magenheimer wrote:
>>> --- linux-2.6.35-rc2/include/linux/cleancache.h 1969-12-31 17:00:00.000000000 -0700
>>> +++ linux-2.6.35-rc2-cleancache/include/linux/cleancache.h      2010-06-21 14:45:18.000000000 -0600
>>> @@ -0,0 +1,88 @@
>>> +#ifndef _LINUX_CLEANCACHE_H
>>> +#define _LINUX_CLEANCACHE_H
>>> +
>>> +#include <linux/fs.h>
>>> +#include <linux/mm.h>
>>> +
>>> +struct cleancache_ops {
>>> +       int (*init_fs)(size_t);
>>> +       int (*init_shared_fs)(char *uuid, size_t);
>>> +       int (*get_page)(int, ino_t, pgoff_t, struct page *);
>>> +       void (*put_page)(int, ino_t, pgoff_t, struct page *);
>>> +       void (*flush_page)(int, ino_t, pgoff_t);
>>> +       void (*flush_inode)(int, ino_t);
>>> +       void (*flush_fs)(int);
>>> +};
>>> + 
>>
>> How would someone go about testing this code?  Is there an example
>> cleancache implementation?
> 
> Dan,
> 
> Can you reference with a link or a git branch the patches that utilize
> this?
> 
> And also mention that in the 0/X patch so that folks can reference your
> cleancache implementation?
> 
>

FYI.

I am working on 'zcache' which uses cleancache_ops to provide page cache
compression support. I will be posting it to LKML before end of next week.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
