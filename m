Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C515E6B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 04:49:48 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 11so10752878wrb.10
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 01:49:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i1si1530512ede.65.2017.11.14.01.49.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Nov 2017 01:49:47 -0800 (PST)
Date: Tue, 14 Nov 2017 10:49:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: replace FSF address with web source in license
 notices
Message-ID: <20171114094946.owfohzm5iplttdw6@dhcp22.suse.cz>
References: <20171114094438.28224-1-martink@posteo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171114094438.28224-1-martink@posteo.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Kepplinger <martink@posteo.de>
Cc: catalin.marinas@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 14-11-17 10:44:38, Martin Kepplinger wrote:
> A few years ago the FSF moved and "59 Temple Place" is wrong. Having this
> still in our source files feels old and unmaintained.
> 
> Let's take the license statement serious and not confuse users.
> 
> As https://www.gnu.org/licenses/gpl-howto.html suggests, we replace the
> postal address with "<http://www.gnu.org/licenses/>" in the mm directory.

Why to change this now? Isn't there a general plan to move to SPDX?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
