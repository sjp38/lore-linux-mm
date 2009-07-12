Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CA4816B004F
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 10:44:27 -0400 (EDT)
Message-ID: <4A59FA7D.1040009@panasas.com>
Date: Sun, 12 Jul 2009 18:00:13 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
Subject: Re: [rfc][patch 3/4] fs: new truncate sequence
References: <20090707150257.GG2714@wotan.suse.de> <20090707150758.GA18075@infradead.org> <20090707154809.GH2714@wotan.suse.de> <20090707163042.GA14947@infradead.org> <20090708063225.GL2714@wotan.suse.de> <20090708104701.GA31419@infradead.org> <20090708123412.GQ2714@wotan.suse.de> <4A54C435.1000503@panasas.com> <20090709075100.GU2714@wotan.suse.de> <4A59A517.1080605@panasas.com> <20090712144717.GA18163@infradead.org>
In-Reply-To: <20090712144717.GA18163@infradead.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Nick Piggin <npiggin@suse.de>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/12/2009 05:47 PM, Christoph Hellwig wrote:
> On Sun, Jul 12, 2009 at 11:55:51AM +0300, Boaz Harrosh wrote:
>> I wish you would split it.
>>
>> one - helper to be called by converted file systems
>>       (Which just ignores the ATTR_SIZE)
>> second - to be set into .setattr which does the simple_setsize + above.
>>
>> More clear for FS users like me (and that ugly unmask of ATTR_SIZE)
>>
>> or it's just me?
> 
> Yeah, that seems be a lot cleaner.  But let's wait until we got
> rid of ->truncate for all filesystems to have the bigger picture.
> 

I want to convert exofs. do you want that I call inode_setattr clearing
ATTR_SIZE bit, and at second stage remove the clearing and rename inode_setattr
to something else?

When it's time to convert exofs, tel me I'll do it. I have dependent work
on top of that, and I want to cleanup the delete_inode as well as some other
leftovers.

(BTW For none-buffer-heads systems like exofs the new way makes lots of sense)

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
