Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC6F6B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 05:36:36 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o201so995695wmg.3
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 02:36:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i12si1048670wme.196.2017.08.15.02.36.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Aug 2017 02:36:35 -0700 (PDT)
Date: Tue, 15 Aug 2017 11:36:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 15/15] mm: debug for raw alloctor
Message-ID: <20170815093631.GD29067@dhcp22.suse.cz>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-16-git-send-email-pasha.tatashin@oracle.com>
 <20170811130831.GN30811@dhcp22.suse.cz>
 <87d84cad-f03a-88f0-7828-6d3bf7ac473c@oracle.com>
 <20170814115000.GJ19063@dhcp22.suse.cz>
 <b4eb28ad-2d58-fb23-2139-427df46c2773@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b4eb28ad-2d58-fb23-2139-427df46c2773@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

On Mon 14-08-17 10:01:52, Pasha Tatashin wrote:
> >>However, now thinking about it, I will change it to CONFIG_MEMBLOCK_DEBUG,
> >>and let users decide what other debugging configs need to be enabled, as
> >>this is also OK.
> >
> >Actually the more I think about it the more I am convinced that a kernel
> >boot parameter would be better because it doesn't need the kernel to be
> >recompiled and it is a single branch in not so hot path.
> 
> The main reason I do not like kernel parameter is that automated test suits
> for every platform would need to be updated to include this new parameter in
> order to test it.

How does this differ from the enabling a config option and building a
separate kernel?

My primary point of the kernel option was to have something available to
debug without recompiling the kernel which is more tedious than simply
adding one option to the kernel command line.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
