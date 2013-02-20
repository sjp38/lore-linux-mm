Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <5124C3E6.1060108@cn.fujitsu.com>
Date: Wed, 20 Feb 2013 20:39:02 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 1/2] mm: hotplug: implement non-movable version of
 get_user_pages() called get_user_pages_non_movable()
References: <1360056113-14294-1-git-send-email-linfeng@cn.fujitsu.com> <1360056113-14294-2-git-send-email-linfeng@cn.fujitsu.com> <20130220113757.GA10124@hacker.(null)>
In-Reply-To: <20130220113757.GA10124@hacker.(null)>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi  Wanpeng,

On 02/20/2013 07:37 PM, Wanpeng Li wrote:
>> + * This function first calls get_user_pages() to get the candidate pages, and
>> >+ * then check to ensure all pages are from non movable zone. Otherwise migrate
> How about "Otherwise migrate candidate pages which have already been 
> isolated to non movable zone."?
> 

Which is just what the code does, I'm feeling that it's too detailed to be proper :(
Do we have to comment it like that detailedly?

thanks,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
