Message-ID: <402081F6.9010508@matchmail.com>
Date: Tue, 03 Feb 2004 21:24:06 -0800
From: Mike Fedyk <mfedyk@matchmail.com>
MIME-Version: 1.0
Subject: Re: Active Memory Defragmentation: Our implementation & problems
References: <20040204050915.59866.qmail@web9704.mail.yahoo.com>
In-Reply-To: <20040204050915.59866.qmail@web9704.mail.yahoo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alok Mooley <rangdi@yahoo.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alok Mooley wrote:

> The regular buddy freeing function also increases the
>number of free pages. Since we are not actually
>freeing pages (we are just moving them), we do not
>want the original freeing function. But then we could 
>decrease the number of free pages by the same number &
>use the buddy freeing function. Will do. Thanks.
>  
>
Then you need to split the parts you want out into sub-functions and 
call it from the previous callers, and your new use for it...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
