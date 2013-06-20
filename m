Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 2A15E6B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 19:20:47 -0400 (EDT)
Message-ID: <51C38E3D.5090805@oracle.com>
Date: Fri, 21 Jun 2013 07:20:29 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] zswap: update/document boot parameters
References: <1371716949-9918-1-git-send-email-bob.liu@oracle.com> <20130620144826.GB9461@cerebellum>
In-Reply-To: <20130620144826.GB9461@cerebellum>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Bob Liu <lliubbo@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, konrad.wilk@oracle.com



On 06/20/2013 10:48 PM, Seth Jennings wrote:
> On Thu, Jun 20, 2013 at 04:29:09PM +0800, Bob Liu wrote:
>> The current parameters of zswap are not straightforward.
>> Changed them to start with zswap* and documented them.
> 
> Thanks for the patch!
> 
> However, I think you might be missing that using module_param(_named) allows
> access on the kernel boot line with <modulename>.<moduleparam> syntax.  So

Oh, yes.
Sorry for the noise, I missed the meaning of module_param.

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
