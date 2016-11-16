Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8136B026B
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 09:27:59 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i131so25864398wmf.3
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 06:27:59 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id qa4si33498479wjc.238.2016.11.16.06.27.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 06:27:57 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id u144so11651793wmu.0
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 06:27:57 -0800 (PST)
Date: Wed, 16 Nov 2016 17:27:55 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 11/21] mm: Remove unnecessary vma->vm_ops check
Message-ID: <20161116142755.GA28051@node.shutemov.name>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-12-git-send-email-jack@suse.cz>
 <20161115222819.GK23021@node>
 <20161116132918.GK21785@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161116132918.GK21785@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Nov 16, 2016 at 02:29:18PM +0100, Jan Kara wrote:
> On Wed 16-11-16 01:28:19, Kirill A. Shutemov wrote:
> > On Fri, Nov 04, 2016 at 05:25:07AM +0100, Jan Kara wrote:
> > > We don't check whether vma->vm_ops is NULL in do_shared_fault() so
> > > there's hardly any point in checking it in wp_page_shared() or
> > > wp_pfn_shared() which get called only for shared file mappings as well.
> > > 
> > > Signed-off-by: Jan Kara <jack@suse.cz>
> > 
> > Well, I'm not sure about this.
> > 
> > do_shared_fault() doesn't have the check since we checked it upper by
> > stack: see vma_is_anonymous() in handle_pte_fault().
> > 
> > In principal, it should be fine. But random crappy driver has potential to
> > blow it up.
> 
> Ok, so do you prefer me to keep this patch or discard it? Either is fine with
> me. It was just a cleanup I wrote when factoring out the functionality.

I would rather drop it.

Eventually, we need to make sure that all file-backed vma has vm_ops.
I tried to do this once, but that back-fired...

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
