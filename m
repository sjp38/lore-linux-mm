Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 30BC16B025F
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 03:32:50 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 63so159245247pfx.0
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 00:32:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t81si18315717wmf.1.2016.08.16.00.32.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Aug 2016 00:32:49 -0700 (PDT)
Date: Tue, 16 Aug 2016 09:32:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM killer changes
Message-ID: <20160816073246.GC5001@dhcp22.suse.cz>
References: <3c022d92-9c96-9022-8496-aa8738fb7358@quantum.com>
 <20160801202616.GG31957@dhcp22.suse.cz>
 <b91f97ee-c369-43be-c934-f84b96260ead@Quantum.com>
 <27bd5116-f489-252c-f257-97be00786629@Quantum.com>
 <20160802071010.GB12403@dhcp22.suse.cz>
 <ccad54a2-be1e-44cf-b9c8-d6b34af4901d@quantum.com>
 <6cb37d4a-d2dd-6c2f-a65d-51474103bf86@Quantum.com>
 <d1f63745-b9e3-b699-8a5a-08f06c72b392@suse.cz>
 <20160815150123.GG3360@dhcp22.suse.cz>
 <1b8ee89d-a851-06f0-6bcc-62fef9e7e7cc@Quantum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1b8ee89d-a851-06f0-6bcc-62fef9e7e7cc@Quantum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon 15-08-16 11:42:11, Ralf-Peter Rohbeck wrote:
> This time the OOM killer hit much quicker. No btrfs balance, just compiling
> the kernel with the new change did it.
> Much smaller logs so I'm attaching them.

Just to clarify. You have added the trace_printk for
try_to_release_page, right? (after fixing it of course). If yes there is
no single mention of that path failing which would support Joonsoo's
theory... Could you try with his patch?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
