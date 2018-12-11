Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CDE138E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 00:09:56 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o21so6384918edq.4
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 21:09:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ge18-v6sor3659994ejb.16.2018.12.10.21.09.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Dec 2018 21:09:55 -0800 (PST)
Date: Tue, 11 Dec 2018 05:09:53 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, sparse: remove check with
 __highest_present_section_nr in for_each_present_section_nr()
Message-ID: <20181211050953.nj3kwmwzhprsam5z@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181211035128.43256-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211035128.43256-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.com, osalvador@suse.de

On Tue, Dec 11, 2018 at 11:51:28AM +0800, Wei Yang wrote:
>A valid present section number is in [0, __highest_present_section_nr].
>And the return value of next_present_section_nr() meets this
>requirement. This means it is not necessary to check it with

            ^ , if it is not (-1)

Would like to add this to be more exact.

>__highest_present_section_nr again in for_each_present_section_nr().
>
>Since we pass an unsigned long *section_nr* to
>for_each_present_section_nr(), we need to cast it to int before
>comparing.
>
>Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>---
> mm/sparse.c | 3 +--
> 1 file changed, 1 insertion(+), 2 deletions(-)
>
>diff --git a/mm/sparse.c b/mm/sparse.c
>index a4fdbcb21514..9eaa8f98a3d2 100644
>--- a/mm/sparse.c
>+++ b/mm/sparse.c
>@@ -197,8 +197,7 @@ static inline int next_present_section_nr(int section_nr)
> }
> #define for_each_present_section_nr(start, section_nr)		\
> 	for (section_nr = next_present_section_nr(start-1);	\
>-	     ((section_nr >= 0) &&				\
>-	      (section_nr <= __highest_present_section_nr));	\
>+	     (int)section_nr >= 0;				\
> 	     section_nr = next_present_section_nr(section_nr))
> 
> static inline unsigned long first_present_section_nr(void)
>-- 
>2.15.1

-- 
Wei Yang
Help you, Help me
