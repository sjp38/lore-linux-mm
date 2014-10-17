Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id CB8E16B006E
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 11:42:13 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id p9so887631lbv.7
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 08:42:12 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [78.47.125.74])
        by mx.google.com with ESMTP id sf5si2627898lbb.46.2014.10.17.08.42.09
        for <linux-mm@kvack.org>;
        Fri, 17 Oct 2014 08:42:11 -0700 (PDT)
Date: Fri, 17 Oct 2014 15:42:02 +0000 (UTC)
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Message-ID: <2128367244.10915.1413560522748.JavaMail.zimbra@efficios.com>
In-Reply-To: <20141016221624.GL11522@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com> <1411677218-29146-21-git-send-email-matthew.r.wilcox@intel.com> <20141016125625.GR19075@thinkos.etherlink> <20141016221624.GL11522@wil.cx>
Subject: Re: [PATCH v11 20/21] ext4: Add DAX functionality
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

----- Original Message -----
> From: "Matthew Wilcox" <willy@linux.intel.com>
> To: "Mathieu Desnoyers" <mathieu.desnoyers@efficios.com>
> Cc: "Matthew Wilcox" <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
> linux-kernel@vger.kernel.org, "Ross Zwisler" <ross.zwisler@linux.intel.com>
> Sent: Friday, October 17, 2014 12:16:24 AM
> Subject: Re: [PATCH v11 20/21] ext4: Add DAX functionality
> 
[...]
> On Thu, Oct 16, 2014 at 02:56:25PM +0200, Mathieu Desnoyers wrote:
> > > @@ -3572,6 +3579,11 @@ static int ext4_fill_super(struct super_block *sb,
> > > void *data, int silent)
> > >  				 "both data=journal and dioread_nolock");
> > >  			goto failed_mount;
> > >  		}
> > > +		if (test_opt(sb, DAX)) {
> > > +			ext4_msg(sb, KERN_ERR, "can't mount with "
> > > +				 "both data=journal and dax");
> > 
> > This limitation regarding ext4 and dax should be documented in dax
> > Documentation.
> 
> Maybe the ext4 documentation too?  It seems kind of obvious to me that if
> ypu're enabling in-place-updates that you can't journal the data you're
> updating (well ... you could implement undo-log journalling, I suppose,
> which would be quite a change for ext4)

Yes, we could document this limitation in general for all journalling FS within
DAX documentation, and then document it specifically per-FS in the FS
documentation.

Thanks,

Mathieu

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
