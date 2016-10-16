Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D7AC06B0038
	for <linux-mm@kvack.org>; Sun, 16 Oct 2016 03:33:44 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o81so14175173wma.1
        for <linux-mm@kvack.org>; Sun, 16 Oct 2016 00:33:44 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id lh9si10451921wjc.188.2016.10.16.00.33.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Oct 2016 00:33:43 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id z189so5049937wmb.1
        for <linux-mm@kvack.org>; Sun, 16 Oct 2016 00:33:43 -0700 (PDT)
Date: Sun, 16 Oct 2016 09:33:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] scripts: Include postprocessing script for memory
 allocation tracing
Message-ID: <20161016073340.GA15839@dhcp22.suse.cz>
References: <20160911222411.GA2854@janani-Inspiron-3521>
 <20160912121635.GL14524@dhcp22.suse.cz>
 <0ACE5927-A6E5-4B49-891D-F990527A9F50@gmail.com>
 <20160919094224.GH10785@dhcp22.suse.cz>
 <BFAF8DCA-F4A6-41C6-9AA0-C694D33035A3@gmail.com>
 <20160923080709.GB4478@dhcp22.suse.cz>
 <E8FAA4EF-DAA1-4E18-B48F-6677E6AFE76E@gmail.com>
 <2D27EF16-B63B-4516-A156-5E2FB675A1BB@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2D27EF16-B63B-4516-A156-5E2FB675A1BB@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 15-10-16 19:31:22, Janani Ravichandran wrote:
> 
> > On Oct 11, 2016, at 10:43 AM, Janani Ravichandran <janani.rvchndrn@gmail.com> wrote:
> > 
> > Alright. Ia??ll add a starting tracepoint, change the script accordingly and 
> > send a v2. Thanks!
> > 
> I looked at it again and I think that the context information we need 
> can be obtained from the tracepoint trace_mm_page_alloc in 
> alloc_pages_nodemask().

trace_mm_page_alloc will tell you details about the allocation, like
gfp mask, order but it doesn't tell you how long the allocation took at
its current form. So either you have to note jiffies at the allocation
start and then add the end-start in the trace point or we really need
another trace point to note the start. The later has an advantage that
we do not add unnecessary load for jiffies when the tracepoint is
disabled.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
