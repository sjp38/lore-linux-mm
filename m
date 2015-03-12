Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0A6829A3
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 12:18:13 -0400 (EDT)
Received: by qcwb13 with SMTP id b13so19752997qcw.9
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 09:18:12 -0700 (PDT)
Received: from mail-qc0-x22f.google.com (mail-qc0-x22f.google.com. [2607:f8b0:400d:c01::22f])
        by mx.google.com with ESMTPS id i72si6999342qkh.25.2015.03.12.09.18.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Mar 2015 09:18:11 -0700 (PDT)
Received: by qcxr5 with SMTP id r5so19832416qcx.4
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 09:18:11 -0700 (PDT)
Date: Thu, 12 Mar 2015 12:18:10 -0400
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RESEND 0/3] memory_hotplug: hyperv: fix deadlock between
 memory adding and onlining
Message-ID: <20150312161810.GA18269@dhcp22.suse.cz>
References: <1423736634-338-1-git-send-email-vkuznets@redhat.com>
 <20150306155002.GB23443@dhcp22.suse.cz>
 <871tkyy35g.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <871tkyy35g.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Fabian Frederick <fabf@skynet.be>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Vladimir Davydov <vdavydov@parallels.com>, Wang Nan <wangnan0@huawei.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, devel@linuxdriverproject.org, linux-mm@kvack.org

On Mon 09-03-15 09:40:43, Vitaly Kuznetsov wrote:
> Michal Hocko <mhocko@suse.cz> writes:
> 
> > [Sorry for the late response]
> >
> > This is basically the same code posted by KY Srinivasan posted late last
> > year (http://marc.info/?l=linux-mm&m=141782228129426&w=2). I had
> > objections to the implementation
> > http://marc.info/?l=linux-mm&m=141805109216700&w=2
> 
> Np, David's alternative fix is already in -mm:
> 
> https://lkml.org/lkml/2015/2/12/655

Thanks for the pointer. I have missed this one. This is definitely a
better approach than cluttering around exporting device lock.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
