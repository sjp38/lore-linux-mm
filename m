Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id E55106B015D
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 07:58:00 -0400 (EDT)
Received: by mail-yh0-f54.google.com with SMTP id f73so8375344yha.13
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 04:58:00 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id t43si17127791yhj.205.2014.03.19.04.58.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Mar 2014 04:58:00 -0700 (PDT)
Message-ID: <53298646.4080404@citrix.com>
Date: Wed, 19 Mar 2014 11:57:58 +0000
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [mm/vmalloc] BUG: sleeping function called from invalid context
 at mm/vmalloc.c:74
References: <20140319115540.GA7277@localhost>
In-Reply-To: <20140319115540.GA7277@localhost>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, lkp@01.org, Linux Memory Management List <linux-mm@kvack.org>

On 19/03/14 11:55, Fengguang Wu wrote:
> Hi David,
> 
> FYI, we noticed the below BUG on
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> commit 032dda8b6c4021d4be63bcc483b47fd26c6f48a2 ("mm/vmalloc: avoid soft lockup warnings when vunmap()'ing large ranges")

Thanks,  this patches have been are in the process of being dropped.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
