Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7396B02C4
	for <linux-mm@kvack.org>; Fri,  5 May 2017 09:30:31 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p62so762897wrc.13
        for <linux-mm@kvack.org>; Fri, 05 May 2017 06:30:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 2si5870742wrh.283.2017.05.05.06.30.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 May 2017 06:30:30 -0700 (PDT)
Date: Fri, 5 May 2017 15:30:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 4/4] mm: Adaptive hash table scaling
Message-ID: <20170505133029.GC31461@dhcp22.suse.cz>
References: <1488432825-92126-1-git-send-email-pasha.tatashin@oracle.com>
 <1488432825-92126-5-git-send-email-pasha.tatashin@oracle.com>
 <20170303153247.f16a31c95404c02a8f3e2c5f@linux-foundation.org>
 <20170426201126.GA32407@dhcp22.suse.cz>
 <40f72efa-3928-b3c6-acca-0740f1a15ba4@oracle.com>
 <429c8506-c498-0599-4258-7bac947fe29c@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <429c8506-c498-0599-4258-7bac947fe29c@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

On Thu 04-05-17 14:28:51, Pasha Tatashin wrote:
> BTW, I am OK with your patch on top of this "Adaptive hash table" patch, but
> I do not know what high_limit should be from where HASH_ADAPT will kick in.
> 128M sound reasonable to you?

For simplicity I would just use it unconditionally when no high_limit is
set. What would be the problem with that? If you look at current users
(and there no new users emerging too often) then most of them just want
_some_ scaling. The original one obviously doesn't scale with large
machines. Are you OK to fold my change to your patch or you want me to
send a separate patch? AFAIK Andrew hasn't posted this patch to Linus
yet.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
