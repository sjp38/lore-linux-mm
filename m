Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CEF1A8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 05:23:15 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e17so6671869edr.7
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 02:23:15 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p26-v6si826269eji.30.2018.12.11.02.23.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 02:23:14 -0800 (PST)
Date: Tue, 11 Dec 2018 11:23:13 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, sparse: remove check with
 __highest_present_section_nr in for_each_present_section_nr()
Message-ID: <20181211102313.GG1286@dhcp22.suse.cz>
References: <20181211035128.43256-1-richard.weiyang@gmail.com>
 <20181211094441.GD1286@dhcp22.suse.cz>
 <20181211101905.xczl6bndmrqwukni@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211101905.xczl6bndmrqwukni@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, osalvador@suse.de

On Tue 11-12-18 10:19:05, Wei Yang wrote:
> On Tue, Dec 11, 2018 at 10:44:41AM +0100, Michal Hocko wrote:
> >On Tue 11-12-18 11:51:28, Wei Yang wrote:
> >> A valid present section number is in [0, __highest_present_section_nr].
> >> And the return value of next_present_section_nr() meets this
> >> requirement. This means it is not necessary to check it with
> >> __highest_present_section_nr again in for_each_present_section_nr().
> >> 
> >> Since we pass an unsigned long *section_nr* to
> >> for_each_present_section_nr(), we need to cast it to int before
> >> comparing.
> >
> >Why do we want this patch? Is it an improvement? If yes, it is
> >performance visible change or does it make the code easier to maintain?
> >
> 
> Michal
> 
> I know you concern, maintainance is a very critical part of review.
> 
> >To me at least the later seems dubious to be honest because it adds a
> >non-obvious dependency of the terminal condition to the
> >next_present_section_nr implementation and that might turn out error
> >prone.
> >
> 
> While I think the original code is not that clear about the syntax.
> 
> When we look at the next_present_section_nr(section_nr), the return
> value falls into two categories:
> 
>   -1   : no more present section after section_nr
>   other: the next present section number after section_nr
> 
> Based on this syntax, the iteration could be simpler to terminate
> when the return value is less than 0. This is what the patch tries to
> do.
> 
> Maybe I could do more to help the maintainance:
> 
>   * add some comment about the return value of next_present_section_nr
>   * terminate the loop when section_nr == -1
> 
> Hope this would help a little.

Well, not really. Nothing of the above seems to matter to callers of the
code. So I do not see this as a general improvement and as such no
strong reason to merge it. It is basicly polishing a code without any
obvious issues.
-- 
Michal Hocko
SUSE Labs
