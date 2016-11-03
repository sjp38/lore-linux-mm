Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3D22D6B02DD
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 16:46:57 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u144so3381258wmu.1
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 13:46:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h84si919614wmf.90.2016.11.03.13.46.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Nov 2016 13:46:55 -0700 (PDT)
Date: Thu, 3 Nov 2016 21:46:22 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/21 v4] dax: Clear dirty bits after flushing caches
Message-ID: <20161103204622.GD24234@quack2.suse.cz>
References: <1478039794-20253-1-git-send-email-jack@suse.cz>
 <20161101231318.GC20418@quack2.suse.cz>
 <20161102100217.GC20724@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161102100217.GC20724@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org

On Wed 02-11-16 13:02:17, Kirill A. Shutemov wrote:
> On Wed, Nov 02, 2016 at 12:13:18AM +0100, Jan Kara wrote:
> > Hi,
> > 
> > forgot to add Kirill to CC since this modifies the fault path he changed
> > recently. I don't want to resend the whole series just because of this so
> > at least I'm pinging him like this...
> 
> I see strange mix x/20 and x/21 patches. Which should I look at?

Ah, sorry, I've messed up the send out (I already had the old series
formatted in that directory). I'll send it again with you in CC.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
