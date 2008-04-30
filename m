Message-ID: <48189681.5080504@oracle.com>
Date: Wed, 30 Apr 2008 08:55:45 -0700
From: Zach Brown <zach.brown@oracle.com>
MIME-Version: 1.0
Subject: Re: correct use of vmtruncate()?
References: <20080429100601.GO108924158@sgi.com> <481756A3.20601@oracle.com> <20080430072457.GB7791@skywalker>
In-Reply-To: <20080430072457.GB7791@skywalker>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: David Chinner <dgc@sgi.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, xfs-oss <xfs@oss.sgi.com>
List-ID: <linux-mm.kvack.org>

>> This paragraph in particular reminds me of an outstanding bug with
>> O_DIRECT and ext*.  It isn't truncating partial allocations when a dio
>> fails with ENOSPC.  This was noticed by a user who saw that fsck found
>> bocks outside i_size in the file that saw ENOSPC if they tried to
>> unmount and check the volume after the failed write.
> 
> This patch should be the fix I guess
> 	http://lkml.org/lkml/2006/12/18/103

That's the thread related to the bug, yes, but that isn't the right fix
as David's later messages in the thread indicate.

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
