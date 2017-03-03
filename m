Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D3D616B0389
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 03:50:41 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id f84so91517341ioj.6
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 00:50:41 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id c6si11738534ioa.182.2017.03.03.00.50.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 00:50:41 -0800 (PST)
Date: Fri, 3 Mar 2017 09:50:44 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3] lockdep: Teach lockdep about memalloc_noio_save
Message-ID: <20170303085044.GW6515@twins.programming.kicks-ass.net>
References: <1488367797-27278-1-git-send-email-nborisov@suse.com>
 <20170301154659.GL6515@twins.programming.kicks-ass.net>
 <20170301160529.GI11730@dhcp22.suse.cz>
 <20170301161220.GP6515@twins.programming.kicks-ass.net>
 <20170301161854.GJ11730@dhcp22.suse.cz>
 <20170303080419.GA31582@dhcp22.suse.cz>
 <20170303082250.GU6515@twins.programming.kicks-ass.net>
 <20170303083106.GC31499@dhcp22.suse.cz>
 <20170303083723.GD31499@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170303083723.GD31499@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Nikolay Borisov <nborisov@suse.com>, linux-kernel@vger.kernel.org, vbabka.lkml@gmail.com, linux-mm@kvack.org, mingo@redhat.com

On Fri, Mar 03, 2017 at 09:37:24AM +0100, Michal Hocko wrote:
> Btw. can I assume your Acked-by?

Yeah,

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
