Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 83CBE6B0276
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 14:22:00 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id e70so3826918wmc.6
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 11:22:00 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id k14si4488094wrf.236.2017.12.07.11.21.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 11:21:59 -0800 (PST)
Date: Thu, 7 Dec 2017 19:21:56 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 4/8] vfs: remove unused hardirq.h
Message-ID: <20171207192156.GF21978@ZenIV.linux.org.uk>
References: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com>
 <1510959741-31109-4-git-send-email-yang.s@alibaba-inc.com>
 <0bfadf85-b499-5d2f-f0d2-20d229ba7fe2@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0bfadf85-b499-5d2f-f0d2-20d229ba7fe2@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, netdev@vger.kernel.org

On Fri, Dec 08, 2017 at 03:12:52AM +0800, Yang Shi wrote:
> Hi folks,
> 
> Any comment on this one?

Applied

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
