Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FORGED_MUA_MOZILLA,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64C74ECDE27
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 08:43:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D18721928
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 08:43:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=urbackup.org header.i=@urbackup.org header.b="TLoD1gqx";
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="grYXhPHg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D18721928
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=urbackup.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A56E96B0005; Wed, 11 Sep 2019 04:43:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DFBB6B0006; Wed, 11 Sep 2019 04:43:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87FDB6B0007; Wed, 11 Sep 2019 04:43:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0226.hostedemail.com [216.40.44.226])
	by kanga.kvack.org (Postfix) with ESMTP id 5E84E6B0005
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 04:43:05 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 02FFC181AC9BF
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 08:43:05 +0000 (UTC)
X-FDA: 75921999930.21.hot33_37e6af6750b60
X-HE-Tag: hot33_37e6af6750b60
X-Filterd-Recvd-Size: 8517
Received: from a4-15.smtp-out.eu-west-1.amazonses.com (a4-15.smtp-out.eu-west-1.amazonses.com [54.240.4.15])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 08:43:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ob2ngmaigrjtzxgmrxn2h6b3gszyqty3; d=urbackup.org; t=1568191382;
	h=Subject:To:References:From:Message-ID:Date:MIME-Version:In-Reply-To:Content-Type:Content-Transfer-Encoding;
	bh=qQV7uqEq2fVv9oREM0bMzbb0KcjU3d8iebg1LaeyBTc=;
	b=TLoD1gqxxP7r6utL/9OtMw8yUySe+K7y4cLzzPu6J8sE1TtJ0MiB2y01znctz8F7
	6BRID5yGQaZi1TPVDhRv3V1HRf2mBj16mhs23GeN+tG6ZiLBpKfH0jHCYSrJ+MJTcZW
	Dmzqh9DJzKRRgdoOD/1qYH68u5ASBCYg9GvzWNPc=
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ihchhvubuqgjsxyuhssfvqohv7z3u4hn; d=amazonses.com; t=1568191382;
	h=Subject:To:References:From:Message-ID:Date:MIME-Version:In-Reply-To:Content-Type:Content-Transfer-Encoding:Feedback-ID;
	bh=qQV7uqEq2fVv9oREM0bMzbb0KcjU3d8iebg1LaeyBTc=;
	b=grYXhPHgGJgLXTMb/as/jG6VbPuWhQEA6kIWj49qooBq6W+2PKnfZm6ywbXqXUF0
	gs7utbsvGgT/M+hGfW7vmH0Z2yU+kX3fol3NWnWplSFVoXnrwO9/dFWsVLAVvwv0p8y
	bHfYoEw7ZsgXQUIVE++Jhaoxt+atkYX96OeudsW0=
Subject: Re: [RFC PATCH] Add proc interface to set PF_MEMALLOC flags
To: Damien Le Moal <Damien.LeMoal@wdc.com>,
 Mike Christie <mchristi@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
 "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>
References: <20190909162804.5694-1-mchristi@redhat.com>
 <5D76995B.1010507@redhat.com>
 <BYAPR04MB5816DABF3C5071D13D823990E7B60@BYAPR04MB5816.namprd04.prod.outlook.com>
From: Martin Raiber <martin@urbackup.org>
Message-ID: <0102016d1f7d8136-cb7bca70-0509-4a29-b687-5b93a36e3fec-000000@eu-west-1.amazonses.com>
Date: Wed, 11 Sep 2019 08:43:02 +0000
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.9.0
MIME-Version: 1.0
In-Reply-To: <BYAPR04MB5816DABF3C5071D13D823990E7B60@BYAPR04MB5816.namprd04.prod.outlook.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-SES-Outgoing: 2019.09.11-54.240.4.15
Feedback-ID: 1.eu-west-1.zKMZH6MF2g3oUhhjaE2f3oQ8IBjABPbvixQzV8APwT0=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 10.09.2019 10:35 Damien Le Moal wrote:
> Mike,
>
> On 2019/09/09 19:26, Mike Christie wrote:
>> Forgot to cc linux-mm.
>>
>> On 09/09/2019 11:28 AM, Mike Christie wrote:
>>> There are several storage drivers like dm-multipath, iscsi, and nbd that
>>> have userspace components that can run in the IO path. For example,
>>> iscsi and nbd's userspace deamons may need to recreate a socket and/or
>>> send IO on it, and dm-multipath's daemon multipathd may need to send IO
>>> to figure out the state of paths and re-set them up.
>>>
>>> In the kernel these drivers have access to GFP_NOIO/GFP_NOFS and the
>>> memalloc_*_save/restore functions to control the allocation behavior,
>>> but for userspace we would end up hitting a allocation that ended up
>>> writing data back to the same device we are trying to allocate for.
>>>
>>> This patch allows the userspace deamon to set the PF_MEMALLOC* flags
>>> through procfs. It currently only supports PF_MEMALLOC_NOIO, but
>>> depending on what other drivers and userspace file systems need, for
>>> the final version I can add the other flags for that file or do a file
>>> per flag or just do a memalloc_noio file.
> Awesome. That probably will be the perfect solution for the problem we hit with
> tcmu-runner a while back (please see this thread:
> https://www.spinics.net/lists/linux-fsdevel/msg148912.html).
>
> I think we definitely need nofs as well for dealing with cases where the backend
> storage for the user daemon is a file.
>
> I will give this patch a try as soon as possible (I am traveling currently).
>
> Best regards.
I had issues with this as well, and work on this is appreciated! In my
case it is a loop block device on a fuse file system.

Setting PF_LESS_THROTTLE was the one that helped the most, though, so
add an option for that as well? I set this via prctl() for the thread
calling it (was easiest to add to).

Sorry, I have no idea about the current rationale, but wouldn't it be
better to have a way to mask a set of block devices/file systems not to
write-back to in a thread. So in my case I'd specify that the fuse
daemon threads cannot write-back to the file system and loop device
running on top of the fuse file system, while all other block
devices/file systems can be write-back to (causing less swapping/OOM
issues).

>
>>> Signed-off-by: Mike Christie <mchristi@redhat.com>
>>> ---
>>>  Documentation/filesystems/proc.txt |  6 ++++
>>>  fs/proc/base.c                     | 53 ++++++++++++++++++++++++++++++
>>>  2 files changed, 59 insertions(+)
>>>
>>> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
>>> index 99ca040e3f90..b5456a61a013 100644
>>> --- a/Documentation/filesystems/proc.txt
>>> +++ b/Documentation/filesystems/proc.txt
>>> @@ -46,6 +46,7 @@ Table of Contents
>>>    3.10  /proc/<pid>/timerslack_ns - Task timerslack value
>>>    3.11	/proc/<pid>/patch_state - Livepatch patch operation state
>>>    3.12	/proc/<pid>/arch_status - Task architecture specific information
>>> +  3.13  /proc/<pid>/memalloc - Control task's memory reclaim behavior
>>>  
>>>    4	Configuring procfs
>>>    4.1	Mount options
>>> @@ -1980,6 +1981,11 @@ Example
>>>   $ cat /proc/6753/arch_status
>>>   AVX512_elapsed_ms:      8
>>>  
>>> +3.13 /proc/<pid>/memalloc - Control task's memory reclaim behavior
>>> +-----------------------------------------------------------------------
>>> +A value of "noio" indicates that when a task allocates memory it will not
>>> +reclaim memory that requires starting phisical IO.
>>> +
>>>  Description
>>>  -----------
>>>  
>>> diff --git a/fs/proc/base.c b/fs/proc/base.c
>>> index ebea9501afb8..c4faa3464602 100644
>>> --- a/fs/proc/base.c
>>> +++ b/fs/proc/base.c
>>> @@ -1223,6 +1223,57 @@ static const struct file_operations proc_oom_score_adj_operations = {
>>>  	.llseek		= default_llseek,
>>>  };
>>>  
>>> +static ssize_t memalloc_read(struct file *file, char __user *buf, size_t count,
>>> +			     loff_t *ppos)
>>> +{
>>> +	struct task_struct *task;
>>> +	ssize_t rc = 0;
>>> +
>>> +	task = get_proc_task(file_inode(file));
>>> +	if (!task)
>>> +		return -ESRCH;
>>> +
>>> +	if (task->flags & PF_MEMALLOC_NOIO)
>>> +		rc = simple_read_from_buffer(buf, count, ppos, "noio", 4);
>>> +	put_task_struct(task);
>>> +	return rc;
>>> +}
>>> +
>>> +static ssize_t memalloc_write(struct file *file, const char __user *buf,
>>> +			      size_t count, loff_t *ppos)
>>> +{
>>> +	struct task_struct *task;
>>> +	char buffer[5];
>>> +	int rc = count;
>>> +
>>> +	memset(buffer, 0, sizeof(buffer));
>>> +	if (count != sizeof(buffer) - 1)
>>> +		return -EINVAL;
>>> +
>>> +	if (copy_from_user(buffer, buf, count))
>>> +		return -EFAULT;
>>> +	buffer[count] = '\0';
>>> +
>>> +	task = get_proc_task(file_inode(file));
>>> +	if (!task)
>>> +		return -ESRCH;
>>> +
>>> +	if (!strcmp(buffer, "noio")) {
>>> +		task->flags |= PF_MEMALLOC_NOIO;
>>> +	} else {
>>> +		rc = -EINVAL;
>>> +	}
>>> +
>>> +	put_task_struct(task);
>>> +	return rc;
>>> +}
>>> +
>>> +static const struct file_operations proc_memalloc_operations = {
>>> +	.read		= memalloc_read,
>>> +	.write		= memalloc_write,
>>> +	.llseek		= default_llseek,
>>> +};
>>> +
>>>  #ifdef CONFIG_AUDIT
>>>  #define TMPBUFLEN 11
>>>  static ssize_t proc_loginuid_read(struct file * file, char __user * buf,
>>> @@ -3097,6 +3148,7 @@ static const struct pid_entry tgid_base_stuff[] = {
>>>  #ifdef CONFIG_PROC_PID_ARCH_STATUS
>>>  	ONE("arch_status", S_IRUGO, proc_pid_arch_status),
>>>  #endif
>>> +	REG("memalloc", S_IRUGO|S_IWUSR, proc_memalloc_operations),
>>>  };
>>>  
>>>  static int proc_tgid_base_readdir(struct file *file, struct dir_context *ctx)
>>> @@ -3487,6 +3539,7 @@ static const struct pid_entry tid_base_stuff[] = {
>>>  #ifdef CONFIG_PROC_PID_ARCH_STATUS
>>>  	ONE("arch_status", S_IRUGO, proc_pid_arch_status),
>>>  #endif
>>> +	REG("memalloc", S_IRUGO|S_IWUSR, proc_memalloc_operations),
>>>  };
>>>  
>>>  static int proc_tid_base_readdir(struct file *file, struct dir_context *ctx)
>>>
>>
>


