Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id 908EC9003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 09:53:55 -0400 (EDT)
Received: by ykax123 with SMTP id x123so193384119yka.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 06:53:55 -0700 (PDT)
Received: from mail-yk0-x233.google.com (mail-yk0-x233.google.com. [2607:f8b0:4002:c07::233])
        by mx.google.com with ESMTPS id z188si1118594ywb.42.2015.07.22.06.53.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 06:53:54 -0700 (PDT)
Received: by ykfw194 with SMTP id w194so112726227ykf.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 06:53:54 -0700 (PDT)
Date: Wed, 22 Jul 2015 09:53:52 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] percpu: add macro PCPU_CHUNK_AREA_IN_USE
Message-ID: <20150722135352.GK15934@mtj.duckdns.org>
References: <1437404130-5188-1-git-send-email-bhe@redhat.com>
 <1437404130-5188-3-git-send-email-bhe@redhat.com>
 <20150721153019.GH15934@mtj.duckdns.org>
 <20150722002839.GC1834@dhcp-17-102.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150722002839.GC1834@dhcp-17-102.nay.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Wed, Jul 22, 2015 at 08:28:39AM +0800, Baoquan He wrote:
> I know this change makes code longer. PCPU_MAP_BUSY is better, I am gonna
> repost with it.

While at it, can you also please add comment on top of the definition
of PCPU_MAP_BUSY explaining what's going on?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
