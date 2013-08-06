Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 470B26B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 22:21:53 -0400 (EDT)
Message-ID: <52005D92.1090103@huawei.com>
Date: Tue, 6 Aug 2013 10:21:06 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/5] cgroup, memcg: move cgroup_event implementation
 to memcg
References: <1375632446-2581-1-git-send-email-tj@kernel.org> <1375632446-2581-4-git-send-email-tj@kernel.org> <20130805170928.GB23751@mtj.dyndns.org> <5200593C.7090005@huawei.com>
In-Reply-To: <5200593C.7090005@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2013/8/6 10:02, Li Zefan wrote:
>>  static struct cftype mem_cgroup_files[] = {
>>  	{
>>  		.name = "usage_in_bytes",
>> @@ -5973,6 +6192,12 @@ static struct cftype mem_cgroup_files[] = {
>>  		.read_u64 = mem_cgroup_hierarchy_read,
>>  	},
>>  	{
>> +		.name = "cgroup.event_control",
>> +		.write_string = cgroup_write_event_control,
>> +		.flags = CFTYPE_NO_PREFIX,
>> +		.mode = S_IWUGO,
>> +	},
> 
> One of the misdesign of cgroup eventfd is, cgroup.event_control is
> totally redunant...
> 

ok. write_string() is needed to accept arguments and pass them to
the event register function. still not good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
