Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <51243BF7.3030004@cn.fujitsu.com>
Date: Wed, 20 Feb 2013 10:59:03 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: hotplug: implement non-movable version of get_user_pages()
 called get_user_pages_non_movable()
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com> <1359972248-8722-2-git-send-email-linfeng@cn.fujitsu.com> <20130204160624.5c20a8a0.akpm@linux-foundation.org> <20130205115722.GF21389@suse.de> <20130205133244.GH21389@suse.de> <51238033.6010005@cn.fujitsu.com> <5124363C.9060604@cn.fujitsu.com> <20130220024435.GA30208@hacker.(null)>
In-Reply-To: <20130220024435.GA30208@hacker.(null)>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, mhocko@suse.cz, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Wanpeng,

On 02/20/2013 10:44 AM, Wanpeng Li wrote:
>> Sorry, I misunderstood what "tail pages" means, stupid question, just ignore it.
>> >flee...
> According to the compound page, the first page of compound page is
> called head page, other sub pages are called tail pages.
> 
> Regards,
> Wanpeng Li 
> 
Yes, you are right, thanks for explaining.
I thought it just means only the last one of the compound pages..

thanks,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
