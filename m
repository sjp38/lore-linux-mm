Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA2E56B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 07:44:32 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id r2so8948093wra.4
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 04:44:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q50si3425318edq.170.2017.11.24.04.44.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 04:44:31 -0800 (PST)
Date: Fri, 24 Nov 2017 13:44:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: [PATCH 1/1] stackdepot: interface to check entries and size
 of stackdepot.
Message-ID: <20171124124429.juonhyw4xbqc65u7@dhcp22.suse.cz>
References: <CACT4Y+bF7TGFS+395kyzdw21M==ECgs+dCjV0e3Whkvm1_piDA@mail.gmail.com>
 <20171123162835.6prpgrz3qkdexx56@dhcp22.suse.cz>
 <1511347661-38083-1-git-send-email-maninder1.s@samsung.com>
 <20171124094108epcms5p396558828a365a876d61205b0fdb501fd@epcms5p3>
 <20171124095428.5ojzgfd24sy7zvhe@dhcp22.suse.cz>
 <CGME20171122105142epcas5p173b7205da12e1fc72e16ec74c49db665@epcms5p4>
 <20171124115707epcms5p4fa19970a325e87f08eadb1b1dc6f0701@epcms5p4>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171124115707epcms5p4fa19970a325e87f08eadb1b1dc6f0701@epcms5p4>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vaneet Narang <v.narang@samsung.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Maninder Singh <maninder1.s@samsung.com>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "jkosina@suse.cz" <jkosina@suse.cz>, "pombredanne@nexb.com" <pombredanne@nexb.com>, "jpoimboe@redhat.com" <jpoimboe@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "guptap@codeaurora.org" <guptap@codeaurora.org>, "vinmenon@codeaurora.org" <vinmenon@codeaurora.org>, AMIT SAHRAWAT <a.sahrawat@samsung.com>, PANKAJ MISHRA <pankaj.m@samsung.com>, Lalit Mohan Tripathi <lalit.mohan@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>

On Fri 24-11-17 11:57:07, Vaneet Narang wrote:
[...]
> > OK, so debugging a debugging facility... I do not think we want to
> > introduce a lot of code for something like that.
> 
> We enabled stackdepot on our system and realised, in long run stack depot consumes
> more runtime memory then it actually needs. we used shared patch to debug this issue. 
> stack stores following two unique entries. Page allocation done in interrupt 
> context will generate a unique stack trace. Consider following two entries.
[...]
> We have been getting similar kind of such entries and eventually
> stackdepot reaches Max Cap. So we found this interface useful in debugging
> stackdepot issue so shared in community.

Then use it for internal debugging and provide a code which would scale
better on smaller systems. We do not need this in the kernel IMHO. We do
not merge all the debugging patches we use for internal development.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
