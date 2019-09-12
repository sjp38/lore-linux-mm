Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 877CAC4CEC6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 16:22:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57CF62084D
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 16:22:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57CF62084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8E976B0003; Thu, 12 Sep 2019 12:22:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3F916B0006; Thu, 12 Sep 2019 12:22:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2E6B6B0007; Thu, 12 Sep 2019 12:22:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0023.hostedemail.com [216.40.44.23])
	by kanga.kvack.org (Postfix) with ESMTP id 917C96B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 12:22:12 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id CC127181AC9B4
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 16:22:11 +0000 (UTC)
X-FDA: 75926785662.13.crate01_3021979cbd632
X-HE-Tag: crate01_3021979cbd632
X-Filterd-Recvd-Size: 6996
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 16:22:10 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9F80F883BA;
	Thu, 12 Sep 2019 16:22:09 +0000 (UTC)
Received: from [10.10.125.97] (ovpn-125-97.rdu2.redhat.com [10.10.125.97])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BF0335D704;
	Thu, 12 Sep 2019 16:22:08 +0000 (UTC)
Subject: Re: [RFC PATCH] Add proc interface to set PF_MEMALLOC flags
To: Martin Raiber <martin@urbackup.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
 "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>
References: <20190909162804.5694-1-mchristi@redhat.com>
 <5D76995B.1010507@redhat.com>
 <BYAPR04MB5816DABF3C5071D13D823990E7B60@BYAPR04MB5816.namprd04.prod.outlook.com>
 <0102016d1f7af966-334f093b-2a62-4baa-9678-8d90d5fba6d9-000000@eu-west-1.amazonses.com>
 <5D792758.2060706@redhat.com>
 <0102016d21c61ec3-4e148e0f-24f5-4e00-a74e-6249653167c7-000000@eu-west-1.amazonses.com>
From: Mike Christie <mchristi@redhat.com>
Message-ID: <5D7A70B0.9010407@redhat.com>
Date: Thu, 12 Sep 2019 11:22:08 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101
 Thunderbird/38.6.0
MIME-Version: 1.0
In-Reply-To: <0102016d21c61ec3-4e148e0f-24f5-4e00-a74e-6249653167c7-000000@eu-west-1.amazonses.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 12 Sep 2019 16:22:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/11/2019 02:21 PM, Martin Raiber wrote:
> On 11.09.2019 18:56 Mike Christie wrote:
>> On 09/11/2019 03:40 AM, Martin Raiber wrote:
>>> On 10.09.2019 10:35 Damien Le Moal wrote:
>>>> Mike,
>>>>
>>>> On 2019/09/09 19:26, Mike Christie wrote:
>>>>> Forgot to cc linux-mm.
>>>>>
>>>>> On 09/09/2019 11:28 AM, Mike Christie wrote:
>>>>>> There are several storage drivers like dm-multipath, iscsi, and nbd that
>>>>>> have userspace components that can run in the IO path. For example,
>>>>>> iscsi and nbd's userspace deamons may need to recreate a socket and/or
>>>>>> send IO on it, and dm-multipath's daemon multipathd may need to send IO
>>>>>> to figure out the state of paths and re-set them up.
>>>>>>
>>>>>> In the kernel these drivers have access to GFP_NOIO/GFP_NOFS and the
>>>>>> memalloc_*_save/restore functions to control the allocation behavior,
>>>>>> but for userspace we would end up hitting a allocation that ended up
>>>>>> writing data back to the same device we are trying to allocate for.
>>>>>>
>>>>>> This patch allows the userspace deamon to set the PF_MEMALLOC* flags
>>>>>> through procfs. It currently only supports PF_MEMALLOC_NOIO, but
>>>>>> depending on what other drivers and userspace file systems need, for
>>>>>> the final version I can add the other flags for that file or do a file
>>>>>> per flag or just do a memalloc_noio file.
>>>> Awesome. That probably will be the perfect solution for the problem we hit with
>>>> tcmu-runner a while back (please see this thread:
>>>> https://www.spinics.net/lists/linux-fsdevel/msg148912.html).
>>>>
>>>> I think we definitely need nofs as well for dealing with cases where the backend
>>>> storage for the user daemon is a file.
>>>>
>>>> I will give this patch a try as soon as possible (I am traveling currently).
>>>>
>>>> Best regards.
>>> I had issues with this as well, and work on this is appreciated! In my
>>> case it is a loop block device on a fuse file system.
>>> Setting PF_LESS_THROTTLE was the one that helped the most, though, so
>>> add an option for that as well? I set this via prctl() for the thread
>>> calling it (was easiest to add to).
>>>
>>> Sorry, I have no idea about the current rationale, but wouldn't it be
>>> better to have a way to mask a set of block devices/file systems not to
>>> write-back to in a thread. So in my case I'd specify that the fuse
>>> daemon threads cannot write-back to the file system and loop device
>>> running on top of the fuse file system, while all other block
>>> devices/file systems can be write-back to (causing less swapping/OOM
>>> issues).
>> I'm not sure I understood you.
>>
>> The storage daemons I mentioned normally kick off N threads per M
>> devices. The threads handle duties like IO and error handling for those
>> devices. Those threads would set the flag, so those IO/error-handler
>> related operations do not end up writing back to them. So it works
>> similar to how storage drivers work in the kernel where iscsi_tcp has an
>> xmit thread and that does memalloc_noreclaim_save. Only the threads for
>> those specific devices being would set the flag.
>>
>> In your case, it sounds like you have a thread/threads that would
>> operate on multiple devices and some need the behavior and some do not.
>> Is that right?
> 
> No, sounds the same as your case. As an example think of vdfuse (or
> qemu-nbd locally). You'd have something like
> 
> ext4(a) <- loop <- fuse file system <- vdfuse <- disk.vdi container file
> <- ext4(b) <- block device
> 
> If vdfuse threads cause writeback to ext4(a), you'd get the issue we
> have. Setting PF_LESS_THROTTLE and/or PF_MEMALLOC_NOIO mostly avoids
> this problem, but with only PF_LESS_THROTTLE there are still corner
> cases (I think if ext4(b) slows down suddenly) where it wedges itself
> and the side effect of setting PF_MEMALLOC_NOIO are being discussed...
> The best solution would be, I guess, to have a way for vdfuse to set
> something, such that write-back to ext4(a) isn't allowed from those
> threads, but write-back to ext4(b) (and all other block devices) is. But
> I only have a rough idea of how write-back works, so this is really only
> a guess.

I see now.

Initially, would it be ok to keep it simple and keep the existing kernel
behavior? For your example, is the PF_MEMALLOC_NOIO use in loop today
causing a lot of swap/oom issues? For iscsi_tcp and nbd their memalloc
and GFP_NOIO use is not.

The problem for the storage driver daemons I mentioned in the patch is
that they are at the bottom of the stack and they do not know what is
going to be added above them plus it can change, so we will have to walk
the storage device stack while IO is running and allocations are trying
to execute. It looks like I will end up having to insert extra
locking/refcounts into multiple layers, and I am not sure if the extra
complexity is going to be worth it if we are not seeing problems from
existing kernel users.

