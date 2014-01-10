Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f175.google.com (mail-ea0-f175.google.com [209.85.215.175])
	by kanga.kvack.org (Postfix) with ESMTP id 200056B0031
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 12:14:34 -0500 (EST)
Received: by mail-ea0-f175.google.com with SMTP id z10so2184448ead.20
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 09:14:33 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d41si1790076eep.8.2014.01.10.09.14.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 09:14:32 -0800 (PST)
Message-ID: <52D02A76.50005@suse.cz>
Date: Fri, 10 Jan 2014 18:14:30 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: [LSF/MM ATTEND] Memory management
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org

Hi,

I would like to attend LSF/MM. I'm working in the MM area for half a 
year now, so I'm still learning a lot and hope that the discussions 
would help me clarify longer-term goals to pursue. In general, I'm (of 
course) interested in improving performance where possible, perhaps by 
better use of features the hardware offers. In the past I've been doing 
academic research on performance modeling on shared caches and hope to 
put that experience to use somehow.

During the half year in MM so far, I've been improving performance of 
munlock operations (merged in 3.12), memory compaction effectiveness (in 
mmotm) and recently helping fix the trinity fallout. Currently I 
continue investigating memory compaction with the goal of having similar 
success rates as it used to have around 3.0, but without the associated 
massive performance penalty.

--
Vlastimil Babka
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
