Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 074396B0062
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 21:10:38 -0500 (EST)
Message-ID: <50F60BDE.8050304@cn.fujitsu.com>
Date: Wed, 16 Jan 2013 10:09:34 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2] memory-hotplug: revert register_page_bootmem_info_node()
 to empty when platform related code is not implemented
References: <1358245203-4181-1-git-send-email-linfeng@cn.fujitsu.com> <20130115142056.GC21725@dhcp22.suse.cz>
In-Reply-To: <20130115142056.GC21725@dhcp22.suse.cz>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, minchan@kernel.org, aquini@redhat.com, wency@cn.fujitsu.com, jiang.liu@huawei.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linux-kernel@vger.kernel.org

Hi Michal,

On 01/15/2013 10:20 PM, Michal Hocko wrote:
>> +#else
>> > +void register_page_bootmem_info_node(struct pglist_data *pgdat)
>> > +{
>> > +	/* TODO */
>> > +}
> I think that TODO is misleading here because the function should be
> empty if !CONFIG_HAVE_BOOTMEM_INFO_NODE. I would also suggest updating
Yes, I got lost here, you are right, thanks.

> include/linux/memory_hotplug.h and removing the arch specific functions
> without any implementation. Something like (untested) patch below:
I will merge your suggestion in next version.

thanks,
linfeng
> ---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
