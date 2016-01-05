Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7269F6B0007
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 10:03:42 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id f206so26385392wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 07:03:42 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id ei4si147690373wjd.8.2016.01.05.07.03.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 07:03:41 -0800 (PST)
Received: by mail-wm0-x22a.google.com with SMTP id l65so26092615wmf.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 07:03:41 -0800 (PST)
Date: Tue, 5 Jan 2016 17:03:39 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2] mm, oom: skip mlocked VMAs in __oom_reap_vmas()
Message-ID: <20160105150339.GD19907@node.shutemov.name>
References: <1451421990-32297-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1451421990-32297-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20160105133338.GC15324@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160105133338.GC15324@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Jan 05, 2016 at 02:33:38PM +0100, Michal Hocko wrote:
> On Tue 29-12-15 23:46:29, Kirill A. Shutemov wrote:
> > As far as I can see we explicitly munlock pages everywhere before unmap
> > them. The only case when we don't to that is OOM-reaper.
> > 
> > I don't think we should bother with munlocking in this case, we can just
> > skip the locked VMA.
> > 
> > I think this patch would fix this crash:
> >  http://lkml.kernel.org/r/5661FBB6.6050307@oracle.com
> 
> Btw, do you happen to have the full log here. OOM reaper can only
> interfere if there was an OOM killer invoked.

No, I don't. Sasha?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
