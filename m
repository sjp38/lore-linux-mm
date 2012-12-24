Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 9A5FB6B0044
	for <linux-mm@kvack.org>; Mon, 24 Dec 2012 03:23:10 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id jt11so3847337pbb.40
        for <linux-mm@kvack.org>; Mon, 24 Dec 2012 00:23:09 -0800 (PST)
Date: Mon, 24 Dec 2012 16:36:37 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Re: [PATCH v2 2/3] mm: Update file times when inodes are written
 after mmaped writes
Message-ID: <20121224083637.GA11906@gmail.com>
References: <cover.1356124965.git.luto@amacapital.net>
 <6b22b806806b21af02b70a2fa860a9d10304fc16.1356124965.git.luto@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6b22b806806b21af02b70a2fa860a9d10304fc16.1356124965.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>

On Fri, Dec 21, 2012 at 01:28:27PM -0800, Andy Lutomirski wrote:
> The onus is currently on filesystems to call file_update_time
> somewhere in the page_mkwrite path.  This is unfortunate for three
> reasons:
> 
> 1. page_mkwrite on a locked page should be fast.  ext4, for example,
>    often sleeps while dirtying inodes.  (This could be considered a
>    fixable problem with ext4, but this approach makes it
>    irrelevant.)

Hi Andy,

Out of curiosity, could you please share more detailed information about
how to reproduce and measure this problem in ext4?

Thanks
                                        - Zheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
