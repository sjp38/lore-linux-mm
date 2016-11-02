Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6E3BF6B02AB
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 06:02:36 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id o20so2204233lfg.2
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 03:02:36 -0700 (PDT)
Received: from mail-lf0-x22e.google.com (mail-lf0-x22e.google.com. [2a00:1450:4010:c07::22e])
        by mx.google.com with ESMTPS id s2si762988lfe.362.2016.11.02.03.02.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 03:02:35 -0700 (PDT)
Received: by mail-lf0-x22e.google.com with SMTP id c13so8109834lfg.0
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 03:02:35 -0700 (PDT)
Date: Wed, 2 Nov 2016 13:02:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/21 v4] dax: Clear dirty bits after flushing caches
Message-ID: <20161102100217.GC20724@node.shutemov.name>
References: <1478039794-20253-1-git-send-email-jack@suse.cz>
 <20161101231318.GC20418@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161101231318.GC20418@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org

On Wed, Nov 02, 2016 at 12:13:18AM +0100, Jan Kara wrote:
> Hi,
> 
> forgot to add Kirill to CC since this modifies the fault path he changed
> recently. I don't want to resend the whole series just because of this so
> at least I'm pinging him like this...

I see strange mix x/20 and x/21 patches. Which should I look at?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
