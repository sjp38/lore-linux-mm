Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 474BE6B0255
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 10:47:27 -0500 (EST)
Received: by igcmv3 with SMTP id mv3so120341718igc.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 07:47:27 -0800 (PST)
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id 21si6398472iod.72.2015.12.02.07.47.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 07:47:26 -0800 (PST)
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id D089C20C5B
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 10:47:23 -0500 (EST)
Date: Wed, 2 Dec 2015 07:47:20 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] oom kill init lead panic
Message-ID: <20151202154720.GB31371@kroah.com>
References: <1449037856-23990-1-git-send-email-chenjie6@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449037856-23990-1-git-send-email-chenjie6@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chenjie6@huawei.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David.Woodhouse@intel.com, zhihui.gao@huawei.com, lizefan@huawei.com, akpm@linux-foundation.org, stable@vger.kernel.org

On Wed, Dec 02, 2015 at 02:30:56PM +0800, chenjie6@huawei.com wrote:
> From: chenjie <chenjie6@huawei.com>

This name should match...

> Signed-off-by: Chen Jie <chenjie6@huawei.com>

this name please.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
