Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 940FD6B025F
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:15:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v2so7636954pfa.4
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 07:15:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1si9014077pll.286.2017.10.10.07.15.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 07:15:49 -0700 (PDT)
Date: Tue, 10 Oct 2017 16:15:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v11 0/9] complete deferred page initialization
Message-ID: <20171010141547.zpdptsccsblyw634@dhcp22.suse.cz>
References: <20171009221931.1481-1-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171009221931.1481-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Btw. thanks for your persistance and willingness to go over all the
suggestions which might not have been consistent btween different
versions. I believe this is a general improvement in the early
initialization code. We do not rely on an implicit zeroing which just
happens to work by a chance. The perfomance improvements are a bonus on
top.

Thanks, good work!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
