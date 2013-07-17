Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <51E5F03A.4060508@cn.fujitsu.com>
Date: Wed, 17 Jul 2013 09:15:38 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH RESEND 1/2] fs/anon_inode: Introduce a new lib function
 anon_inode_getfile_private()
References: <51E518BC.8040900@cn.fujitsu.com> <20130716131614.GC5403@kvack.org>
In-Reply-To: <20130716131614.GC5403@kvack.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Al Viro <viro@zeniv.linux.org.uk>, tangchen <tangchen@cn.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Hi Ben,

On 07/16/2013 09:16 PM, Benjamin LaHaise wrote:

> On Tue, Jul 16, 2013 at 05:56:12PM +0800, Gu Zheng wrote:
>>
>> Introduce a new lib function anon_inode_getfile_private(), it creates a new file
>> instance by hooking it up to an anonymous inode, and a dentry that describe the
>> "class" of the file, similar to anon_inode_getfile(), but each file holds a
>> single inode. Furthermore, anyone who wants to create a private anon file will
>> benefit from this change.
>>
>> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
>> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
> 
> Please don't add my Signed-off-by when I have never even seen or reviewed 
> a patch -- that is completely unacceptable.  

Sorry for my reckless action, I'll remember your reminder.:)

> Second, I don't think this 
> patch is suitable for 3.11, as it has not seen much testing outside of one 
> test program I had written.  It's a long standing bug, so it isn't urgent 
> to get the fix into the tree.  That said, it did pass a few tests I ran 
> last night, so it is probably suitable for the -next tree.

Thanks for your test.:)

Regards,
Gu

> 
> As for patch 1, it looks okay to me, but will need Al Viro's signoff.
> 
> 		-ben


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
