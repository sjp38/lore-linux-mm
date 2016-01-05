Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id DCFE46B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 10:44:56 -0500 (EST)
Received: by mail-qk0-f176.google.com with SMTP id q19so86523517qke.3
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 07:44:56 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id q7si107397767qgd.110.2016.01.05.07.44.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 07:44:56 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, oom: skip mlocked VMAs in __oom_reap_vmas()
References: <1451421990-32297-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1451421990-32297-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20160105133338.GC15324@dhcp22.suse.cz>
 <20160105150339.GD19907@node.shutemov.name>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <568BE4F1.5060804@oracle.com>
Date: Tue, 5 Jan 2016 10:44:49 -0500
MIME-Version: 1.0
In-Reply-To: <20160105150339.GD19907@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 01/05/2016 10:03 AM, Kirill A. Shutemov wrote:
> On Tue, Jan 05, 2016 at 02:33:38PM +0100, Michal Hocko wrote:
>> > On Tue 29-12-15 23:46:29, Kirill A. Shutemov wrote:
>>> > > As far as I can see we explicitly munlock pages everywhere before unmap
>>> > > them. The only case when we don't to that is OOM-reaper.
>>> > > 
>>> > > I don't think we should bother with munlocking in this case, we can just
>>> > > skip the locked VMA.
>>> > > 
>>> > > I think this patch would fix this crash:
>>> > >  http://lkml.kernel.org/r/5661FBB6.6050307@oracle.com
>> > 
>> > Btw, do you happen to have the full log here. OOM reaper can only
>> > interfere if there was an OOM killer invoked.
> No, I don't. Sasha?

I don't have the log, but my setup does invoke the OOM killer occasionally.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
