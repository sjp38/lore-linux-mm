Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 72FA86B004D
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 23:25:31 -0400 (EDT)
Received: by dakh32 with SMTP id h32so8292806dak.9
        for <linux-mm@kvack.org>; Mon, 16 Apr 2012 20:25:30 -0700 (PDT)
Message-ID: <4F8CE2A6.7070004@gmail.com>
Date: Tue, 17 Apr 2012 11:25:26 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: question about memsw of memory cgroup-subsystem
References: <op.wco7ekvhn27o5l@gaoqiang-d1.corp.qihoo.net> <20120413144954.GA9227@tiehlicka.suse.cz> <op.wct9zibjn27o5l@gaoqiang-d1.corp.qihoo.net>
In-Reply-To: <op.wct9zibjn27o5l@gaoqiang-d1.corp.qihoo.net>
Content-Type: text/plain; charset=x-gbk; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gaoqiang <gaoqiangscut@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org

On 04/16/2012 11:43 AM, gaoqiang wrote:
> OU Fri, 13 Apr 2012 22:49:54 +0800GBP!Michal Hocko <mhocko@suse.cz> D'uA:
>
>> [CC linux-mm]
>>
>> Hi,
>>
>> On Fri 13-04-12 18:00:10, gaoqiang wrote:
>>>
>>>
>>> I put a single process into a cgroup and set memory.limit_in_bytes
>>> to 100M,and memory.memsw.limit_in_bytes to 1G.
>>>
>>> howevery,the process was oom-killed before mem+swap hit 1G. I tried
>>> many times,and it was killed randomly when memory+swap
>>>
>>> exceed 100M but less than 1G. what is the matter ?
>>
>> could you be more specific about your kernel version, workload and could
>> you provide us with GROUP/memory.stat snapshots taken during your test?
>>
>> One reason for oom might be that you are hitting the hard limit (you
>> cannot get over even if memsw limit says more) and you cannot swap out
>> any pages (e.g. they are mlocked or under writeback).
>>
>
> many thanks.
>
>
> The system is a vmware virtual machine,running centos6.2 with kernel 
> 2.6.32-220.7.1.el6.x86_64.
>
> the attachments are memory.stat, the test program and the 
> /var/log/message of the oom.
>
> the workload is nearly 0,with searal sshd and bash program running.
>
> I just did the following command when testing:
>
> ./t
> # this program will pause at the "getchar()" line and in another 
> terminal,run :
>
> cgclear
> service cgconfig restart
> mkdir /cgroup/memory/test
> cd /cgroup/memory/test
> echo 100m > memory.limit_in_bytes
> echo 1G > memory.memsw.limit_in_bytes
> echo 'pid' > tasks
>
> # then continue the t command
>
>
Hi,

I run your test under RHEL6.1 with 2.6.32-220.7.1.el6.x86_64 (an 
internal version but
no changes in mm/memcg) in a real server and the process is killed with 
memsw reaching
1G. Does your vmware virtual machine have enough swap space?.. I've no 
idea whether
the different behavior come from the physical/virtual environment.


Thanks,
Sha


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
