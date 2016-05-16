Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7386B025E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 06:02:11 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id d139so248199935oig.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 03:02:11 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTP id kd1si11239327oeb.52.2016.05.16.03.02.09
        for <linux-mm@kvack.org>;
        Mon, 16 May 2016 03:02:10 -0700 (PDT)
Message-ID: <57399A84.20205@huawei.com>
Date: Mon, 16 May 2016 18:01:40 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: why the count nr_file_pages is not equal to nr_inactive_file
 + nr_active_file ?
References: <573550D8.9030507@huawei.com> <dce01643-7aa9-e779-e4ac-b74439f5074d@intel.com> <573582DE.3030302@huawei.com> <20160516095720.GB23251@dhcp22.suse.cz>
In-Reply-To: <20160516095720.GB23251@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Aaron Lu <aaron.lu@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/5/16 17:57, Michal Hocko wrote:

> [Sorry I haven't noticed this answer before]
> 
> On Fri 13-05-16 15:31:42, Xishi Qiu wrote:
>> On 2016/5/13 15:00, Aaron Lu wrote:
>>
>> Hi Aaron,
>>
>> Thanks for your reply, but I find the count of nr_shmem is very small
>> in my system.
> 
> which kernel version is this? I remember that we used to account thp
> pages as NR_FILE_PAGE as well in the past.
> 
> I didn't get to look at your number more closely though.

Hi Michal,

It's android kernel, v3.10
I think the thp config is off.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
