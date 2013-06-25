Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 991E36B0036
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 22:30:41 -0400 (EDT)
Message-ID: <51C900BD.60109@oracle.com>
Date: Tue, 25 Jun 2013 10:30:21 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] vfs: export lseek_execute() to modules
References: <51C832F8.2090707@oracle.com> <20130624125513.GA7921@infradead.org>
In-Reply-To: <20130624125513.GA7921@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 06/24/2013 08:55 PM, Christoph Hellwig wrote:

> On Mon, Jun 24, 2013 at 07:52:24PM +0800, Jeff Liu wrote:
>> From: Jie Liu <jeff.liu@oracle.com>
>>
>> For those file systems(btrfs/ext4/xfs/ocfs2/tmpfs) that support
>> SEEK_DATA/SEEK_HOLE functions, we end up handling the similar
>> matter in lseek_execute() to verify the final offset.
>>
>> To reduce the duplications, this patch make lseek_execute() public
>> accessible so that we can call it directly from them.
>>
>> Thanks Dave Chinner for this suggestion.
> 
> Please add a kerneldoc comment explaining the use of this function.

Ok, I'll repost it later.

Thanks,
-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
