Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E3C606B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 01:44:55 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u63so23953079wmu.0
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 22:44:55 -0800 (PST)
Received: from dggrg03-dlp.huawei.com ([45.249.212.189])
        by mx.google.com with ESMTPS id 36si9471844wrk.321.2017.03.01.22.44.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Mar 2017 22:44:54 -0800 (PST)
Subject: Re: mm allocation failure and hang when running xfstests generic/269
 on xfs
References: <20170301044634.rgidgdqqiiwsmfpj@XZHOUW.usersys.redhat.com>
 <20170302003731.GB24593@infradead.org>
 <20170302051900.ct3xbesn2ku7ezll@XZHOUW.usersys.redhat.com>
From: Bob Liu <liubo95@huawei.com>
Message-ID: <25dc5032-db32-5814-cabe-14e015302423@huawei.com>
Date: Thu, 2 Mar 2017 14:41:41 +0800
MIME-Version: 1.0
In-Reply-To: <20170302051900.ct3xbesn2ku7ezll@XZHOUW.usersys.redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiong Zhou <xzhou@redhat.com>, Christoph Hellwig <hch@infradead.org>, mhocko@suse.com
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On 2017/3/2 13:19, Xiong Zhou wrote:
> On Wed, Mar 01, 2017 at 04:37:31PM -0800, Christoph Hellwig wrote:
>> On Wed, Mar 01, 2017 at 12:46:34PM +0800, Xiong Zhou wrote:
>>> Hi,
>>>
>>> It's reproduciable, not everytime though. Ext4 works fine.
>>
>> On ext4 fsstress won't run bulkstat because it doesn't exist.  Either
>> way this smells like a MM issue to me as there were not XFS changes
>> in that area recently.
> 
> Yap.
> 
> First bad commit:
> 

It looks like not a bug.
>From below commit, the allocation failure print was due to current process received SIGKILL signal.
You may need to confirm whether that's the case. 

Regards,
Bob

> commit 5d17a73a2ebeb8d1c6924b91e53ab2650fe86ffb
> Author: Michal Hocko <mhocko@suse.com>
> Date:   Fri Feb 24 14:58:53 2017 -0800
> 
>     vmalloc: back off when the current task is killed
> 
> Reverting this commit on top of
>   e5d56ef Merge tag 'watchdog-for-linus-v4.11'
> survives the tests.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
